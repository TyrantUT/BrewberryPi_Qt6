/**
  ******************************************************************************
  * File Name          : max31865.cpp
  * Description        : MAX31865 temperature sensor class
  ******************************************************************************
  * @attention
**/

#include "max31865.h"
#include "pigpio.h"
#include "rpihelper.h"
#include <QThread>
#include <QDebug>
#include <cmath>

MAX31865::MAX31865(qint8 spi_cs) {
    // Set SPI Chip Select pin
    {
        QWriteLocker locker(&temperatureLocker);
        MAX31865_handle.spi_cs = spi_cs;
    }

    gpioSetMode(spi_cs, PI_OUTPUT);
    gpioWrite(spi_cs, PI_HIGH);

    quint8 dataByte = MAX31865_buildConfigByte();
    MAX31865_writeRegister(0, dataByte);

    QThread::msleep(100);
}

quint8 MAX31865::MAX31865_buildConfigByte(void) {
    quint8 dataByte = MAX31865_CONFIG_REG;

    dataByte |= MAX31865_CONFIG_BIAS; // Enable Bias
    dataByte |= MAX31865_CONFIG_MODEAUTO; // Enable Auto Convert
    dataByte &= ~MAX31865_CONFIG_1SHOT; // Disable 1 Shot
    dataByte |= MAX31865_CONFIG_3WIRE; // Configure 3 wire PT100
    dataByte &= ~MAX31865_CONFIG_FAULTCYCLE; // Disable fault cycle
    dataByte |= MAX31865_CONFIG_FAULTSTAT; // Clear fault bit
    dataByte |= MAX31865_CONFIG_FILT60HZ; // Enable 60Hz

    return dataByte;
}

void MAX31865::MAX31865_readTemp(void) {

    quint8 outBuf[8];
    //quint8 conf_reg;

    quint8 rtd_msb, rtd_lsb;
    //quint8 hft_msb, hft_lsb;
    //quint8 lft_msb, lft_lsb;

    // Read all registers
    MAX31865_readRegister(0, 8, outBuf);

    //conf_reg = outBuf[0];
    //printf("Configuration Register: %02x\n", conf_reg);

    rtd_msb = outBuf[1];
    rtd_lsb = outBuf[2];

    // Combine two bytes to one for RTD Response
    quint16 rtd_response = (( rtd_msb << 8 ) | rtd_lsb ) >> 1;
    //printf("RTD Code: %i\n", rtd_ADC_Code);

    // Read Fault from buffer
    {
        QWriteLocker locker(&temperatureLocker);
        MAX31865_handle.fault = outBuf[7];
    }

    // Calculate temperature from rtd_response
    MAX31865_calculateTempC(rtd_response);
    MAX31865_calculateTempF();

    // We need to allow for at least 100msec for each conversion
    // Note: This will impact the Temp Thread overall wait time since all 4 are within 1 thread
    //QThread::msleep(100);
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

    // Calculate temperature in C

    Rt = rtd_response;
    Rt /= PT100_RESISTANCE;
    Rt *= MAX31865_RTD_RESISTOR;
    Z1 = -RTD_A;
    Z2 = RTD_A * RTD_A - (4 * RTD_B);
    Z3 = (4 * RTD_B) / MAX31865_RTD_NOMINAL;
    Z4 = 2 * RTD_B;
    temp = Z2 + (Z3 * Rt);
    temp = (sqrt(temp) + Z1) / Z4;

    printf("Temp in C: %f\n", temp);

    temp = MAX31865_normalizeTemp(temp);
    {
        QWriteLocker locker(&temperatureLocker);
        MAX31865_handle.tempC = temp;
        MAX31865_handle.lastTempC = temp;
    }
}

void MAX31865::MAX31865_calculateTempF(void) {
    QWriteLocker locker(&temperatureLocker);
    MAX31865_handle.tempF = (MAX31865_handle.tempC * 9.0f / 5.0f) + 32.0f;
}

void MAX31865::MAX31865_compareFault(void) {

/*
    # bit 7: RTD High Threshold / cable fault open
        MAX31865_FAULT_HIGHTHRESH
    # bit 6: RTD Low Threshold / cable fault short
        MAX31865_FAULT_LOWTHRESH
    # bit 5: REFIN- > 0.85 x VBias -> must be requested
        MAX31865_FAULT_REFINLOW
    # bit 4: REFIN- < 0.85 x VBias (FORCE- open) -> must be requested
        MAX31865_FAULT_REFINHIGH
    # bit 3: RTDIN- < 0.85 x VBias (FORCE- open) -> must be requested
        MAX31865_FAULT_RTDINLOW
    # bit 2: Overvoltage / undervoltage fault -
        MAX31865_FAULT_OVUV
    # bit 1: [Nothing]
    # bit 0: No Fault
        MAX31865_FAULT_NONE
*/

}

float MAX31865::MAX31865_normalizeTemp(float temp) {
    tempBuffer.append(temp);

    if (tempBuffer.size() > bufferSize) {
        tempBuffer.removeFirst();
    }

    float sum = std::accumulate(tempBuffer.begin(), tempBuffer.end(), 0.0f);

    if (temp < 0) {
        return -17.77777777777778f;
    } else {
        return sum / tempBuffer.size();
    }
}

MAX31865::~MAX31865() {
    gpioTerminate();
}
