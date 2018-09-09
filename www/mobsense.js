/*global cordova, module*/

module.exports = {
    getState: function(successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Mobsense", "getState", []);
    },

    /**
     *  Enable the sensor. Needs to be called before getting the state.
     */
    enableSensor: function(TYPE_SENSOR, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Mobsense", "start", [TYPE_SENSOR]);
    },

    /**
     *  Disable the sensor.
     */
    disableSensor: function(successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Mobsense", "stop", []);
    },

    getSensorList: function(successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Mobsense", "list", []);
    }
};


/*
DOC:

"PROXIMITY"
"ACCELEROMETER"
"GRAVITY"
"GYROSCOPE"
"GYROSCOPE_UNCALIBRATED"
"LINEAR_ACCELERATION"
"ROTATION_VECTOR"
"SIGNIFICANT_MOTION"
"STEP_COUNTER"
"STEP_DETECTOR"
"GAME_ROTATION_VECTOR"
"GEOMAGNETIC_ROTATION_VECTOR"
"MAGNETIC_FIELD"
"MAGNETIC_FIELD_UNCALIBRATED"
"ORIENTATION"
"AMBIENT_TEMPERATURE"
"LIGHT"
"PRESSURE"
"RELATIVE_HUMIDITY"
"TEMPERATURE"
*/