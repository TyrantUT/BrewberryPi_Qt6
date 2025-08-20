#include "websocketmanager.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>

WebSocketManager::WebSocketManager(QObject *parent) : QObject(parent), m_server(nullptr), m_rpiData(nullptr) {
    m_server = new QWebSocketServer(QStringLiteral("BrewPi Server"), QWebSocketServer::NonSecureMode, this);
}

WebSocketManager::~WebSocketManager() {
    QMutexLocker locker(&m_clientsMutex);
    for (QWebSocket *client : m_clients) {
        client->close();
        client->deleteLater();
    }
    m_clients.clear();
    if (m_server) {
        m_server->close();
    }
}

bool WebSocketManager::startServer(quint16 port) {
    if (!m_server->listen(QHostAddress::Any, port)) {
        qDebug() << "Failed to start WebSocket server on port" << port << ":" << m_server->errorString();
        return false;
    }
    qDebug() << "WebSocket server started on ws://0.0.0.0:" << port;
    connect(m_server, &QWebSocketServer::newConnection, this, &WebSocketManager::onNewConnection);
    return true;
}

void WebSocketManager::setRPiData(RPiData *rpiData) {
    m_rpiData = rpiData;
}

void WebSocketManager::onNewConnection() {
    QWebSocket *client = m_server->nextPendingConnection();
    {
        QMutexLocker locker(&m_clientsMutex);
        m_clients.append(client);
    }
    qDebug() << "New client connected:" << client->peerAddress().toString();

    // Send current RPiData to new client
    if (m_rpiData) {
        QJsonObject json;
        json["setpointHltOrMash"] = m_rpiData->getSetpointHltOrMash();
        json["currentTemp_HLT"] = m_rpiData->getCurrentTemp_HLT();
        json["currentTemp_Mash"] = m_rpiData->getCurrentTemp_Mash();
        json["currentTemp_Boil"] = m_rpiData->getCurrentTemp_Boil();
        json["currentTemp_Mash2"] = m_rpiData->getCurrentTemp_Mash2();
        json["setpointTemp_HLT"] = m_rpiData->getSetpointTemp_HLT();
        json["setpointTemp_Mash"] = m_rpiData->getSetpointTemp_Mash();
        json["setpointTemp_Boil"] = m_rpiData->getSetpointTemp_Boil();
        json["setpointPercent_HLT"] = m_rpiData->getSetpointPercent_HLT();
        json["setpointPercent_Mash"] = m_rpiData->getSetpointPercent_Mash();
        json["setpointPercent_Boil"] = m_rpiData->getSetpointPercent_Boil();
        json["setpointManual_HLT"] = m_rpiData->getSetpointManual_HLT();
        json["setpointManual_Boil"] = m_rpiData->getSetpointManual_Boil();
        json["elementOn_HLT"] = m_rpiData->getElementOn_HLT();
        json["elementOn_Boil"] = m_rpiData->getElementOn_Boil();
        json["pumpOn_Wort"] = m_rpiData->getPumpOn_Wort();
        json["pumpOn_Water"] = m_rpiData->getPumpOn_Water();
        json["pwmDutyCycle_HLT"] = m_rpiData->getPwmDutyCycle_HLT();
        json["pwmDutyCycle_Boil"] = m_rpiData->getPwmDutyCycle_Boil();
        QJsonDocument doc(json);
        QString jsonString = QString(doc.toJson(QJsonDocument::Compact));
        client->sendTextMessage(jsonString);
    }

    connect(client, &QWebSocket::disconnected, this, &WebSocketManager::onClientDisconnected);
    connect(client, &QWebSocket::errorOccurred, this, &WebSocketManager::onClientError);
}

void WebSocketManager::onClientDisconnected() {
    QWebSocket *client = qobject_cast<QWebSocket*>(sender());
    if (client) {
        QMutexLocker locker(&m_clientsMutex);
        m_clients.removeAll(client);
        qDebug() << "Client disconnected:" << client->peerAddress().toString();
        client->deleteLater();
    }
}

void WebSocketManager::onClientError(QAbstractSocket::SocketError error) {
    QWebSocket *client = qobject_cast<QWebSocket*>(sender());
    if (client) {
        qDebug() << "Client error:" << client->errorString();
    }
}

void WebSocketManager::broadcastData() {
    if (!m_rpiData) return;

    QJsonObject json;
    json["setpointHltOrMash"] = m_rpiData->getSetpointHltOrMash();
    json["currentTemp_HLT"] = m_rpiData->getCurrentTemp_HLT();
    json["currentTemp_Mash"] = m_rpiData->getCurrentTemp_Mash();
    json["currentTemp_Boil"] = m_rpiData->getCurrentTemp_Boil();
    json["currentTemp_Mash2"] = m_rpiData->getCurrentTemp_Mash2();
    json["setpointTemp_HLT"] = m_rpiData->getSetpointTemp_HLT();
    json["setpointTemp_Mash"] = m_rpiData->getSetpointTemp_Mash();
    json["setpointTemp_Boil"] = m_rpiData->getSetpointTemp_Boil();
    json["setpointPercent_HLT"] = m_rpiData->getSetpointPercent_HLT();
    json["setpointPercent_Mash"] = m_rpiData->getSetpointPercent_Mash();
    json["setpointPercent_Boil"] = m_rpiData->getSetpointPercent_Boil();
    json["setpointManual_HLT"] = m_rpiData->getSetpointManual_HLT();
    json["setpointManual_Boil"] = m_rpiData->getSetpointManual_Boil();
    json["elementOn_HLT"] = m_rpiData->getElementOn_HLT();
    json["elementOn_Boil"] = m_rpiData->getElementOn_Boil();
    json["pumpOn_Wort"] = m_rpiData->getPumpOn_Wort();
    json["pumpOn_Water"] = m_rpiData->getPumpOn_Water();
    json["pwmDutyCycle_HLT"] = m_rpiData->getPwmDutyCycle_HLT();
    json["pwmDutyCycle_Boil"] = m_rpiData->getPwmDutyCycle_Boil();
    QJsonDocument doc(json);
    QString jsonString = QString(doc.toJson(QJsonDocument::Compact));

    QMutexLocker locker(&m_clientsMutex);
    for (QWebSocket *client : m_clients) {
        if (client->state() == QAbstractSocket::ConnectedState) {
            // Ensure sendTextMessage is called in the client's thread
            QMetaObject::invokeMethod(client, [client, jsonString]() {
                client->sendTextMessage(jsonString);
            }, Qt::QueuedConnection);
        }
    }
}
