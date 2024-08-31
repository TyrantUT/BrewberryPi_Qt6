#ifndef RPIDATA_H
#define RPIDATA_H

#include <QObject>
#include <QReadWriteLock>
#include <QReadLocker>
#include <QWriteLocker>
#include "qqmlintegration.h"
#include <QThread>

typedef struct RPiData_t {
    // HLT or Mash mode
    bool setpointHltOrMash{false};

    // Current Temperature
    float currentTemp_HLT = 0.0f;
    float currentTemp_Mash = 0.0f;
    float currentTemp_Boil = 0.0f;
    float currentTemp_Mash2 = 0.0f;

    // Setpoint Values;
    float setpointTemp_HLT = 0.0f;
    float setpointTemp_Mash = 0.0f;
    float setpointTemp_Boil = 0.0f;
    int setpointPercent_HLT = 0;
    int setpointPercent_Mash = 0;
    int setpointPercent_Boil = 0.0f;

    bool setpointManual_HLT = false;
    bool setpointManual_Mash = false;
    bool setpointManual_Boil = false;

    // Element Control
    bool elementOn_HLT = false;
    bool elementOn_Boil = false;

    // Pump Control;
    bool pumpOn_Wort = false;
    bool pumpOn_Water = false;

    // PWM Values
    float pwmDutyCycle_HLT = 0.0f;
    float pwmDutyCycle_Boil = 0.0f;

} RPiData_t;

class RPiData : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY (bool setpointHltOrMash READ getSetpointHltOrMash WRITE setSetpointHltOrMash NOTIFY setpointHltOrMashChanged)

    Q_PROPERTY (float currentTemp_HLT READ getCurrentTemp_HLT NOTIFY currentTemp_HLTChanged)
    Q_PROPERTY (float currentTemp_Mash READ getCurrentTemp_Mash NOTIFY currentTemp_MashChanged)
    Q_PROPERTY (float currentTemp_Boil READ getCurrentTemp_Boil NOTIFY currentTemp_BoilChanged)
    Q_PROPERTY (float currentTemp_Mash2 READ getCurrentTemp_Mash2 NOTIFY currentTemp_Mash2Changed)

    Q_PROPERTY (float setpointTemp_HLT READ getSetpointTemp_HLT WRITE setSetpointTemp_HLT NOTIFY setpointTemp_HLTChanged)
    Q_PROPERTY (float setpointTemp_Mash READ getSetpointTemp_Mash WRITE setSetpointTemp_Hash NOTIFY setpointTemp_MashChanged)
    Q_PROPERTY (float setpointTemp_Boil READ getSetpointTemp_Boil WRITE setSetpointTemp_Boil NOTIFY setpointTemp_BoilChanged)

    Q_PROPERTY (int setpointPercent_HLT READ getSetpointPercent_HLT WRITE setSetpointPercent_HLT NOTIFY setpointPercent_HLTChanged)
    Q_PROPERTY (int setpointPercent_Mash READ getSetpointPercent_Mash WRITE setSetpointPercent_Mash NOTIFY setpointPercent_MashChanged)
    Q_PROPERTY (int setpointPercent_Boil READ getSetpointPercent_Boil WRITE setSetpointPercent_Boil NOTIFY setpointPercent_BoilChanged)

    Q_PROPERTY (bool setpointManual_HLT READ getSetpointManual_HLT WRITE setSetpointManual_HLT NOTIFY setpointManual_HLTChanged)
    Q_PROPERTY (bool setpointManual_Boil READ getSetpointManual_Boil WRITE setSetpointManual_Boil NOTIFY setpointManual_BoilChanged)

    Q_PROPERTY (bool elementOn_HLT READ getElementOn_HLT WRITE setElementOn_HLT NOTIFY elementOn_HLTChanged)
    Q_PROPERTY (bool elementOn_Boil READ getElementOn_Boil WRITE setElementOn_Boil NOTIFY elementOn_BoilChanged)

    Q_PROPERTY (bool pumpOn_Wort READ getPumpOn_Wort WRITE setPumpOn_Wort NOTIFY pumpOn_WortChanged)
    Q_PROPERTY (bool pumpOn_Water READ getPumpOn_Water WRITE setPumpOn_Water NOTIFY pumpOn_WaterChanged)

public:
    explicit RPiData(QObject *parent = nullptr);
    virtual ~RPiData() {};

    bool getSetpointHltOrMash(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointHltOrMash;}
    float getCurrentTemp_HLT(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.currentTemp_HLT;}
    float getCurrentTemp_Mash(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.currentTemp_Mash;}
    float getCurrentTemp_Boil(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.currentTemp_Boil;}
    float getCurrentTemp_Mash2(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.currentTemp_Mash2;}
    float getSetpointTemp_HLT(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointTemp_HLT;}
    float getSetpointTemp_Mash(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointTemp_Mash;}
    float getSetpointTemp_Boil(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointTemp_Boil;}
    int getSetpointPercent_HLT(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointPercent_HLT;}
    int getSetpointPercent_Mash(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointPercent_Mash;}
    int getSetpointPercent_Boil(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointPercent_Boil;}
    bool getSetpointManual_HLT(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointManual_HLT;}
    bool getSetpointManual_Boil(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.setpointManual_Boil;}
    bool getElementOn_HLT(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.elementOn_HLT;}
    bool getElementOn_Boil(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.elementOn_Boil;}
    bool getPumpOn_Wort(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.pumpOn_Wort;}
    bool getPumpOn_Water(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.pumpOn_Water;}
    float getPwmDutyCycle_HLT(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.pwmDutyCycle_HLT;}
    float getPwmDutyCycle_Boil(void) const { QReadLocker locker(&rpiDataMutex); return RPiDataStruct.pwmDutyCycle_Boil;}

    void setCurrentTemp_HLT(float value);
    void setCurrentTemp_Mash(float value);
    void setCurrentTemp_Boil(float value);
    void setCurrentTemp_Mash2(float value);

    void setPwmDutyCycle_HLT(float value);
    void setPwmDutyCycle_Boil(float value);

    // Mutex
    mutable QReadWriteLock rpiDataMutex;

public slots:
    void setSetpointHltOrMash(bool value);
    void setSetpointTemp_HLT(float value);
    void setSetpointTemp_Hash(float value);
    void setSetpointTemp_Boil(float value);
    void setSetpointPercent_HLT(int value);
    void setSetpointPercent_Mash(int value);
    void setSetpointPercent_Boil(int value);
    void setSetpointManual_HLT(bool value);
    void setSetpointManual_Boil(bool value);
    void setElementOn_HLT(bool value);
    void setElementOn_Boil(bool value);
    void setPumpOn_Wort(bool value);
    void setPumpOn_Water(bool value);

signals:
    void setpointHltOrMashChanged();
    void currentTemp_HLTChanged();
    void currentTemp_MashChanged();
    void currentTemp_BoilChanged();
    void currentTemp_Mash2Changed();
    void setpointTemp_HLTChanged();
    void setpointTemp_MashChanged();
    void setpointTemp_BoilChanged();
    void setpointPercent_HLTChanged();
    void setpointPercent_MashChanged();
    void setpointPercent_BoilChanged();
    void setpointManual_HLTChanged();
    void setpointManual_BoilChanged();
    void elementOn_HLTChanged(bool value);
    void elementOn_BoilChanged(bool value);
    void pumpOn_WortChanged(bool value);
    void pumpOn_WaterChanged(bool value);
    void pwmDutyCycle_HLTChanged(float value);
    void pwmDutyCycle_BoilChanged(float value);

private:
    // Data
    RPiData_t RPiDataStruct;
};

#endif // RPIDATA_H
