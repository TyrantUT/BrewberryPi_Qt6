#ifndef RPIHELPER_H
#define RPIHELPER_H

#include <QThread>
#include <QDebug>

#ifdef PLATFORM_ARM
#include "/sysroot/usr/include/pigpio.h"
#else
// Define stubs for pigpio
#define PI_INPUT 0
#define PI_OUTPUT 1
#define PI_LOW 0
#define PI_HIGH 1
inline void gpioInitialise() {}
inline void gpioSetMode(unsigned, unsigned) {}
inline void gpioWrite(unsigned, unsigned) {}
inline void gpioPWM(unsigned, unsigned) {}
inline void gpioSetPWMrange(unsigned, unsigned) {}
inline void gpioTerminate() {}
inline int gpioRead(unsigned) { return 0; }
#endif

#define QT_DEBUG_ON         (bool)      true
#define QT_THREADS_MAX      (bool)      false
#define QT_THREADS_PID_HLT  (bool)      false
#define QT_THREADS_PID_BOIL (bool)      false

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

float mapPWM(float input);
void piSetup(void);
void piDestroy(void);
void gpioWriteValue(unsigned pin, unsigned value);
void pwmWriteValue(unsigned pin, unsigned value);
void spiSendBytes(quint8 byte);
quint8 spiReceiveBytes(void);

#endif // RPIHELPER_H
