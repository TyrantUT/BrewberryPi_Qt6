#ifndef MAX31865_H
#define MAX31865_H

#include <QReadWriteLock>
#include <QThread>
#include <deque>

struct max31865 {
    qint8 spi_cs;
    float tempC;
    float tempF;
    float lastTempC;
    quint8 fault;
};

class MAX31865 : public QObject {
    Q_OBJECT
public:
    explicit MAX31865(qint8 spi_cs);
    virtual ~MAX31865();

    void MAX31865_readTemp(void);
    float MAX31865_tempC(void);
    float MAX31865_tempF(void);
    quint8 MAX31865_fault(void);
    void MAX31865_writeRegister(quint8 regNum, quint8 data);
    void MAX31865_readRegister(quint8 regNumStart, quint8 count, quint8 buffer[]);
    void MAX31865_calculateTempC(quint16 rtd_response);
    void MAX31865_calculateTempF(void);
    void MAX31865_compareFault(void);
    quint8 MAX31865_buildConfigByte(void);

private:
    float MAX31865_normalizeTemp(float temp);

private:
    max31865 MAX31865_handle;
    QReadWriteLock temperatureLocker;
    std::deque<float> tempBuffer;
    const int bufferSize = 16;
    static constexpr float PT100_RESISTANCE = 100.0f;
    static constexpr float MAX31865_RTD_NOMINAL = 100.0f;
    static constexpr float MAX31865_RTD_RESISTOR = 402.0f;
    static constexpr float RTD_A = 3.9083e-3;
    static constexpr float RTD_B = -5.775e-7;
    static constexpr quint8 MAX31865_CONFIG_REG = 0x00;
    static constexpr quint8 MAX31865_CONFIG_WRITE = 0x80;
    static constexpr quint8 MAX31865_CONFIG_BIAS = 0x80;
    static constexpr quint8 MAX31865_CONFIG_MODEAUTO = 0x40;
    static constexpr quint8 MAX31865_CONFIG_1SHOT = 0x20;
    static constexpr quint8 MAX31865_CONFIG_3WIRE = 0x10;
    static constexpr quint8 MAX31865_CONFIG_FAULTCYCLE = 0x0C;
    static constexpr quint8 MAX31865_CONFIG_FAULTSTAT = 0x02;
    static constexpr quint8 MAX31865_CONFIG_FILT60HZ = 0x01;
    static constexpr quint8 MAX31865_FAULT_NONE = 0x00;
    static constexpr quint8 MAX31865_FAULT_HIGHTHRESH = 0x80;
    static constexpr quint8 MAX31865_FAULT_LOWTHRESH = 0x40;
    static constexpr quint8 MAX31865_FAULT_REFINLOW = 0x20;
    static constexpr quint8 MAX31865_FAULT_REFINHIGH = 0x10;
    static constexpr quint8 MAX31865_FAULT_RTDINLOW = 0x08;
    static constexpr quint8 MAX31865_FAULT_OVUV = 0x04;
};

#endif // MAX31865_H
