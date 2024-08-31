#include "connectionmanager.h"

ConnectionManager::ConnectionManager(QObject *parent)
    : QObject(parent)
{
}

void ConnectionManager::setupConnections(RPiData *RPiDataGlobal) {
    QObject::connect(RPiDataGlobal, &RPiData::pwmDutyCycle_HLTChanged, [RPiDataGlobal](float value) {
        qDebug() << "HLT PWM Value Changed: PWM Value is now" << value;
        if (RPiDataGlobal->getPwmDutyCycle_HLT() != value) {
            const float pwmValue = mapPWM(value);
            pwmWriteValue(PWM_BOIL, pwmValue);
        }
    });

    QObject::connect(RPiDataGlobal, &RPiData::pwmDutyCycle_BoilChanged, [RPiDataGlobal](float value) {
        qDebug() << "Boil PWM Value Changed: PWM Value is now" << value;
        if (RPiDataGlobal->getPwmDutyCycle_Boil() != value) {
            const float pwmValue = mapPWM(value);
            pwmWriteValue(PWM_BOIL, pwmValue);
        }
    });

    QObject::connect(RPiDataGlobal, &RPiData::elementOn_HLTChanged, [RPiDataGlobal](bool value) {
        qDebug() << "HLT Element On Value Changed: Value is now" << value;
        if (RPiDataGlobal->getElementOn_HLT() != value) {
            gpioWriteValue(ELEMENT_HLT, value);
        }
    });

    QObject::connect(RPiDataGlobal, &RPiData::elementOn_BoilChanged, [RPiDataGlobal](bool value) {
        qDebug() << "Boil Element On Value Changed: Value is now" << value;
        if (RPiDataGlobal->getElementOn_Boil() != value) {
            gpioWriteValue(ELEMENT_BOIL, value);
        }
    });

    QObject::connect(RPiDataGlobal, &RPiData::pumpOn_WortChanged, [&RPiDataGlobal](bool value) {
        qDebug() << "Wort Pump Value Changed: Value is now" << value;
        if (RPiDataGlobal->getPumpOn_Wort() != value) {
            QThreadPool::globalInstance()->start([value]() {
                gpioWriteValue(PUMP_WORT, value);
            });
        }
    });

    QObject::connect(RPiDataGlobal, &RPiData::pumpOn_WaterChanged, [RPiDataGlobal](bool value) {
        qDebug() << "Water Pump Value Changed: Value is now" << value;
        if (RPiDataGlobal->getPumpOn_Water() != value) {
            gpioWriteValue(PUMP_WATER, value);
        }
    });
}
