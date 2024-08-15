/**
  ******************************************************************************
  * File Name          : pidcontroller.h
  * Description        : Header file for Raspberry Pi PID Controller
  ******************************************************************************
  * @attention
**/

#ifndef PIDCONTROLLER_H
#define PIDCONTROLLER_H

#define CONSTRAIN(x,lower,upper)    ((x)<(lower)?(lower):((x)>(upper)?(upper):(x)))

class PIDController
{
public:
    explicit PIDController();
    virtual ~PIDController();


    typedef enum _PIDMode {
        MANUAL,
        AUTOMATIC
    } PIDMode;

    typedef enum _PIDDirection {
        DIRECT,
        REVERSE
    } PIDDirection;

    // Function prototypes
    void PIDInit(float kp, float ki, float kd, float sampleTimeSeconds, float minOutput, float maxOutput, PIDMode mode, PIDDirection controllerDirection);
    bool PIDCompute();
    void PIDModeSet(PIDMode mode);
    void PIDOutputLimitsSet(float outMin, float outMax);
    void PIDTuningsSet(float kp, float ki, float kd);
    void PIDControllerDirectionSet(PIDDirection controllerDirection);
    void PIDSampleTimeSet(float sampleTimeSeconds);

    // Set new tuned values
    void PIDTuningKpSet(float kp);
    void PIDTuningKiSet(float ki);
    void PIDTuningKdSet(float kd);

    // Inline Functions
    inline void PIDSetpointSet(float setpoint) { _setpoint = setpoint; }
    inline void PIDInputSet(float input) { _input = input; }
    inline float PIDOutputGet() { return _output; }
    inline float PIDKpGet() { return _dispKp; }
    inline float PIDKiGet() { return _dispKi; }
    inline float PIDKdGet() { return _dispKd; }
    inline PIDMode PIDModeGet() { return _mode; }
    inline PIDDirection PIDDirectionGet() { return _controllerDirection; }

private:
    float _input;
    float _setpoint;
    float _output;
    float _lastInput;
    float _dispKp;
    float _dispKi;
    float _dispKd;
    float _alteredKp;
    float _alteredKi;
    float _alteredKd;
    float _iTerm;
    float _sampleTime;
    float _outMin;
    float _outMax;
    PIDDirection _controllerDirection;
    PIDMode _mode;
};

#endif // PIDCONTROLLER_H
