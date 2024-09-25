#include "connectionmanager.h"
#include "rpihelper.h"

ConnectionManager::ConnectionManager(QObject *parent)
    : QObject(parent)
{
}

void ConnectionManager::setupConnections(RPiData *RPiDataGlobal) {
    QObject::connect(RPiDataGlobal, &RPiData::pwmDutyCycle_HLTChanged, [RPiDataGlobal](float value) {
        qDebug() << "HLT PWM Value Changed: PWM Value is now" << value;
        const float pwmValue = mapPWM(value);
        QThreadPool::globalInstance()->start([pwmValue]() {
            pwmWriteValue(PWM_HLT, pwmValue);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::pwmDutyCycle_BoilChanged, [RPiDataGlobal](float value) {
        qDebug() << "Boil PWM Value Changed: PWM Value is now" << value;
        const float pwmValue = mapPWM(value);
        QThreadPool::globalInstance()->start([pwmValue]() {
            pwmWriteValue(PWM_BOIL, pwmValue);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::elementOn_HLTChanged, [RPiDataGlobal](bool value) {
        qDebug() << "HLT Element On Value Changed: Value is now" << value;     
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(ELEMENT_HLT, !value);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::elementOn_BoilChanged, [RPiDataGlobal](bool value) {
        qDebug() << "Boil Element On Value Changed: Value is now" << value; 
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(ELEMENT_BOIL, !value);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::pumpOn_WortChanged, [&RPiDataGlobal](bool value) {
        qDebug() << "Wort Pump Value Changed: Value is now" << value;
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(PUMP_WORT, value);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::pumpOn_WaterChanged, [RPiDataGlobal](bool value) {
        qDebug() << "Water Pump Value Changed: Value is now" << value;
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(PUMP_WATER, value);
        });
    });
}
