#include "connectionmanager.h"
#include "rpihelper.h"
#include <QtWidgets/QApplication>

ConnectionManager::ConnectionManager(QObject *parent)
    : QObject(parent),
    temperatureThread(nullptr),
    pidHLTThread(nullptr),
    pidBoilThread(nullptr),
    temperatureWorker(nullptr),
    pidHLTWorker(nullptr),
    pidBoilWorker(nullptr)
{
}

ConnectionManager::~ConnectionManager()
{
    if (temperatureThread) {
        temperatureThread->requestInterruption();
        temperatureThread->quit();
        temperatureThread->wait();
    }
    if (pidHLTThread) {
        pidHLTThread->requestInterruption();
        pidHLTThread->quit();
        pidHLTThread->wait();
    }
    if (pidBoilThread) {
        pidBoilThread->requestInterruption();
        pidBoilThread->quit();
        pidBoilThread->wait();
    }
}

void ConnectionManager::setupConnections(QApplication *app, RPiData *rpiData)
{
    if (!rpiData) {
        qDebug() << "[ERROR - ConnectionManager] RPiData is null";
        return;
    }

    // Limit thread pool to prevent overload
    QThreadPool::globalInstance()->setMaxThreadCount(4);

    // Initialize thread workers without a parent to allow moveToThread
    temperatureWorker = new RPiThreads(rpiData, nullptr);
    pidHLTWorker = new RPiThreads(rpiData, nullptr);
    pidBoilWorker = new RPiThreads(rpiData, nullptr);

    // Initialize threads
    temperatureThread = new QThread(this);
    pidHLTThread = new QThread(this);
    pidBoilThread = new QThread(this);

    // Move workers to their respective threads
    temperatureWorker->moveToThread(temperatureThread);
    pidHLTWorker->moveToThread(pidHLTThread);
    pidBoilWorker->moveToThread(pidBoilThread);

    // Connect thread signals
    QObject::connect(temperatureThread, &QThread::started, temperatureWorker, &RPiThreads::processTemps);
    QObject::connect(temperatureThread, &QThread::finished, temperatureWorker, &QObject::deleteLater);
    QObject::connect(pidHLTThread, &QThread::started, pidHLTWorker, &RPiThreads::processPidHlt);
    QObject::connect(pidHLTThread, &QThread::finished, pidHLTWorker, &QObject::deleteLater);
    QObject::connect(pidBoilThread, &QThread::started, pidBoilWorker, &RPiThreads::processPidBoil);
    QObject::connect(pidBoilThread, &QThread::finished, pidBoilWorker, &QObject::deleteLater);

    // Connect application quit signals for thread cleanup
    QObject::connect(app, &QCoreApplication::aboutToQuit, this, [this]() {
        if (temperatureThread) {
            temperatureThread->requestInterruption();
            temperatureThread->quit();
            temperatureThread->wait();
        }
        if (pidHLTThread) {
            pidHLTThread->requestInterruption();
            pidHLTThread->quit();
            pidHLTThread->wait();
        }
        if (pidBoilThread) {
            pidBoilThread->requestInterruption();
            pidBoilThread->quit();
            pidBoilThread->wait();
        }
    }, Qt::DirectConnection);

    // Setup RPiData signal connections
    setupRPiDataConnections(rpiData);

    // Set thread priorities
    temperatureThread->start();
    pidHLTThread->start();
    pidBoilThread->start();

    temperatureThread->setPriority(QThread::TimeCriticalPriority);
    pidHLTThread->setPriority(QThread::HighPriority);
    pidBoilThread->setPriority(QThread::HighPriority);
}

void ConnectionManager::setupRPiDataConnections(RPiData *rpiData)
{
    // PWM Duty Cycle for HLT
    QObject::connect(rpiData, &RPiData::pwmDutyCycle_HLTChanged, [rpiData](float value) {
        qDebug() << "HLT PWM Value Changed: PWM Value is now" << value;
        const float pwmValue = mapPWM(value);
        QThreadPool::globalInstance()->start([pwmValue]() {
            pwmWriteValue(PWM_HLT, pwmValue);
        });
    });

    // PWM Duty Cycle for Boil
    QObject::connect(rpiData, &RPiData::pwmDutyCycle_BoilChanged, [rpiData](float value) {
        qDebug() << "Boil PWM Value Changed: PWM Value is now" << value;
        const float pwmValue = mapPWM(value);
        QThreadPool::globalInstance()->start([pwmValue]() {
            pwmWriteValue(PWM_BOIL, pwmValue);
        });
    });

    // HLT Element
    QObject::connect(rpiData, &RPiData::elementOn_HLTChanged, [rpiData](bool value) {
        qDebug() << "HLT Element:" << (value ? "On" : "Off");
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(ELEMENT_HLT, value);
        });
    });

    // Boil Element
    QObject::connect(rpiData, &RPiData::elementOn_BoilChanged, [rpiData](bool value) {
        qDebug() << "Boil Element:" << (value ? "On" : "Off");
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(ELEMENT_BOIL, value);
        });
    });

    // Wort Pump
    QObject::connect(rpiData, &RPiData::pumpOn_WortChanged, [rpiData](bool value) {
        qDebug() << "Wort Pump:" << (value ? "On" : "Off");
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(PUMP_WORT, value);
        });
    });

    // Water Pump
    QObject::connect(rpiData, &RPiData::pumpOn_WaterChanged, [rpiData](bool value) {
        qDebug() << "Water Pump:" << (value ? "On" : "Off");
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(PUMP_WATER, value);
        });
    });

    // HLT or Mash Setpoint
    QObject::connect(rpiData, &RPiData::setpointHltOrMashChanged, [rpiData](bool value) {
        qDebug() << "Brewery Mode is now:" << (value ? "HLT Mode" : "Mash Mode");
    });

    // HLT Manual Setpoint
    QObject::connect(rpiData, &RPiData::setpointManual_HLTChanged, [rpiData](bool value) {
        qDebug() << "HLT Element Mode set to:" << (value ? "Manual" : "Automatic");
    });

    // Boil Manual Setpoint
    QObject::connect(rpiData, &RPiData::setpointManual_BoilChanged, [rpiData](bool value) {
        qDebug() << "Boil Element Mode set to:" << (value ? "Manual" : "Automatic");
    });
}
