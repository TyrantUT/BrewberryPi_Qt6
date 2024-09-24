/**
  ******************************************************************************
  * File Name          : max31865.h
  * Description        : Header File for MAX31865 temperature sensor class
  ******************************************************************************
  * @attention
**/

#ifndef MAX31865_H
#define MAX31865_H

#include <QReadWriteLock>
#include <QReadLocker>
#include <QWriteLocker>
#include <QList>

#define MAX31865_CONFIG_WRITE       0x80
#define MAX31865_CONFIG_REG         0x00
#define MAX31865_CONFIG_BIAS        0x80
#define MAX31865_CONFIG_MODEAUTO    0x40
#define MAX31865_CONFIG_MODEOFF     0x00
#define MAX31865_CONFIG_1SHOT       0x20
#define MAX31865_CONFIG_3WIRE       0x10
#define MAX31865_CONFIG_24WIRE      0x00
#define MAX31865_CONFIG_FAULTSTAT   0x02
#define MAX31865_CONFIG_FILT50HZ    0x01
#define MAX31865_CONFIG_FILT60HZ    0x00
#define MAX31865_CONFIG_FAULTCYCLE  0x0C

#define MAX31865_RTDMSB_REG         0x01
#define MAX31865_RTDLSB_REG         0x02
#define MAX31865_HFAULTMSB_REG      0x03
#define MAX31865_HFAULTLSB_REG      0x04
#define MAX31865_LFAULTMSB_REG      0x05
#define MAX31865_LFAULTLSB_REG      0x06
#define MAX31865_FAULTSTAT_REG      0x07

#define MAX31865_FAULT_HIGHTHRESH   0x80
#define MAX31865_FAULT_LOWTHRESH    0x40
#define MAX31865_FAULT_REFINLOW     0x20
#define MAX31865_FAULT_REFINHIGH    0x10
#define MAX31865_FAULT_RTDINLOW     0x08
#define MAX31865_FAULT_OVUV         0x04
#define MAX31865_FAULT_NONE         0x00

#define RTD_A                       3.9083e-3
#define RTD_B                       -5.775e-7

#define PT100_RESISTANCE            32768.0
#define MAX31865_RTD_NOMINAL        100.0f
#define MAX31865_RTD_RESISTOR       402.0f
#define MAX31865_EFFECTIVE_FACTOR   0.1f

typedef struct MAX31865_handle {
    qint8 spi_cs = 0;
    float tempC = 0.0f;
    float tempF = 0.0f;
    float lastTempC = 0.0f;
    quint8 fault = 0;
} handle_t;

class MAX31865 {
public:
    MAX31865(qint8 spi_cs);
    virtual ~MAX31865();

    void MAX31865_init(void);
    void MAX31865_readTemp(void);

    float MAX31865_tempC() {QReadLocker locker(&temperatureLocker); return MAX31865_handle.tempC;}
    float MAX31865_tempF() {QReadLocker locker(&temperatureLocker); return MAX31865_handle.tempF;}
    quint8 MAX31865_fault() {QReadLocker locker(&temperatureLocker); return MAX31865_handle.fault;}

private:
    mutable QReadWriteLock temperatureLocker;
    QList<float> tempBuffer;
    int bufferSize = 10;

    struct MAX31865_handle MAX31865_handle;

    float MAX31865_lastTempC() {QReadLocker locker(&temperatureLocker); return MAX31865_handle.lastTempC;}
    quint8 MAX31865_buildConfigByte(void);
    void MAX31865_writeRegister(quint8 regNum, quint8 data);
    void MAX31865_readRegister(quint8 regNumStart, quint8 count, quint8 buffer[]);
    void MAX31865_calculateTempC(quint8 rtd_response);
    void MAX31865_calculateTempF(void);
    void MAX31865_compareFault(void);
    float MAX31865_normalizeTemp(float temp);
};
#endif // MAX31865_H
