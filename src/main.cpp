#include <QQmlApplicationEngine>
#include <QApplication>
#include <QQmlContext>
#include <QQuickWindow>
#include "app_environment.h"
#include "import_qml_plugins.h"
#include "websocketmanager.h"
#include "imports/BrewberryPi/rpidata.h"
#include "imports/BrewberryPi/rpithreads.h"
#include "imports/BrewberryPi/rpihelper.h"
#include "imports/BrewberryPi/connectionmanager.h"
#include <csignal>

// Enable to remove debug outputs throughout code
//#define QT_NO_DEBUG_OUTPUT

void sigHandler(int s) {
    signal(s, SIG_DFL);
    qDebug() << "[X] Ctrl + C Caught: Quitting...";
    qApp->quit();
}

int main(int argc, char *argv[])
{
    // Disable debug, info, and warning output in Release profile
#ifdef QT_NO_DEBUG_OUTPUT
    qputenv("QT_LOGGING_RULES", "qml=false");
    const char* nullStream = "/dev/null";
    if (!freopen(nullStream, "a", stdout)) assert(false);
    if (!freopen(nullStream, "a", stderr)) assert(false);
#endif

    // Set OpenGL ES context attributes for Raspberry Pi
#ifndef PLATFORM_APPLE
    QSurfaceFormat format;
    format.setDepthBufferSize(16);
    format.setStencilBufferSize(8);
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    QSurfaceFormat::setDefaultFormat(format);
#endif

    set_qt_environment();

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    if (QSysInfo::productType() != "macos") {
        QCursor cursor(Qt::BlankCursor);
        QApplication::setOverrideCursor(cursor);
        QApplication::changeOverrideCursor(cursor);
    }

    using namespace Qt::StringLiterals;

    const QUrl url(u"qrc:/qt/qml/Main/main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    // Initialize RPi GPIO and set default values
    piSetup();

    // Initialize RPiData Class
    RPiData RPiDataGlobal;
    engine.rootContext()->setContextProperty("RPiDataGlobal", &RPiDataGlobal);

    // Temperature Thread
    RPiThreads *temperatureWorker = new RPiThreads(&RPiDataGlobal);
    RPiThreads *pidHLTWorker = new RPiThreads(&RPiDataGlobal);
    RPiThreads *pidBoilWorker = new RPiThreads(&RPiDataGlobal);

    QThread *temperatureThread = new QThread;
    QThread *pidHLTThread = new QThread;
    QThread *pidBoilThread = new QThread;

    temperatureWorker->moveToThread(temperatureThread);
    pidHLTWorker->moveToThread(pidHLTThread);
    pidBoilWorker->moveToThread(pidBoilThread);

    QObject::connect(temperatureThread, &QThread::started, temperatureWorker, &RPiThreads::processTemps);
    QObject::connect(temperatureThread, &QThread::finished, temperatureWorker, &QObject::deleteLater);

    QObject::connect(pidHLTThread, &QThread::started, pidHLTWorker, &RPiThreads::processPidHlt);
    QObject::connect(pidHLTThread, &QThread::finished, pidHLTWorker, &QObject::deleteLater);

    QObject::connect(pidBoilThread, &QThread::started, pidBoilWorker, &RPiThreads::processPidBoil);
    QObject::connect(pidBoilThread, &QThread::finished, pidBoilWorker, &QObject::deleteLater);

    ConnectionManager connectionManager;
    connectionManager.setupConnections(&RPiDataGlobal);

    // WebSocket server setup
    WebSocketManager *webSocketManager = new WebSocketManager(&app);
    webSocketManager->setRPiData(&RPiDataGlobal);
    if (!webSocketManager->startServer(8443)) {
        qDebug() << "Failed to start WebSocket server";
        return -1;
    }

    // Clean up on application quit
    QObject::connect(&app, &QCoreApplication::aboutToQuit, webSocketManager, &WebSocketManager::closeServer, Qt::DirectConnection);

    QObject::connect(&app, &QCoreApplication::aboutToQuit, temperatureThread, [temperatureThread]() {
        temperatureThread->requestInterruption();
        temperatureThread->quit();
        temperatureThread->wait();
        temperatureThread->deleteLater();
    }, Qt::DirectConnection);

    QObject::connect(&app, &QCoreApplication::aboutToQuit, pidHLTThread, [pidHLTThread]() {
        pidHLTThread->requestInterruption();
        pidHLTThread->quit();
        pidHLTThread->wait();
        pidHLTThread->deleteLater();
    }, Qt::DirectConnection);

    QObject::connect(&app, &QCoreApplication::aboutToQuit, pidBoilThread, [pidBoilThread]() {
        pidBoilThread->requestInterruption();
        pidBoilThread->quit();
        pidBoilThread->wait();
        pidBoilThread->deleteLater();
    }, Qt::DirectConnection);

    temperatureThread->start();
    pidHLTThread->start();
    pidBoilThread->start();

    temperatureThread->setPriority(QThread::TimeCriticalPriority);
    pidHLTThread->setPriority(QThread::HighPriority);
    pidBoilThread->setPriority(QThread::HighPriority);

    engine.load(url);
    if (engine.rootObjects().isEmpty()) return -1;

    signal(SIGTERM, sigHandler);
    signal(SIGKILL, sigHandler);
    signal(SIGHUP, sigHandler);
    signal(SIGINT, sigHandler);
    signal(SIGQUIT, sigHandler);
    signal(SIGILL, sigHandler);
    signal(SIGTRAP, sigHandler);
    signal(SIGABRT, sigHandler);
    signal(SIGUSR2, sigHandler);

    return app.exec();
}
