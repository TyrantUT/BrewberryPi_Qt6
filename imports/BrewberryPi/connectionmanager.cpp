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
        if (value) {
            qDebug() << "HLT Element: On";
        } else {
            qDebug() << "HLT Element: Off";
        }

        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(ELEMENT_HLT, value);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::elementOn_BoilChanged, [RPiDataGlobal](bool value) {
        if (value) {
            qDebug() << "Boil Element: On";
        } else {
            qDebug() << "Boil Element: Off";
        }

        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(ELEMENT_BOIL, value);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::pumpOn_WortChanged, [&RPiDataGlobal](bool value) {
        if (value) {
            qDebug() << "Wort Pump: On";
        } else {
            qDebug() << "Wort Pump: Off";
        }

        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(PUMP_WORT, value);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::pumpOn_WaterChanged, [RPiDataGlobal](bool value) {
        if (value) {
            qDebug() << "Water Pump: On";
        } else {
            qDebug() << "Water Pump: Off";
        }
        QThreadPool::globalInstance()->start([value]() {
            gpioWriteValue(PUMP_WATER, value);
        });
    });

    QObject::connect(RPiDataGlobal, &RPiData::setpointHltOrMashChanged, [RPiDataGlobal](bool value) {
        if (value) {
            qDebug() << "Brewery Mode is now: HLT Mode";
        } else {
            qDebug() << "Brewery Mode is now: Mash Mode";
        }
    });

    QObject::connect(RPiDataGlobal, &RPiData::setpointManual_HLTChanged, [RPiDataGlobal](bool value) {
        if (value) {
            qDebug() << "HLT Element Mode set to: Manual";
        } else {
            qDebug() << "HLT Element Mode set to: Automatic";
        }
    });

    QObject::connect(RPiDataGlobal, &RPiData::setpointManual_BoilChanged, [RPiDataGlobal](bool value) {
        if (value) {
            qDebug() << "Boil Element Mode set to: Manual";
        } else {
            qDebug() << "Boil Element Mode set to: Automatic";
        }
    });
}
