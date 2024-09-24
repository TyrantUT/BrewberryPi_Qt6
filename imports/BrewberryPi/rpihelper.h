#ifndef RPIHELPER_H
#define RPIHELPER_H

#include "pigpio.h"

#define QT_DEBUG_ON         (bool)      true
#define QT_THREADS_MAX      (bool)      true
#define QT_THREADS_PID_HLT  (bool)      false
#define QT_THREADS_PID_BOIL (bool)      false

#define INPUT_MIN           (float)     0.0
#define INPUT_MAX           (float)     100.0
#define OUTPUT_MIN          (float)     0.0
#define OUTPUT_MAX          (float)     255.0

#define SPI_CHANNEL         1
#define SPI_SPEED           200000

#define MISO                19
#define MOSI                20
#define SCLK                21

#define MAX31865_HLT_GPIO   14
#define MAX31865_MASH_GPIO  15
#define MAX31865_BOIL_GPIO  18
#define MAX31865_MASH2_GPIO 25
#define PWM_HLT             12
#define PWM_BOIL            13
#define ELEMENT_HLT         23
#define ELEMENT_BOIL        24
#define PUMP_WORT           2
#define PUMP_WATER          3

static float mapPWM(float input) {
    return 1.0 * OUTPUT_MIN + \
        ((OUTPUT_MAX - OUTPUT_MIN) / (INPUT_MAX - INPUT_MIN)) \
        * (input - INPUT_MIN);
};

static void piSetup(void) {

    gpioInitialise();

    gpioSetMode(MISO, PI_INPUT);

    // Set MOSI to Output and set Low
    gpioSetMode(MOSI, PI_OUTPUT);
    gpioWrite(MOSI, PI_LOW);

    // Set SCLK to Output and set to Low
    gpioSetMode(SCLK, PI_OUTPUT);
    gpioWrite(SCLK, PI_LOW);

    // Set Element Output to High
    gpioSetMode(ELEMENT_HLT, PI_OUTPUT);
    gpioSetMode(ELEMENT_BOIL, PI_OUTPUT);
    gpioWrite(ELEMENT_HLT, PI_HIGH);
    gpioWrite(ELEMENT_BOIL, PI_HIGH);

    // Set Pump Output to High
    gpioSetMode(PUMP_WORT, PI_OUTPUT);
    gpioSetMode(PUMP_WATER, PI_OUTPUT);
    gpioWrite(PUMP_WORT, PI_HIGH);
    gpioWrite(PUMP_WATER, PI_HIGH);

    // Set PWM Modes
    gpioSetMode(PWM_HLT, PI_OUTPUT);
    gpioSetMode(PWM_BOIL, PI_OUTPUT);
    gpioSetPWMrange(PWM_HLT, OUTPUT_MAX);
    gpioSetPWMrange(PWM_BOIL, OUTPUT_MAX);

    // Default PWM to 0
    gpioPWM(PWM_HLT, PI_LOW);
    gpioPWM(PWM_BOIL, PI_LOW);
}

static void gpioWriteValue(unsigned pin, unsigned value) {
    gpioWrite(pin, value);
};

static void pwmWriteValue(unsigned pin, unsigned value) {
    gpioPWM(pin, value);
};

#endif // RPIHELPER_H
