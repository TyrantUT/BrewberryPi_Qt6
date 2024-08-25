#include "rpithreads.h"
#include "rpihelper.h"

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

    if (QT_DEBUG_ON) {
        qDebug() << "[DEBUG - MAX31865 Thread] MAX31865 Initialized.";
        qDebug() << "[DEBUG - MAX31865 Thread] MAX31865 Temperature Thread Starting";
    }

    // Initialize MAX31865 temperarture sensors
    MAX31865 MAX31865_hlt(MAX31865_HLT_GPIO);
    MAX31865 MAX31865_mash(MAX31865_MASH_GPIO);
    MAX31865 MAX31865_boil(MAX31865_BOIL_GPIO);
    MAX31865 MAX31865_mash2(MAX31865_MASH2_GPIO);

    while (!QThread::currentThread()->isInterruptionRequested()) {
        volatile float tempHLTTemp;
        volatile float tempMashTemp;
        volatile float tempBoilTemp;
        volatile float tempMash2Temp;

        // HLT
        MAX31865_hlt.MAX31865_readTemp();
        tempHLTTemp = MAX31865_hlt.MAX31865_tempF();

        if (QT_DEBUG_ON) {
            qDebug() << "[DEBUG - MAX31865 Thread] HLT Temp: " << tempHLTTemp;
        }

        // Handle HLT Mutex and set new temperature
        m_rpiData->rpiDataMutex.lock();
        m_rpiData->setCurrentTemp_HLT(tempHLTTemp);
        m_rpiData->rpiDataMutex.unlock();

        // MASH
        MAX31865_mash.MAX31865_readTemp();
        tempMashTemp = MAX31865_mash.MAX31865_tempF();

        if (QT_DEBUG_ON) {
            qDebug() << "[DEBUG - MAX31865 Thread] Mash Temp: " << tempMashTemp;
        }

        // Handle Mash Mutex and set new temperature
        m_rpiData->rpiDataMutex.lock();
        m_rpiData->setCurrentTemp_Mash(tempMashTemp);
        m_rpiData->rpiDataMutex.unlock();

        // BOIL
        MAX31865_boil.MAX31865_readTemp();
        tempBoilTemp = MAX31865_boil.MAX31865_tempF();

        if (QT_DEBUG_ON) {
            qDebug() << "[DEBUG - MAX31865 Thread] Boil Temp: " << tempBoilTemp;
        }

        // Handle Boil Mutex and set new temperature
        m_rpiData->rpiDataMutex.lock();
        m_rpiData->setCurrentTemp_Boil(tempBoilTemp);
        m_rpiData->rpiDataMutex.unlock();

        // MASH2
        MAX31865_mash2.MAX31865_readTemp();
        tempMash2Temp = MAX31865_mash2.MAX31865_tempF();

        if (QT_DEBUG_ON) {
            qDebug() << "[DEBUG - MAX31865 Thread] Mash2 Temp: " << tempMash2Temp;
        }

        // Handle Mash2 Mutex and set new temperature
        m_rpiData->rpiDataMutex.lock();
        m_rpiData->setCurrentTemp_Mash2(tempMash2Temp);
        m_rpiData->rpiDataMutex.unlock();

    }

    QThread::currentThread()->quit();
}
