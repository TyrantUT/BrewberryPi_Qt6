#include <QDebug>

#ifndef PIGPIO_H
#define PIGPIO_H

#define PI_LOW      0
#define PI_HIGH     1
#define PI_INPUT    0
#define PI_OUTPUT   1

int gpioInitialise(void);
int gpioTerminate(void);
int gpioRead (unsigned gpio);
int gpioWrite(unsigned gpio, unsigned level);
int gpioPWM(unsigned user_gpio, unsigned dutycycle);
int gpioSetMode(unsigned gpio, unsigned mode);
int gpioSetPWMrange(unsigned user_gpio, unsigned range);
int spiRead(unsigned handle, char *buf, unsigned count);
int spiWrite(unsigned handle, char *buf, unsigned count);

#endif // PWM_THREAD_H
