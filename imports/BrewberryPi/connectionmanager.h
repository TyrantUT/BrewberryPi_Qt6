#ifndef CONNECTIONMANAGER_H
#define CONNECTIONMANAGER_H

#include <QObject>
#include <QDebug>
#include <QThreadPool>
#include <QThread>
#include "rpidata.h"
#include "rpithreads.h"

class QApplication;

class ConnectionManager : public QObject
{
    Q_OBJECT

public:
    explicit ConnectionManager(QObject *parent = nullptr);
    ~ConnectionManager();

    void setupConnections(QApplication *app, RPiData *rpiData);

private:
    void setupRPiDataConnections(RPiData *rpiData);

    QThread *temperatureThread;
    QThread *pidHLTThread;
    QThread *pidBoilThread;
    RPiThreads *temperatureWorker;
    RPiThreads *pidHLTWorker;
    RPiThreads *pidBoilWorker;
};

#endif // CONNECTIONMANAGER_H
