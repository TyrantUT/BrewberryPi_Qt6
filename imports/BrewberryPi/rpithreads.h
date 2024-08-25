#ifndef RPITHREADS_H
#define RPITHREADS_H

#include <QObject>
#include <thread>
#include <QThread>
#include <QDebug>

#include "rpidata.h"
#include "max31865.h"
#include "pidcontroller.h"

class RPiThreads : public QObject
{
    Q_OBJECT
public:
    explicit RPiThreads(RPiData *rpiData = nullptr, QObject *parent = nullptr);
    virtual ~RPiThreads();

public slots:
    void processTemps(void);
    //void processPidHLT(void);
    //void processPidBoil(void);
    //void processPwmHLT(void);
    //void processPwmBoil(void);

private:
    // Pointer to the shared RPiData instance
    RPiData *m_rpiData;

    // PID Initial values
    float PID_Kp = 1;
    float PID_Ki = 1;
    float PID_Kd = 50;
    float PID_minOutput = 0;
    float PID_maxOutput = 100;
    float PID_sampleTime = .5;

    // PWM Duty Cycle Values
    volatile float dutyCycle_HLT = 0.0;
    volatile float dutyCycle_Boil = 0.0;
    volatile float dutyCycleLast_HLT = 0.0;
    volatile float dutyCycleLast_Boil = 0.0;

    // Local Variables
    // Current Temperature
    float currentTemp_HLT = 0.0f;
    float currentTemp_Mash = 0.0f;
    float currentTemp_Boil = 0.0f;

    // Setpoint Values;
    float setpointTemp_HLT = 0.0f;
    float setpointTemp_Mash = 0.0f;
    float setpointTemp_Boil = 0.0f;
    int setpointPercent_HLT = 0;
    int setpointPercent_Mash = 0;
    int setpointPercent_Boil = 0;

    bool setpointManual_HLT = false;
    bool setpointManual_Mash = false;
    bool setpointManual_Boil = false;

    // Element Control
    bool elementOn_HLT = false;
    bool elementOn_Boil = false;

    // Pump Control;
    bool pumpOn_Wort = false;
    bool pumpOn_Water = false;

signals:
    //void temperatureValueChanged(void);
    //void pwmHLTValueChanged(void);
    //void pwmBoilValueChanged(void);
    //void pidHLTValueChanged(void);
    //void pidBoilValueChanged(void);
};

#endif // RPITHREADS_H
