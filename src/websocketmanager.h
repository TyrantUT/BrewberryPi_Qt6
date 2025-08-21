#ifndef WEBSOCKETMANAGER_H
#define WEBSOCKETMANAGER_H

#include <QObject>
#include <QWebSocketServer>
#include <QWebSocket>
#include <QList>
#include <QMutex>
#include <QJsonDocument>
#include "imports/BrewberryPi/rpidata.h"

class WebSocketManager : public QObject {
    Q_OBJECT
public:
    explicit WebSocketManager(QObject *parent = nullptr);
    ~WebSocketManager();

    bool startServer(quint16 port);
    void setRPiData(RPiData *rpiData);

public slots:
    void broadcastData();
    void closeServer();

private slots:
    void onNewConnection();
    void onClientDisconnected();
    void onClientError(QAbstractSocket::SocketError error);
    QString serializeData(bool includeRateLimited);

private:
    QWebSocketServer *m_server;
    QList<QWebSocket*> m_clients;
    int m_messageCounter = 0;
    QMutex m_clientsMutex;
    RPiData *m_rpiData;
};

#endif // WEBSOCKETMANAGER_H
