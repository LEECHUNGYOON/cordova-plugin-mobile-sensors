# cordova-plugin-mobile-sensors
Get all mobile sensor info in one plugin [Beta Version] 

# Supported Platforms

- Android
- iOS

# Installation Steps

This requires cordova ios 4.3.0+ which supports the use of cocoapods.<br/>
npm link :- https://www.npmjs.com/package/cordova-plugin-mobile-sensors

`cordova plugin add cordova-plugin-mobile-sensors`

For **Android** that is all.

For **iOS** please also follow the steps below.
- Once the iOS platform is added in command line, change directory to where podfile is found. Example location :- (myapp/platforms/ios). 
- Make sure you have [cocoapods](https://cocoapods.org/) installed then in command line do `pod update`. 
- Now open myapp.xcworkspace which is usually found in the same directory as the podfile, then build and run. <br/> 
*Note :- if you use myapp.xcodeproj to build and run, it will not work and it will show a linker error.* <br/>

# Plugin Usage
> Currently only one sensor can be functional at once. So to enable a new sensor, User needs to first disable any other sensors that were enabled.

- Get List of all sensors on the device.
```
mobsense.getSensorList(success,error);

function success(sensorArray)
{
  console.log(sensorArray);
}

function error(error)
{
  console.log(error);
}
```

- Enable the sensor. Common values are ACCELEROMETER, GYROSCOPE, MAGNETIC_FIELD, STEP_COUNTER, GRAVITY. Complete list coming soon!
```
mobsense.enableSensor("ACCELEROMETER",success,error);

function success(sensorArray)
{
  console.log(sensorArray);
}

function error(error)
{
  console.log(error);
}
```
- Disable all sensors.
```
mobsense.disableSensor(success,error);

function success(sensorArray)
{
  console.log(sensorArray);
}

function error(error)
{
  console.log(error);
}
```
- Get raw values of sensors as an array. Refer to android and ios sensor documentation to understand the unit of the returned values.
```
mobsense.getState(success,error);

function success(sensorArray)
{
  console.log(sensorArray);
}

function error(error)
{
  console.log(error);
}
```

# More about us
Find out more or contact us directly here :- http://www.neutrinos.co/

Facebook :- https://www.facebook.com/Neutrinos.co/ <br/>
LinkedIn :- https://www.linkedin.com/company/25057297/ <br/>
Twitter :- https://twitter.com/Neutrinosco <br/>
Instagram :- https://www.instagram.com/neutrinos.co/

[![N|Solid](https://image4.owler.com/logo/neutrinos_owler_20171023_142541_original.jpg "Neutrinos")](http://www.neutrinos.co/) 
