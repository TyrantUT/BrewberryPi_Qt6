#include <QQmlApplicationEngine>
#include <QApplication>
#include <QQmlContext>
#include <QQuickWindow>
#include "app_environment.h"
#include "import_qml_plugins.h"
#include "websocketmanager.h"
#include "imports/BrewberryPi/rpidata.h"
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

    set_qt_environment();

    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    // Set context attributes for Raspberry Pi
#ifdef PLATFORM_ARM
    qDebug() << "Input Devices:" << QInputDevice::devices();

    QSurfaceFormat format;
    format.setDepthBufferSize(16);
    format.setStencilBufferSize(8);
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    QSurfaceFormat::setDefaultFormat(format);
    QCursor cursor(Qt::BlankCursor);
    QApplication::setOverrideCursor(cursor);
    QApplication::changeOverrideCursor(cursor);
#endif

    using namespace Qt::StringLiterals;

    const QUrl url(QStringLiteral("qrc:/qt/qml/content/App.qml"));
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

    // Initialize ConnectionManager to handle all thread and app connections
    ConnectionManager connectionManager;
    connectionManager.setupConnections(&app, &RPiDataGlobal);

    // WebSocket server setup
    WebSocketManager webSocketManager(&app);
    webSocketManager.setRPiData(&RPiDataGlobal);
    if (!webSocketManager.startServer(8443)) {
        qDebug() << "Failed to start WebSocket server";
        return -1;
    }

    engine.load(url);
    if (engine.rootObjects().isEmpty()) return -1;

    // Set up signal handlers for graceful shutdown
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
