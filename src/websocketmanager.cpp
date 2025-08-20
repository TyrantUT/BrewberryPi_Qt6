#include "websocketmanager.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>
#include <QFile>
#include <QSslKey>
#include <QSslCertificate>
#include <QSslConfiguration>
#include <utility>

WebSocketManager::WebSocketManager(QObject *parent) : QObject(parent), m_server(nullptr), m_rpiData(nullptr) {
    m_server = new QWebSocketServer(QStringLiteral("Brewberry Pi Server"), QWebSocketServer::SecureMode, this);

    QSslConfiguration sslConfig;
    QFile certFile(":/ssl/server.crt");
    QFile keyFile(":/ssl/server.key");

    if (!certFile.open(QIODevice::ReadOnly) || !keyFile.open(QIODevice::ReadOnly)) {
        qDebug() << "Failed to open SSL certificate or key file";
        return;
    }

    QSslCertificate certificate(&certFile, QSsl::Pem);
    QSslKey key(&keyFile, QSsl::Rsa, QSsl::Pem);
    certFile.close();
    keyFile.close();

    if (certificate.isNull() || key.isNull()) {
        qDebug() << "Invalid SSL certificate or key";
        return;
    }

    sslConfig.setLocalCertificate(certificate);
    sslConfig.setPrivateKey(key);
    sslConfig.setProtocol(QSsl::TlsV1_2OrLater);
    m_server->setSslConfiguration(sslConfig);
}

WebSocketManager::~WebSocketManager()
{
}

bool WebSocketManager::startServer(quint16 port)
{
    if (m_server->listen(QHostAddress::Any, port)) {
        qDebug() << "WebSocket server started on port" << port;
        connect(m_server, &QWebSocketServer::newConnection, this, &WebSocketManager::onNewConnection);
        return true;
    } else {
        qDebug() << "Failed to start WebSocket server:" << m_server->errorString();
        return false;
    }
}

void WebSocketManager::setRPiData(RPiData *rpiData)
{
    m_rpiData = rpiData;
    if (m_rpiData) {
        // Connect all RPiData signals to broadcastData
        connect(m_rpiData, &RPiData::setpointHltOrMashChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::currentTemp_HLTChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::currentTemp_MashChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::currentTemp_BoilChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::currentTemp_Mash2Changed, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::setpointTemp_HLTChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::setpointTemp_MashChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::setpointTemp_BoilChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::setpointPercent_HLTChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::setpointPercent_MashChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::setpointPercent_BoilChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::setpointManual_HLTChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::setpointManual_BoilChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::elementOn_HLTChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::elementOn_BoilChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::pumpOn_WortChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::pumpOn_WaterChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::pwmDutyCycle_HLTChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::pwmDutyCycle_BoilChanged, this, &WebSocketManager::broadcastData);
        connect(m_rpiData, &RPiData::breweryTimerChanged, this, &WebSocketManager::broadcastData);
    }
}

QJsonObject WebSocketManager::serializeRPiData(bool includeRateLimited)
{
    QJsonObject json;
    // Always include non-rate-limited fields
    json["setpointHltOrMash"] = m_rpiData->getSetpointHltOrMash();
    json["setpointManual_HLT"] = m_rpiData->getSetpointManual_HLT();
    json["setpointManual_Boil"] = m_rpiData->getSetpointManual_Boil();
    json["elementOn_HLT"] = m_rpiData->getElementOn_HLT();
    json["elementOn_Boil"] = m_rpiData->getElementOn_Boil();
    json["pumpOn_Wort"] = m_rpiData->getPumpOn_Wort();
    json["pumpOn_Water"] = m_rpiData->getPumpOn_Water();
    json["pwmDutyCycle_HLT"] = m_rpiData->getPwmDutyCycle_HLT();
    json["pwmDutyCycle_Boil"] = m_rpiData->getPwmDutyCycle_Boil();
    json["breweryTimer"] = m_rpiData->getBreweryTimer();

    // Include rate-limited fields only every 5th message
    if (includeRateLimited) {
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
    }

    return json;
}

void WebSocketManager::broadcastData()
{
    if (!m_rpiData || m_clients.isEmpty()) return;

    // Increment counter and determine if rate-limited fields should be included
    m_messageCounter = (m_messageCounter + 1) % 5;
    bool includeRateLimited = (m_messageCounter == 0);

    // Serialize data
    QJsonDocument doc(serializeRPiData(includeRateLimited));
    QString jsonString = QString(doc.toJson(QJsonDocument::Compact));

    // Broadcast to all clients
    QMutexLocker locker(&m_clientsMutex);
    for (QWebSocket *client : std::as_const(m_clients)) {
        if (client->state() == QAbstractSocket::ConnectedState) {
            client->sendTextMessage(jsonString);
        }
    }
    qDebug() << "Broadcast data (rate-limited:" << includeRateLimited << "):" << jsonString;
}

void WebSocketManager::onNewConnection()
{
    QWebSocket *client = m_server->nextPendingConnection();
    if (client) {
        QMutexLocker locker(&m_clientsMutex);
        m_clients.append(client);
        qDebug() << "New client connected. Total clients:" << m_clients.size();

        // Connect client signals
        connect(client, &QWebSocket::disconnected, this, &WebSocketManager::onClientDisconnected);
        connect(client, &QWebSocket::errorOccurred, this, &WebSocketManager::onClientError);
    }
}

void WebSocketManager::onClientDisconnected()
{
    QWebSocket *client = qobject_cast<QWebSocket*>(sender());
    if (client) {
        QMutexLocker locker(&m_clientsMutex);
        m_clients.removeOne(client);
        qDebug() << "Client disconnected. Total clients:" << m_clients.size();
        client->deleteLater();
    }
}

void WebSocketManager::onClientError(QAbstractSocket::SocketError error)
{
    QWebSocket *client = qobject_cast<QWebSocket*>(sender());
    if (client) {
        qDebug() << "Client error:" << client->errorString();
    }
}

void WebSocketManager::closeServer()
{
    m_server->close();
    QMutexLocker locker(&m_clientsMutex);
    for (QWebSocket *client : std::as_const(m_clients)) {
        disconnect(client, nullptr, this, nullptr);
        client->close();
        client->deleteLater();
    }
    m_clients.clear();
    qDebug() << "WebSocket server closed and clients disconnected";
}
