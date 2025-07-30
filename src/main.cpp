#include <QQmlApplicationEngine>
#include <QApplication>
#include <QQmlContext>
#include <QQuickWindow>
#include "app_environment.h"
#include "import_qml_plugins.h"
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

int main(int argc, char *argv[]) {

// Disable debug, info, and warning output in Release profile
#ifdef QT_NO_DEBUG_OUTPUT
    qputenv("QT_LOGGING_RULES", "qml=false");
    const char* nullStream = "/dev/null";
    if (!freopen(nullStream, "a", stdout)) assert(false);
    if (!freopen(nullStream, "a", stderr)) assert(false);
#endif

    // Allow file reads inside the qrc files
    //qputenv("QML_XHR_ALLOW_FILE_READ", QByteArray("1"));

    set_qt_environment();

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;


    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    if (QSysInfo::productType() != "macos") {
        QCursor cursor(Qt::BlankCursor);
        QApplication::setOverrideCursor(cursor);
        QApplication::changeOverrideCursor(cursor);
    }

    const QUrl url(u"qrc:/qt/qml/Main/main.qml"_qs);
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

    QObject::connect(&app, &QCoreApplication::aboutToQuit, temperatureThread, [temperatureThread]() {
        // Handle pidHLTThread cleanup
        temperatureThread->requestInterruption();
        temperatureThread->quit();  // Ask the thread to quit (non-blocking)
        temperatureThread->wait();  // Wait for the thread to finish (blocking)
        temperatureThread->deleteLater();  // Clean up the thread object
    }, Qt::DirectConnection);

    QObject::connect(&app, &QCoreApplication::aboutToQuit, pidHLTThread, [pidHLTThread]() {
        // Handle pidHLTThread cleanup
        pidHLTThread->requestInterruption();
        pidHLTThread->quit();
        pidHLTThread->wait();
        pidHLTThread->deleteLater();
    }, Qt::DirectConnection);

    QObject::connect(&app, &QCoreApplication::aboutToQuit, pidBoilThread, [pidBoilThread]() {
        // Handle pidBoilThread cleanup
        pidBoilThread->requestInterruption();
        pidBoilThread->quit();
        pidBoilThread->wait();
        pidBoilThread->deleteLater();
    }, Qt::DirectConnection);

    temperatureThread->start();
    pidHLTThread->start();
    pidBoilThread->start();

    temperatureThread->setPriority(QThread::TimeCriticalPriority);
    pidHLTThread->setPriority((QThread::HighPriority));
    pidBoilThread->setPriority((QThread::HighPriority));

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
