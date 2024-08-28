#ifndef RPITHREADS_H
#define RPITHREADS_H

#include <QObject>
#include <QThread>
#include <QDebug>

#include "rpidata.h"

class RPiThreads : public QObject
{
    Q_OBJECT
public:
    explicit RPiThreads(RPiData *rpiData = nullptr, QObject *parent = nullptr);
    virtual ~RPiThreads();

public slots:
    void processTemps(void);
    void processPidHlt(void);
    void processPidBoil(void);
    //void processPwmHLT(void);
    //void processPwmBoil(void);

private:
    // Pointer to the shared RPiData instance
    RPiData *m_rpiData;

    // PID Initial values
    const float PID_Kp = 1.0;
    const float PID_Ki = 1.0;
    const float PID_Kd = 50.0;
    const float PID_sampleTime = .5;
    const float PID_minOutput = 0.0;
    const float PID_maxOutput = 100.0;
};

#endif // RPITHREADS_H
