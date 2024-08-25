/**
  ******************************************************************************
  * File Name          : rpidata.cpp
  * Description        : Raspberry Pi / QT Data class
  ******************************************************************************
  * @attention
**/

#include "rpidata.h"
#include <QDebug>

RPiData::RPiData() {};

void RPiData::setCurrentTemp_HLT(float value) {
    if (RPiDataStruct.currentTemp_HLT != value) {
        RPiDataStruct.currentTemp_HLT = value;
        emit currentTemp_HLTChanged();
    }
};

void RPiData::setCurrentTemp_Mash(float value) {
    if (RPiDataStruct.currentTemp_Mash != value) {
        RPiDataStruct.currentTemp_Mash = value;
        emit currentTemp_MashChanged();
    }
};

void RPiData::setCurrentTemp_Boil(float value) {
    if (RPiDataStruct.currentTemp_Boil != value) {
        RPiDataStruct.currentTemp_Boil = value;
        emit currentTemp_BoilChanged();
    }
};

void RPiData::setCurrentTemp_Mash2(float value) {
    if (RPiDataStruct.currentTemp_Mash2 != value) {
        RPiDataStruct.currentTemp_Mash2 = value;
        emit currentTemp_Mash2Changed();
    }
};

void RPiData::setSetpointHltOrMash(float value) {
    if (RPiDataStruct.setpointHltOrMash != value) {
        RPiDataStruct.setpointHltOrMash = value;
        emit setpointHltOrMashChanged();
    }
};

void RPiData::setSetpointTemp_HLT(float value) {
    if (RPiDataStruct.setpointTemp_HLT != value) {
        RPiDataStruct.setpointTemp_HLT = value;
        emit setpointTemp_HLTChanged();
    }
};

void RPiData::setSetpointTemp_Hash(float value) {
    if (RPiDataStruct.setpointTemp_Mash != value) {
        RPiDataStruct.setpointTemp_Mash = value;
        emit setpointTemp_MashChanged();
    }
};

void RPiData::setSetpointTemp_Boil(float value) {
    if (RPiDataStruct.setpointTemp_Boil != value) {
        RPiDataStruct.setpointTemp_Boil = value;
        emit setpointTemp_BoilChanged();
    }
};

void RPiData::setSetpointPercent_HLT(int value) {
    if (RPiDataStruct.setpointPercent_HLT != value) {
        RPiDataStruct.setpointPercent_HLT = value;
        emit setpointPercent_HLTChanged();
    }
};

void RPiData::setSetpointPercent_Mash(int value) {
    if (RPiDataStruct.setpointPercent_Mash != value) {
        RPiDataStruct.setpointPercent_Mash = value;
        emit setpointPercent_MashChanged();
    }
};

void RPiData::setSetpointPercent_Boil(int value) {
    if (RPiDataStruct.setpointPercent_Boil != value) {
        RPiDataStruct.setpointPercent_Boil = value;
        emit setpointPercent_BoilChanged();
    }
};

void RPiData::setSetpointManual_HLT(bool value) {
    if (RPiDataStruct.setpointManual_HLT != value) {
        RPiDataStruct.setpointManual_HLT = value;
        emit setpointManual_HLTChanged();
    }
};

void RPiData::setSetpointManual_Mash(bool value) {
    if (RPiDataStruct.setpointManual_Mash != value) {
        RPiDataStruct.setpointManual_Mash = value;
        emit setpointManual_MashChanged();
    }
};

void RPiData::setSetpointManual_Boil(bool value) {
    if (RPiDataStruct.setpointManual_Boil != value) {
        RPiDataStruct.setpointManual_Boil = value;
        emit setpointManual_BoilChanged();
    };
}

void RPiData::setElementOn_HLT(bool value) {
    if (RPiDataStruct.elementOn_HLT != value) {
        RPiDataStruct.elementOn_HLT = value;
        emit elementOn_HLTChanged();
    }
}
void RPiData::setElementOn_Boil(bool value) {
    if (RPiDataStruct.elementOn_Boil != value) {
        RPiDataStruct.elementOn_Boil = value;
        emit elementOn_BoilChanged();
    }
};

void RPiData::setPumpOn_Wort(bool value) {
    if (RPiDataStruct.pumpOn_Wort != value) {
        RPiDataStruct.pumpOn_Wort = value;
        emit pumpOn_WortChanged();
    }
};

void RPiData::setPumpOn_Water(bool value) {
    if (RPiDataStruct.pumpOn_Water != value) {
        RPiDataStruct.pumpOn_Water = value;
        emit pumpOn_WaterChanged();
    }
};
