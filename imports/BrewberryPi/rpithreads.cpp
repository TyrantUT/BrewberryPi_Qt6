#include "rpithreads.h"
#include "rpihelper.h"
#include "max31865.h"
#include "pidcontroller.h"

static float mapPWM(float input) {
    return 1.0 * OUTPUT_MIN + \
    ((OUTPUT_MAX - OUTPUT_MIN) / (INPUT_MAX - INPUT_MIN)) \
    * (input - INPUT_MIN);
}

RPiThreads::RPiThreads(RPiData *rpiData, QObject *parent) :
    QObject(parent),
    m_rpiData(rpiData)
{
}

RPiThreads::~RPiThreads() { }

void RPiThreads::processTemps() {

    // Delay thread by 500 msec to wait for full startup
    QThread::sleep(5);

    if (QT_DEBUG_ON) {
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

            if (QT_DEBUG_ON) {
                qDebug() << "[DEBUG - MAX31865 Thread] HLT Temp: " << tempHLTTemp;
            }
            // Handle HLT Mutex and set new temperature
            m_rpiData->setCurrentTemp_HLT(tempHLTTemp);
        }

        // MASH
        MAX31865_mash.MAX31865_readTemp();
        {
            float tempMashTemp = MAX31865_mash.MAX31865_tempF();

            if (QT_DEBUG_ON) {
                qDebug() << "[DEBUG - MAX31865 Thread] Mash Temp: " << tempMashTemp;
            }
            // Handle Mash Mutex and set new temperature
            m_rpiData->setCurrentTemp_Mash(tempMashTemp);
        }

        // BOIL
        MAX31865_boil.MAX31865_readTemp();
        {
            float tempBoilTemp = MAX31865_boil.MAX31865_tempF();

            if (QT_DEBUG_ON) {
                qDebug() << "[DEBUG - MAX31865 Thread] Boil Temp: " << tempBoilTemp;
            }
            // Handle Boil Mutex and set new temperature
            m_rpiData->setCurrentTemp_Boil(tempBoilTemp);
        }

        // MASH2
        MAX31865_mash2.MAX31865_readTemp();
        {
            float tempMash2Temp = MAX31865_mash2.MAX31865_tempF();

            if (QT_DEBUG_ON) {
                qDebug() << "[DEBUG - MAX31865 Thread] Mash2 Temp: " << tempMash2Temp;
            }
            // Handle Mash2 Mutex and set new temperature
            m_rpiData->setCurrentTemp_Mash2(tempMash2Temp);
        }
    }

    QThread::currentThread()->quit();
}

void RPiThreads::processPidHlt(void) {
    PIDController PIDController_HLT;

    // Initialize HLT PID
    PIDController_HLT.PIDInit(PID_Kp,
                              PID_Ki,
                              PID_Kd,
                              PID_sampleTime,
                              PID_minOutput,
                              PID_maxOutput,
                              PIDController_HLT.AUTOMATIC,
                              PIDController_HLT.DIRECT);

    if (QT_DEBUG_ON) {
        qDebug() << "[DEBUG - PID Controller Thread - HLT / MASH] PID Initalized.";
    }

    // Set PID Mode to AUTOMATIC by default
    PIDController_HLT.PIDModeSet(PIDController_HLT.AUTOMATIC);
    m_rpiData->setPwmDutyCycle_HLT(0.0);
    bool setpointManual_HLTLast = false;

    while(!QThread::currentThread()->isInterruptionRequested()) {
        bool elementOn_HLT = m_rpiData->getElementOn_HLT();
        bool setpointManual_HLT = m_rpiData->getSetpointManual_HLT();
        bool setpointHltOrMash = m_rpiData->getSetpointHltOrMash();

        // Check if the PID Mode has changed since the last
        if (setpointManual_HLT != setpointManual_HLTLast) {
            PIDController_HLT.PIDModeSet(
                setpointManual_HLT
                    ? PIDController_HLT.MANUAL
                    : PIDController_HLT.AUTOMATIC
                );
        }
        setpointManual_HLTLast = setpointManual_HLT;


        if (elementOn_HLT) {            
            if (!setpointManual_HLT) {
                // Automatic mode
                if (!setpointHltOrMash) {
                    // HLT Mode
                    float currentTemp_HLT = m_rpiData->getCurrentTemp_HLT();
                    float setpointTemp_HLT = m_rpiData->getSetpointTemp_HLT();

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
                    // HLT Mode
                    int setpointPercent_HLT = m_rpiData->getSetpointPercent_HLT();
                    m_rpiData->setPwmDutyCycle_HLT(setpointPercent_HLT);

                } else {
                    // Mash Mode
                    int setpointPercent_Mash = m_rpiData->getSetpointPercent_Mash();
                    m_rpiData->setPwmDutyCycle_HLT(setpointPercent_Mash);
                }
            }
        } else {
            // If the element is off, change the duty cycle to 0
            m_rpiData->setPwmDutyCycle_HLT(0.0);
        }

        QThread::msleep(500);
    }

    QThread::currentThread()->quit();
}

void RPiThreads::processPidBoil(void) {
    PIDController PIDController_Boil;

    // Initialize HLT PID
    PIDController_Boil.PIDInit(PID_Kp,
                              PID_Ki,
                              PID_Kd,
                              PID_sampleTime,
                              PID_minOutput,
                              PID_maxOutput,
                              PIDController_Boil.AUTOMATIC,
                              PIDController_Boil.DIRECT);

    if (QT_DEBUG_ON) {
        qDebug() << "[DEBUG - PID Controller Thread - BOil] PID Initalized.";
    }

    // Set PID Mode to AUTOMATIC by default
    PIDController_Boil.PIDModeSet(PIDController_Boil.AUTOMATIC);
    m_rpiData->setPwmDutyCycle_Boil(0.0);
    bool setpointManual_BoilLast = false;

    while(!QThread::currentThread()->isInterruptionRequested()) {
        bool elementOn_Boil = m_rpiData->getElementOn_Boil();
        bool setpointManual_Boil = m_rpiData->getSetpointManual_Boil();

        // Check if the PID Mode has changed since the last
        if (setpointManual_Boil != setpointManual_BoilLast) {
            PIDController_Boil.PIDModeSet(
                setpointManual_Boil
                    ? PIDController_Boil.MANUAL
                    : PIDController_Boil.AUTOMATIC
                );
        }
        setpointManual_BoilLast = setpointManual_Boil;

        if (elementOn_Boil) {
            if (!setpointManual_Boil) {
                // Automatic mode
                float currentTemp_Boil = m_rpiData->getCurrentTemp_Boil();
                float setpointTemp_Boil = m_rpiData->getSetpointTemp_Boil();

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
            // If the element is off, change the duty cycle to 0
            m_rpiData->setPwmDutyCycle_Boil(0.0);
        }

        QThread::msleep(500);
    }

    QThread::currentThread()->quit();
}
