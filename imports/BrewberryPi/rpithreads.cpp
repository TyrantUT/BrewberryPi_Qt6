#include "rpithreads.h"
#include "rpihelper.h"
#include "max31865.h"
#include "pidcontroller.h"

RPiThreads::RPiThreads(RPiData *rpiData, QObject *parent)
    : QObject(parent), m_rpiData(rpiData)
{
}

RPiThreads::~RPiThreads() { }

void RPiThreads::processTemps() {
    if (!m_rpiData) {
        qDebug() << "[ERROR - MAX31865 Thread] RPiData is null";
        QThread::currentThread()->quit();
        return;
    }

    QThread::sleep(5); // Delay thread by 5000ms to wait for full startup

    if (QT_THREADS_MAX) {
        qDebug() << "[DEBUG - MAX31865 Thread] MAX31865 Initialized.";
        qDebug() << "[DEBUG - MAX31865 Thread] MAX31865 Temperature Thread Starting";
    }

    // Initialize MAX31865 temperature sensors
    MAX31865 MAX31865_hlt(MAX31865_HLT_GPIO);
    MAX31865 MAX31865_mash(MAX31865_MASH_GPIO);
    MAX31865 MAX31865_boil(MAX31865_BOIL_GPIO);
    MAX31865 MAX31865_mash2(MAX31865_MASH2_GPIO);

    while (!QThread::currentThread()->isInterruptionRequested()) {
        // HLT
        MAX31865_hlt.MAX31865_readTemp();
        {
            float tempHLTTemp = MAX31865_hlt.MAX31865_tempF();
            if (QT_THREADS_MAX) {
                qDebug() << "[DEBUG - MAX31865 Thread] HLT Temp: " << tempHLTTemp;
            }
            m_rpiData->setCurrentTemp_HLT(tempHLTTemp); // Thread-safe via RPiData's mutex
        }

        // MASH
        MAX31865_mash.MAX31865_readTemp();
        {
            float tempMashTemp = MAX31865_mash.MAX31865_tempF();
            if (QT_THREADS_MAX) {
                qDebug() << "[DEBUG - MAX31865 Thread] Mash Temp: " << tempMashTemp;
            }
            m_rpiData->setCurrentTemp_Mash(tempMashTemp); // Thread-safe via RPiData's mutex
        }

        // BOIL
        MAX31865_boil.MAX31865_readTemp();
        {
            float tempBoilTemp = MAX31865_boil.MAX31865_tempF();
            if (QT_THREADS_MAX) {
                qDebug() << "[DEBUG - MAX31865 Thread] Boil Temp: " << tempBoilTemp;
            }
            m_rpiData->setCurrentTemp_Boil(tempBoilTemp); // Thread-safe via RPiData's mutex
        }

        // MASH2
        MAX31865_mash2.MAX31865_readTemp();
        {
            float tempMash2Temp = MAX31865_mash2.MAX31865_tempF();
            if (QT_THREADS_MAX) {
                qDebug() << "[DEBUG - MAX31865 Thread] Mash2 Temp: " << tempMash2Temp;
            }
            m_rpiData->setCurrentTemp_Mash2(tempMash2Temp); // Thread-safe via RPiData's mutex
        }

        QThread::msleep(5000); // Delay for 1000msec second to slow down temperature reads
    }

    QThread::currentThread()->quit();
}

void RPiThreads::processPidHlt() {
    if (!m_rpiData) {
        qDebug() << "[ERROR - PID Controller Thread - HLT] RPiData is null";
        QThread::currentThread()->quit();
        return;
    }

    PIDController PIDController_HLT;
    PIDController_HLT.PIDInit(PID_Kp, PID_Ki, PID_Kd, PID_sampleTime, PID_minOutput, PID_maxOutput,
                              PIDController_HLT.AUTOMATIC, PIDController_HLT.DIRECT);

    if (QT_THREADS_PID_HLT) {
        qDebug() << "[DEBUG - PID Controller Thread - HLT / MASH] PID Initialized.";
    }

    PIDController_HLT.PIDModeSet(PIDController_HLT.AUTOMATIC);
    m_rpiData->setPwmDutyCycle_HLT(0.0);
    bool setpointManual_HLTLast = false;

    while (!QThread::currentThread()->isInterruptionRequested()) {
        bool elementOn_HLT = m_rpiData->getElementOn_HLT();
        bool setpointManual_HLT = m_rpiData->getSetpointManual_HLT();
        bool setpointHltOrMash = m_rpiData->getSetpointHltOrMash();

        if (setpointManual_HLT != setpointManual_HLTLast) {
            PIDController_HLT.PIDModeSet(setpointManual_HLT ? PIDController_HLT.MANUAL : PIDController_HLT.AUTOMATIC);
        }
        setpointManual_HLTLast = setpointManual_HLT;

        if (elementOn_HLT) {
            if (!setpointManual_HLT) {
                // Automatic mode
                if (!setpointHltOrMash) {
                    // HLT Mode
                    float currentTemp_HLT = m_rpiData->getCurrentTemp_HLT();
                    float setpointTemp_HLT = m_rpiData->getSetpointTemp_HLT();
                    if (setpointTemp_HLT == 0.0) {
                        m_rpiData->setPwmDutyCycle_HLT(0.0);
                        continue;
                    }
                    PIDController_HLT.PIDInputSet(currentTemp_HLT);
                    PIDController_HLT.PIDSetpointSet(setpointTemp_HLT);
                    PIDController_HLT.PIDCompute();
                    float pidOutput = PIDController_HLT.PIDOutputGet();
                    float pidConstrain = CONSTRAIN(pidOutput, PID_minOutput, PID_maxOutput);
                    m_rpiData->setPwmDutyCycle_HLT(pidConstrain);
                } else {
                    // Mash Mode
                    float currentTemp_Mash = m_rpiData->getCurrentTemp_Mash();
                    float setpointTemp_Mash = m_rpiData->getSetpointTemp_Mash();
                    PIDController_HLT.PIDInputSet(currentTemp_Mash);
                    PIDController_HLT.PIDSetpointSet(setpointTemp_Mash);
                    PIDController_HLT.PIDCompute();
                    float pidOutput = PIDController_HLT.PIDOutputGet();
                    float pidConstrain = CONSTRAIN(pidOutput, PID_minOutput, PID_maxOutput);
                    m_rpiData->setPwmDutyCycle_HLT(pidConstrain);
                }
            } else {
                // Manual mode
                if (!setpointHltOrMash) {
                    int setpointPercent_HLT = m_rpiData->getSetpointPercent_HLT();
                    m_rpiData->setPwmDutyCycle_HLT(setpointPercent_HLT);
                } else {
                    int setpointPercent_Mash = m_rpiData->getSetpointPercent_Mash();
                    m_rpiData->setPwmDutyCycle_HLT(setpointPercent_Mash);
                }
            }
        } else {
            m_rpiData->setPwmDutyCycle_HLT(0.0);
        }

        QThread::msleep(1000);
    }

    QThread::currentThread()->quit();
}

void RPiThreads::processPidBoil() {
    if (!m_rpiData) {
        qDebug() << "[ERROR - PID Controller Thread - Boil] RPiData is null";
        QThread::currentThread()->quit();
        return;
    }

    PIDController PIDController_Boil;
    PIDController_Boil.PIDInit(PID_Kp, PID_Ki, PID_Kd, PID_sampleTime, PID_minOutput, PID_maxOutput,
                               PIDController_Boil.AUTOMATIC, PIDController_Boil.DIRECT);

    if (QT_THREADS_PID_BOIL) {
        qDebug() << "[DEBUG - PID Controller Thread - Boil] PID Initialized.";
    }

    PIDController_Boil.PIDModeSet(PIDController_Boil.AUTOMATIC);
    m_rpiData->setPwmDutyCycle_Boil(0.0);
    bool setpointManual_BoilLast = false;

    while (!QThread::currentThread()->isInterruptionRequested()) {
        bool elementOn_Boil = m_rpiData->getElementOn_Boil();
        bool setpointManual_Boil = m_rpiData->getSetpointManual_Boil();

        if (setpointManual_Boil != setpointManual_BoilLast) {
            PIDController_Boil.PIDModeSet(setpointManual_Boil ? PIDController_Boil.MANUAL : PIDController_Boil.AUTOMATIC);
        }
        setpointManual_BoilLast = setpointManual_Boil;

        if (elementOn_Boil) {
            if (!setpointManual_Boil) {
                float currentTemp_Boil = m_rpiData->getCurrentTemp_Boil();
                float setpointTemp_Boil = m_rpiData->getSetpointTemp_Boil();
                if (setpointTemp_Boil == 0.0) {
                    m_rpiData->setPwmDutyCycle_Boil(0.0);
                    continue;
                }
                PIDController_Boil.PIDInputSet(currentTemp_Boil);
                PIDController_Boil.PIDSetpointSet(setpointTemp_Boil);
                PIDController_Boil.PIDCompute();
                float pidOutput = PIDController_Boil.PIDOutputGet();
                float pidConstrain = CONSTRAIN(pidOutput, PID_minOutput, PID_maxOutput);
                m_rpiData->setPwmDutyCycle_Boil(pidConstrain);
            } else {
                int setpointPercent_Boil = m_rpiData->getSetpointPercent_Boil();
                m_rpiData->setPwmDutyCycle_Boil(setpointPercent_Boil);
            }
        } else {
            m_rpiData->setPwmDutyCycle_Boil(0.0);
        }

        QThread::msleep(1000);
    }

    QThread::currentThread()->quit();
}
