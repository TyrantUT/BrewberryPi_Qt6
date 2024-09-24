#include <pigpio.h>

int gpioInitialise(void) {
    //qDebug() << "Initalise";
    return 0;
}

int spiOpen(unsigned spiChan, unsigned baud, unsigned spiFlags) {
    return 0;
}

int gpioTerminate(void) {
    return 0;
}

int gpioRead (unsigned gpio) {
    //qDebug() << gpio;
    return 0;
}

int gpioWrite(unsigned gpio, unsigned level) {
    //qDebug() << gpio << " " << level;
    return 0;
}

int gpioPWM(unsigned user_gpio, unsigned dutycycle) {
    //qDebug() << user_gpio << " " << dutycycle;
    return 0;
}

int gpioSetMode(unsigned gpio, unsigned mode) {
    //qDebug() << gpio << " " << mode;
    return 0;
}


int gpioSetPWMrange(unsigned user_gpio, unsigned range) {
    //qDebug() << user_gpio << " " << range;
    return 0;
}

int spiRead(unsigned handle, char *buf, unsigned count) {
    return 0;
}

int spiWrite(unsigned handle, char *buf, unsigned count) {
    return 0;
}
