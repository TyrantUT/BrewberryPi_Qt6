#include "max31865.h"
#include "rpihelper.h"
#include <QThread>
#include <QDebug>
#include <cmath>
#include <numeric>
#include <QString>

MAX31865::MAX31865(qint8 spi_cs) {
    QWriteLocker locker(&temperatureLocker);
    MAX31865_handle.spi_cs = spi_cs;
    MAX31865_handle.tempC = 0.0f;
    MAX31865_handle.tempF = 32.0f;
    MAX31865_handle.lastTempC = 0.0f;
    MAX31865_handle.fault = 0;
    locker.unlock();

    gpioSetMode(spi_cs, PI_OUTPUT);
    gpioWrite(spi_cs, PI_HIGH);

    quint8 dataByte = MAX31865_buildConfigByte();
    MAX31865_writeRegister(0, dataByte);

    // Perform initial reads to stabilize sensor
    for (int i = 0; i < 10; ++i) {
        MAX31865_readTemp();
        QThread::msleep(100);
    }
}

MAX31865::~MAX31865() {
    gpioTerminate();
}

quint8 MAX31865::MAX31865_buildConfigByte(void) {
    quint8 dataByte = MAX31865_CONFIG_REG;

    dataByte |= MAX31865_CONFIG_BIAS;
    dataByte |= MAX31865_CONFIG_MODEAUTO;
    dataByte &= ~MAX31865_CONFIG_1SHOT;
    dataByte |= MAX31865_CONFIG_3WIRE;
    dataByte &= ~MAX31865_CONFIG_FAULTCYCLE;
    dataByte |= MAX31865_CONFIG_FAULTSTAT;
    dataByte |= MAX31865_CONFIG_FILT60HZ;

    return dataByte;
}

void MAX31865::MAX31865_readTemp(void) {
    quint8 outBuf[8];

    MAX31865_readRegister(0, 8, outBuf);

    quint8 rtd_msb = outBuf[1];
    quint8 rtd_lsb = outBuf[2];

    quint16 rtd_response = ((rtd_msb << 8) | rtd_lsb) >> 1;

    {
        QWriteLocker locker(&temperatureLocker);
        MAX31865_handle.fault = outBuf[7];
    }

    if (MAX31865_fault() != MAX31865_FAULT_NONE) {
        qDebug() << "[MAX31865] Fault detected: " << MAX31865_fault();
        MAX31865_compareFault();
        quint8 config = MAX31865_buildConfigByte() | MAX31865_CONFIG_FAULTSTAT;
        MAX31865_writeRegister(MAX31865_CONFIG_REG, config);
        return;
    }

    MAX31865_calculateTempC(rtd_response);
    MAX31865_calculateTempF();

    QThread::msleep(100);
}

void MAX31865::MAX31865_writeRegister(quint8 regNum, quint8 data) {
    gpioWrite(MAX31865_handle.spi_cs, PI_LOW);
    quint8 address = MAX31865_CONFIG_WRITE | regNum;
    spiSendBytes(address);
    spiSendBytes(data);
    gpioWrite(MAX31865_handle.spi_cs, PI_HIGH);
}

void MAX31865::MAX31865_readRegister(quint8 regNumStart, quint8 count, quint8 buffer[]) {
    gpioWrite(MAX31865_handle.spi_cs, PI_LOW);

    spiSendBytes(regNumStart);

    for (int i = 0; i < count; i++) {
        buffer[i] = spiReceiveBytes();
    }

    gpioWrite(MAX31865_handle.spi_cs, PI_HIGH);
}

void MAX31865::MAX31865_calculateTempC(quint16 rtd_response) {
    float Z1, Z2, Z3, Z4, Rt, temp;

    Rt = rtd_response;
    Rt /= PT100_RESISTANCE;
    Rt *= MAX31865_RTD_RESISTOR;
    Z1 = -RTD_A;
    Z2 = RTD_A * RTD_A - (4 * RTD_B);
    Z3 = (4 * RTD_B) / MAX31865_RTD_NOMINAL;
    Z4 = 2 * RTD_B;
    temp = Z2 + (Z3 * Rt);
    temp = (std::sqrt(temp) + Z1) / Z4;

    temp = MAX31865_normalizeTemp(temp);

    QWriteLocker locker(&temperatureLocker);
    MAX31865_handle.tempC = temp;
    MAX31865_handle.lastTempC = temp;
}

void MAX31865::MAX31865_calculateTempF(void) {
    QWriteLocker locker(&temperatureLocker);
    MAX31865_handle.tempF = (MAX31865_handle.tempC * 9.0f / 5.0f) + 32.0f;
}

void MAX31865::MAX31865_compareFault(void) {
    quint8 fault = MAX31865_fault();
    if (fault & MAX31865_FAULT_HIGHTHRESH) {
        qDebug() << "[MAX31865 Fault] RTD High Threshold";
    }
    if (fault & MAX31865_FAULT_LOWTHRESH) {
        qDebug() << "[MAX31865 Fault] RTD Low Threshold";
    }
    if (fault & MAX31865_FAULT_REFINLOW) {
        qDebug() << "[MAX31865 Fault] REFIN- > 0.85 x Bias";
    }
    if (fault & MAX31865_FAULT_REFINHIGH) {
        qDebug() << "[MAX31865 Fault] REFIN- < 0.85 x Bias - FORCE- open";
    }
    if (fault & MAX31865_FAULT_RTDINLOW) {
        qDebug() << "[MAX31865 Fault] RTDIN- < 0.85 x Bias - FORCE- open";
    }
    if (fault & MAX31865_FAULT_OVUV) {
        qDebug() << "[MAX31865 Fault] Under/Over voltage";
    }
}

float MAX31865::MAX31865_normalizeTemp(float temp) {
    if (temp < 0) {
        return -17.77777777777778f;
    }

    if (!tempBuffer.empty()) {
        float lastBufferedTemp = tempBuffer.back();
        if (std::abs(temp - lastBufferedTemp) > 20.0f) {
            qDebug() << "[MAX31865] Anomaly detected: temp=" << temp
                     << "last=" << lastBufferedTemp << "diff=" << std::abs(temp - lastBufferedTemp);
            float sum = std::accumulate(tempBuffer.begin(), tempBuffer.end(), 0.0f);
            return sum / tempBuffer.size();
        }
    }

    tempBuffer.push_back(temp);
    if (tempBuffer.size() > bufferSize) {
        tempBuffer.pop_front();
    }

    float sum = std::accumulate(tempBuffer.begin(), tempBuffer.end(), 0.0f);
    float average = sum / tempBuffer.size();

    return average;
}

float MAX31865::MAX31865_tempF(void) {
    QReadLocker locker(&temperatureLocker);
    return MAX31865_handle.tempF;
}

quint8 MAX31865::MAX31865_fault(void) {
    QReadLocker locker(&temperatureLocker);
    return MAX31865_handle.fault;
}
