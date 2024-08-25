#ifndef RPIHELPER_H
#define RPIHELPER_H

#import "pigpio.h"

#define QT_DEBUG_ON         (bool)      true

#define INPUT_MIN           (float)     0.0
#define INPUT_MAX           (float)     100.0
#define OUTPUT_MIN          (float)     0.0
#define OUTPUT_MAX          (float)     255.0

#define SPI_CHANNEL         0
#define SPI_SPEED           5000000

#define INPUT_MIN           (float)     0.0
#define INPUT_MAX           (float)     100.0
#define OUTPUT_MIN          (float)     0.0
#define OUTPUT_MAX          (float)     255.0
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

void piSetup(void) {
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

void gpioEnableElement(int pin) {
    gpioWrite(pin, PI_LOW);
}

void gpioDisableElement(int pin) {
    gpioWrite(pin, PI_HIGH);
}

#endif // RPIHELPER_H
