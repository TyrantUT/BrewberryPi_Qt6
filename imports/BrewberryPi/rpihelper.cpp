#include "rpihelper.h"

float mapPWM(float input) {
    return 1.0 * OUTPUT_MIN + \
        ((OUTPUT_MAX - OUTPUT_MIN) / (INPUT_MAX - INPUT_MIN)) \
        * (input - INPUT_MIN);
}

void piSetup(void) {
    gpioInitialise();

    gpioSetMode(MISO, PI_INPUT);

    gpioSetMode(MOSI, PI_OUTPUT);
    gpioWrite(MOSI, PI_LOW);

    gpioSetMode(SCLK, PI_OUTPUT);
    gpioWrite(SCLK, PI_LOW);

    gpioSetMode(ELEMENT_HLT, PI_OUTPUT);
    gpioSetMode(ELEMENT_BOIL, PI_OUTPUT);
    gpioWrite(ELEMENT_HLT, PI_LOW);
    gpioWrite(ELEMENT_BOIL, PI_LOW);

    gpioSetMode(PUMP_WORT, PI_OUTPUT);
    gpioSetMode(PUMP_WATER, PI_OUTPUT);
    gpioWrite(PUMP_WORT, PI_HIGH);
    gpioWrite(PUMP_WATER, PI_HIGH);

    gpioSetMode(PWM_HLT, PI_OUTPUT);
    gpioSetMode(PWM_BOIL, PI_OUTPUT);
    gpioSetPWMrange(PWM_HLT, OUTPUT_MAX);
    gpioSetPWMrange(PWM_BOIL, OUTPUT_MAX);

    gpioPWM(PWM_HLT, PI_LOW);
    gpioPWM(PWM_BOIL, PI_LOW);
}

void gpioWriteValue(unsigned pin, unsigned value) {
    gpioWrite(pin, value);
}

void pwmWriteValue(unsigned pin, unsigned value) {
    gpioPWM(pin, value);
}

void spiSendBytes(quint8 byte) {
    for (int i = 0; i < 8; i++) {
        gpioWrite(SCLK, PI_HIGH);
        if (byte & 0x80) {
            gpioWrite(MOSI, PI_HIGH);
        } else {
            gpioWrite(MOSI, PI_LOW);
        }
        byte <<= 1;
        gpioWrite(SCLK, PI_LOW);

        QThread::usleep(500);
    }
}

quint8 spiReceiveBytes(void) {
    quint8 byte = 0x00;

    for (int i = 0; i < 8; i++) {
        gpioWrite(SCLK, PI_HIGH);
        byte <<= 1;
        if (gpioRead(MISO)) {
            byte |= 0x1;
        }
        gpioWrite(SCLK, PI_LOW);

        QThread::usleep(500);
    }

    return byte;
}
