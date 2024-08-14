/**
  ******************************************************************************
  * File Name          : max31865.cpp
  * Description        : MAX31865 temperature sensor class
  ******************************************************************************
  * @attention
**/

#include "max31865.h"
#include <tgmath.h>

MAX31865::MAX31865(int8_t spi_cs) {
    // Set SPI Chip Select pin
    _spi_cs = spi_cs;
    gpioSetMode(_spi_cs, PI_OUTPUT);
    gpioWrite(_spi_cs, PI_HIGH);
}

void MAX31865::MAX31865_init(void) {
    // Set up auto conversion
    uint8_t dataByte;
    dataByte = MAX31865_buildDataByte();
    MAX31865_writeRegister(0, dataByte);
    QThread::msleep(100);

}

uint8_t MAX31865::MAX31865_buildDataByte(void) {
    uint8_t dataByte = MAX31865_CONFIG_REG;

    dataByte |= MAX31865_CONFIG_BIAS; // Enable Bias
    dataByte |= MAX31865_CONFIG_MODEAUTO; // Set to Manual
    dataByte &= ~MAX31865_CONFIG_1SHOT; // Configure 1 Shot
    dataByte |= MAX31865_CONFIG_3WIRE; // Configure 3 wire PT100
    dataByte &= ~MAX31865_CONFIG_FAULTCYCLE; // Disable fault cycle
    dataByte |= MAX31865_CONFIG_FAULTSTAT; // Clear fault bit
    dataByte |= MAX31865_CONFIG_FILT60HZ; // Enable 60Hz

    return dataByte;
}

void MAX31865::MAX31865_readTemp(void) {

    uint8_t outBuf[8];
    //uint8_t conf_reg;

    uint8_t rtd_msb, rtd_lsb;
    //uint8_t hft_msb, hft_lsb;
    //uint8_t lft_msb, lft_lsb;

    // Read all registers
    MAX31865_readRegister(0, 8, outBuf);

    //conf_reg = outBuf[0];
    //printf("Configuration Register: %02x\n", conf_reg);

    rtd_msb = outBuf[1];
    rtd_lsb = outBuf[2];

    // Combine two bytes to one for RTD Response
    uint16_t rtd_response = (( rtd_msb << 8 ) | rtd_lsb ) >> 1;
    //printf("RTD Code: %i\n", rtd_ADC_Code);

    //hft_msb = outBuf[3];
    //hft_lsb = outBuf[4];

    //uint16_t hft = (( hft_msb << 8 ) | hft_lsb ) >> 1;
    //printf("High Fault Threshold: %d\n", hft);

    //lft_msb = outBuf[5];
    //lft_lsb = outBuf[6];

    //uint16_t lft = (( lft_msb << 8 ) | lft_lsb ) >> 1;
    //printf("Low Fault Threshold: %d\n", lft);

    // Read Fault from buffer
    _fault = outBuf[7];

    // Compare fault bit to get fault text for debugging
    MAX31865_compareFault();

    // Calculate temperature from rtd_response
    MAX31865_calculateTempC(rtd_response);

    // We need to allow for at least 100msec for each conversion
    // Note: This will impact the Temp Thread overall wait time since all 4 are within 1 thread
    QThread::msleep(100);

}

void MAX31865::MAX31865_writeRegister(uint8_t regNum, uint8_t data) {
    gpioWrite(_spi_cs, PI_LOW);
    uint8_t address = 0x80 | regNum;
    RPiComms::spiSendByte(address);
    RPiComms::spiSendByte(data);
    gpioWrite(_spi_cs, PI_HIGH);
}

void MAX31865::MAX31865_readRegister(uint8_t regNumStart, uint8_t numRegisters, uint8_t buffer[]) {
    gpioWrite(_spi_cs, PI_LOW);
    RPiComms::spiSendByte(regNumStart);

    for (int i = 0; i < numRegisters; i++) {
        buffer[i] = RPiComms::spiReceiveByte();
    }

    gpioWrite(_spi_cs, PI_HIGH);
}

void MAX31865::MAX31865_calculateTempC(uint16_t rtd_response) {
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

    //printf("Temp in C: %f\n", temp);

    temp = MAX31865_normalizeTemp(temp);
    _tempC = temp;
    _lastTempC = _tempC;
}

void MAX31865::MAX31865_compareFault(void) {

    //# bit 7: RTD High Threshold / cable fault open
    //# bit 6: RTD Low Threshold / cable fault short
    //# bit 5: REFIN- > 0.85 x VBias -> must be requested
    //# bit 4: REFIN- < 0.85 x VBias (FORCE- open) -> must be requested
    //# bit 3: RTDIN- < 0.85 x VBias (FORCE- open) -> must be requested
    //# bit 2: Overvoltage / undervoltage fault

    _faultText = "Unknown error has occured. Refer to the MAX31865 datasheet.";
    if (_fault == MAX31865_FAULT_NONE) {
        _faultText = "No faults detected.";
    }
    if (_fault == MAX31865_FAULT_HIGHTHRESH) {
        _faultText = "Measured resistance greater than High Fault Threshold value.";
    }
    if (_fault == MAX31865_FAULT_LOWTHRESH) {
        _faultText = "Measured resistance less than Low Fault Threshold value.";
    }
    if (_fault == MAX31865_FAULT_REFINLOW) {
        _faultText = "vREFIN > 0.85 x vBIAS.";
    }
    if (_fault == MAX31865_FAULT_REFINHIGH) {
        _faultText = "vRERFIN < 0.85 X vBIAS (FORCE - open).";
    }
    if (_fault == MAX31865_FAULT_RTDINLOW) {
        _faultText = "vRTRIN- < 0.85 X vBIAS (FORCE - open).";
    }
    if (_fault & MAX31865_FAULT_OVUV) {
        _faultText = "Any protected input voltage > vDD or < GND1.";
    }
}

float MAX31865::MAX31865_normalizeTemp(float temp) {
    if ((temp < 0) || (temp > 102) )
        return _lastTempC;
    else
        return temp;
}

MAX31865::~MAX31865() {
}
