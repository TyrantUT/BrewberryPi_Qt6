#ifndef CONNECTIONMANAGER_H
#define CONNECTIONMANAGER_H

#include <QObject>
#include <QDebug>
#include <QThreadPool>
#include "rpidata.h"

class ConnectionManager : public QObject
{
    Q_OBJECT

public:
    explicit ConnectionManager(QObject *parent = nullptr);

    // This method will be used to set up the connections
    void setupConnections(RPiData *RPiDataGlobal);
};

#endif // CONNECTIONMANAGER_H
