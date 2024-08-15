/**
  ******************************************************************************
  * File Name          : pidcontroller.cpp
  * Description        : Raspberry Pi PID Controller class
  ******************************************************************************
  * @attention
**/

#include "pidcontroller.h"

PIDController::PIDController(){
}

void PIDController::PIDInit(float kp, float ki, float kd,
                            float sampleTimeSeconds, float minOutput,
                            float maxOutput, PIDMode mode,
                            PIDDirection controllerDirection)
{
    _controllerDirection = controllerDirection;
    _mode = mode;
    _iTerm = 0.0f;
    _input = 0.0f;
    _lastInput = 0.0f;
    _output = 0.0f;
    _setpoint = 0.0f;

    if (sampleTimeSeconds > 0.0f) {
        _sampleTime = sampleTimeSeconds;
    } else {
        // If the passed parameter was incorrect, set to .1 second
        _sampleTime = 0.1f;
    }

    PIDOutputLimitsSet(minOutput, maxOutput);
    PIDTuningsSet(kp, ki, kd);
}

bool PIDController::PIDCompute() {
    float error;
    float dInput;

    if (_mode == MANUAL) {
        return false;
    }

    // The classic PID error term
    error = (_setpoint - _input);
    // Compute the integral term separately ahead of time
    _iTerm += _alteredKi * error;
    // Constrain the integrator to make sure it does not exceed output bounds
    _iTerm = CONSTRAIN(_iTerm, _outMin, _outMax);
    // Take the "derivative on measurement" instead of "derivative on error"
    dInput = _input - _lastInput;
    // Run all the terms together to get the overall output
    _output = _alteredKp * error + _iTerm - _alteredKd * dInput;
    // Bound the output
    _output = CONSTRAIN(_output, _outMin, _outMax);
    // Make the current input the former input
    _lastInput = _input;

    return true;
}

void PIDController::PIDModeSet(PIDMode mode) {
    // If the mode changed from MANUAL to AUTOMATIC
    if (_mode != mode && _mode == AUTOMATIC) {
        _iTerm = _output;
        _lastInput = _input;

        _iTerm = CONSTRAIN(_iTerm, _outMin, _outMax);;
    }
    _mode = mode;
}

void PIDController::PIDOutputLimitsSet(float outMin, float outMax) {
    // check if the params are valid
    if (outMin >= outMax) {
        return;
    }

    // Save new params
    _outMin = outMin;
    _outMax = outMax;

    // Constrain if in Automatic mode
    if (_mode == AUTOMATIC) {
        _output = CONSTRAIN(_output, outMin, outMax);
        _iTerm = CONSTRAIN(_iTerm, outMin, outMax);
    }
}

void PIDController::PIDTuningsSet(float kp, float ki, float kd) {
    // Check if params are valid
    if (kp < 0.0f || ki < 0.0f || kd < 0.0f) {
        return;
    }

    // Save new params
    _dispKp = kp;
    _dispKi = ki;
    _dispKd = kd;

    // Alter to params for PID
    _alteredKp = kp;
    _alteredKi = ki * _sampleTime;
    _alteredKd = kd / _sampleTime;

}

void PIDController::PIDControllerDirectionSet(PIDDirection controllerDirection) {
    // If in automatic mode and the controller's sense of direction is reversed
    if (_mode == AUTOMATIC && _controllerDirection == REVERSE)
    {
        // Reverse sense of direction of PID gain constants
        _alteredKp = -(_alteredKp);
        _alteredKi = -(_alteredKi);
        _alteredKd = -(_alteredKd);
    }

    _controllerDirection = controllerDirection;
}

void PIDController::PIDSampleTimeSet(float sampleTimeSeconds) {
    float ratio;
    if (sampleTimeSeconds > 0.0f) {
        // Find the ratio of change and apply to the altered values
        ratio = sampleTimeSeconds / _sampleTime;
        _alteredKi += ratio;
        _alteredKd /= ratio;

        _sampleTime = sampleTimeSeconds;
    }
}

void PIDController::PIDTuningKpSet(float kp) {
    PIDTuningsSet(kp, _dispKi, _dispKd);
}
void PIDController::PIDTuningKiSet(float ki) {
    PIDTuningsSet(_dispKp, ki, _dispKd);
}

void PIDController::PIDTuningKdSet(float kd) {
    PIDTuningsSet(_dispKp, _dispKi, kd);
}

PIDController::~PIDController() {
}


