#include <QQmlApplicationEngine>
#include <QApplication>
#include <QQmlContext>
#include "app_environment.h"
#include "import_qml_plugins.h"
#include "imports/BrewberryPi/pigpio.h"
#include "imports/BrewberryPi/rpidata.h"
#include "imports/BrewberryPi/rpithreads.h"

//#include "imports/BrewberryPi/temperaturethread.h"

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
    qputenv("QML_XHR_ALLOW_FILE_READ", QByteArray("1"));

    set_qt_environment();

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    if (QSysInfo::productType() != "macos") {
        QCursor cursor(Qt::BlankCursor);
        QApplication::setOverrideCursor(cursor);
        QApplication::changeOverrideCursor(cursor);
    }

    const QUrl url(u"qrc:/qt/qml/Main/main.qml"_qs);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    // Initalize GPIO
    gpioInitialise();

    // Initialize RPiData Class
    RPiData RPiDataGlobal;
    engine.rootContext()->setContextProperty("RPiDataGlobal", &RPiDataGlobal);

    // Temperature Thread
    RPiThreads* temperatureWorker = new RPiThreads(&RPiDataGlobal);
    QThread *tempThread = new QThread;
    temperatureWorker->moveToThread(tempThread);
    QObject::connect(tempThread, &QThread::started, temperatureWorker, &RPiThreads::processTemps);
    QObject::connect(tempThread, &QThread::finished, temperatureWorker, &QObject::deleteLater);
    QObject::connect(&app, &QCoreApplication::aboutToQuit, tempThread, [tempThread]() {
        tempThread->requestInterruption();
        tempThread->quit();  // Ask the thread to quit (non-blocking)
        tempThread->wait();  // Wait for the thread to finish (blocking)
        tempThread->deleteLater();  // Clean up the thread object
    }, Qt::DirectConnection);

    tempThread->setPriority(QThread::TimeCriticalPriority);
    tempThread->start();


    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

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
