#import "Mobsense.h"

@implementation Mobsense

- (void) start:(CDVInvokedUrlCommand*)command
{
    _commandglo = command;
    @try
    {
        self.sensingKit = [SensingKitLib sharedSensingKitLib];
        NSString *startSensor = [[_commandglo arguments] objectAtIndex:0];
        SKSensorType startSensorEnum = [self getSensorEnum:startSensor : _commandglo];
        if([self.sensingKit isSensorAvailable:startSensorEnum])
        {
            if([self.sensingKit registerSensor:startSensorEnum error:NULL])
            {
                @try
                {
                    [self.sensingKit startContinuousSensingWithSensor:startSensorEnum error:NULL];
                    NSLog(@"%@", startSensor);
                    NSLog(@"%lu", (unsigned long)startSensorEnum);
                
                    CDVPluginResult* result = [CDVPluginResult
                                               resultWithStatus:CDVCommandStatus_OK
                                               messageAsString:@"Sensor Started"];
                    [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
                }
                @catch (NSException *exception)
                {
                    CDVPluginResult* result = [CDVPluginResult
                                               resultWithStatus:CDVCommandStatus_ERROR
                                               messageAsString:@"Exception! Couldn't start sensor."];
                    [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
                }
            }
            else
            {
                CDVPluginResult* result = [CDVPluginResult
                                           resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:@"Sensor failed to register"];
                [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
            }
        }
        else
        {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:@"Sensor not available"];
            [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
        }
    }
    @catch (NSException *exception)
    {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"Exception! Couldn't register sensor."];
        [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
    }
}

- (void) stop:(CDVInvokedUrlCommand*)command
{
    _commandglo = command;
    @try
    {
        Boolean stopFlag = false;
        Boolean errStopFlag = false;
        NSArray *sensarray = [self getSensorArray];
        
//        if([self.sensingKit isSensorRegistered:Accelerometer])
//        {
//            CDVPluginResult* result = [CDVPluginResult
//                                       resultWithStatus:CDVCommandStatus_OK
//                                       messageAsString:@"suceessssssss"];
//            [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
//        }
        
        for(int i=0;i<sizeof(sensarray);i++)
        {
           if([self.sensingKit isSensorRegistered:i])
           {
               if([self.sensingKit deregisterSensor:i error:NULL]) //stopContinuousSensingWithSensor
               {
                   stopFlag =true;
               }
               else
               {
                   errStopFlag = true;
               }
           }
        }
        
        if(errStopFlag)
        {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:@"Error stopping some sensors. Retry!"];
            [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
        }
        if(stopFlag)
        {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_OK
                                       messageAsString:@"All sensors stopped"];
            [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
        }
        else
        {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:@"Sensor stop failed since no Sensor has been started"];
            [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
        }
    }
    @catch (NSException *exception)
    {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"Exception! Couldn't stop sensor."];
        [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
    }
}

- (void) list:(CDVInvokedUrlCommand*)command
{
    _commandglo = command;
    self.sensingKit = [SensingKitLib sharedSensingKitLib];
    NSMutableString *sensorList = [NSMutableString string];
    NSArray *sensarray = [self getSensorArray];
    for(int i=0;i<sizeof(sensarray);i++)
    {
        if ([self.sensingKit isSensorAvailable:i])
        {
            [sensorList appendString:sensarray[i]];
            [sensorList appendString:@"\n"];
        }
    }
    NSString *message = NULL;
    message = sensorList;
    CDVPluginResult* result;
    if (message != NULL)
    {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_OK
                  messageAsString:message];
    }
    else
    {
        result = [CDVPluginResult
                  resultWithStatus:CDVCommandStatus_ERROR
                  messageAsString:@"No sensors detected!"];
    }
    [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
}

- (void) getState:(CDVInvokedUrlCommand*)command
{
    self.sensingKit = [SensingKitLib sharedSensingKitLib];
    _commandglo = command;
    //NSString *stateSensor = [[_commandglo arguments] objectAtIndex:0];
    //SKSensorType stateSensorEnum = [self getSensorEnum:stateSensor : _commandglo];
    //[self.sensingKit startContinuousSensingWithSensor:stateSensorEnum error:NULL];
    NSArray *sensarray = [self getSensorArray];
    int isensor=-1;
    for(int i=0;i<sizeof(sensarray);i++)
    {
        if([self.sensingKit isSensorRegistered:i])
        {
            isensor=i;
            break;
        }
    }
    
    if(isensor!=-1)
    {
        if([self.sensingKit isSensorRegistered:isensor])
        {
            if([self.sensingKit subscribeToSensor:isensor
                                      withHandler:^(SKSensorType sensorType, SKSensorData *sensorData, NSError *error){
                                          if (!error)
                                          {
                                              NSLog (@"%@", sensorData);
                                              
//                                              NSString *message = @"GOD DAMN NO!!";
//                                              CDVPluginResult* result = [CDVPluginResult
//                                                                         resultWithStatus:CDVCommandStatus_ERROR
//                                                                         messageAsString:message];
//                                              [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
//
                                             NSMutableArray *returnArrayData =[[NSMutableArray alloc] init];
                                              
                                              
                                              
                                              //////////////////////////////////
                                              
                                           
                                          
                                              NSLog (@"%@", @"sensorData");
                                              
                                              //    Battery
                                              //    Location
                                              //    iBeaconProximity
                                              //    EddystoneProximity
                                              //    Microphone
                                              
                                              
                                              if(sensorType==Accelerometer)
                                              {
                                                     NSLog (@"%@", @"sensorData");
                                                  SKAccelerometerData *SKData = (SKAccelerometerData *)sensorData;
                                                  
                                                  if([returnArrayData count]){
                                                      [returnArrayData removeAllObjects];
                                                  }
                                                  
                                                  NSNumber *accx = [NSNumber numberWithDouble:SKData.acceleration.x];
                                                  [returnArrayData addObject:accx];
                                                  
                                                  NSNumber *accy = [NSNumber numberWithDouble:SKData.acceleration.y];
                                                  [returnArrayData addObject:accy];
                                                  
                                                  NSNumber *accz = [NSNumber numberWithDouble:SKData.acceleration.z];
                                                  [returnArrayData addObject:accz];
                                              }
                                              else if (sensorType==Gyroscope)
                                              {
                                                  SKGyroscopeData *SKData = (SKGyroscopeData *)sensorData;
                                                  
                                                  if([returnArrayData count]){
                                                      [returnArrayData removeAllObjects];
                                                  }
                                                  
                                                  NSNumber *rotx = [NSNumber numberWithDouble:SKData.rotationRate.x];
                                                  [returnArrayData addObject:rotx];
                                                  
                                                  NSNumber *roty = [NSNumber numberWithDouble:SKData.rotationRate.y];
                                                  [returnArrayData addObject:roty];
                                                  
                                                  NSNumber *rotz = [NSNumber numberWithDouble:SKData.rotationRate.z];
                                                  [returnArrayData addObject:rotz];
                                              }
                                              else if (sensorType==Magnetometer)
                                              {
                                                  SKMagnetometerData *SKData = (SKMagnetometerData *)sensorData;
                                                  
                                                  if([returnArrayData count]){
                                                      [returnArrayData removeAllObjects];
                                                  }
                                                  
                                                  NSNumber *magx = [NSNumber numberWithDouble:SKData.magneticField.x];
                                                  [returnArrayData addObject:magx];
                                                  
                                                  NSNumber *magy = [NSNumber numberWithDouble:SKData.magneticField.y];
                                                  [returnArrayData addObject:magy];
                                                  
                                                  NSNumber *magz = [NSNumber numberWithDouble:SKData.magneticField.z];
                                                  [returnArrayData addObject:magz];
                                              }
                                              else if (sensorType==DeviceMotion)
                                              {
                                                  SKDeviceMotionData *SKData = (SKDeviceMotionData *)sensorData;
                                                  
                                                  if([returnArrayData count]){
                                                      [returnArrayData removeAllObjects];
                                                  }
                                                  
                                                  // MAgnetic Field
                                                  //NSNumber *magacc = [NSNumber numberWithDouble:SKData.magneticField.accuracy];
                                                  //[returnArrayData addObject:magacc];
                                                  
                                                  NSNumber *magx = [NSNumber numberWithDouble:SKData.magneticField.field.x];
                                                  [returnArrayData addObject:magx];
                                                  
                                                  NSNumber *magy = [NSNumber numberWithDouble:SKData.magneticField.field.y];
                                                  [returnArrayData addObject:magy];
                                                  
                                                  NSNumber *magz = [NSNumber numberWithDouble:SKData.magneticField.field.z];
                                                  [returnArrayData addObject:magz];
                                                  
                                                  // Attitude
                                                  NSNumber *attroll = [NSNumber numberWithDouble:SKData.attitude.roll];
                                                  [returnArrayData addObject:attroll];
                                                  
                                                  NSNumber *attpitch = [NSNumber numberWithDouble:SKData.attitude.pitch];
                                                  [returnArrayData addObject:attpitch];
                                                  
                                                  NSNumber *attyaw = [NSNumber numberWithDouble:SKData.attitude.yaw];
                                                  [returnArrayData addObject:attyaw];
                                                  
                                                  //rotationRate
                                                  NSNumber *rotx = [NSNumber numberWithDouble:SKData.rotationRate.x];
                                                  [returnArrayData addObject:rotx];
                                                  
                                                  NSNumber *roty = [NSNumber numberWithDouble:SKData.rotationRate.y];
                                                  [returnArrayData addObject:roty];
                                                  
                                                  NSNumber *rotz = [NSNumber numberWithDouble:SKData.rotationRate.z];
                                                  [returnArrayData addObject:rotz];
                                                
                                                  //userAcceleration
                                                  NSNumber *accx = [NSNumber numberWithDouble:SKData.userAcceleration.x];
                                                  [returnArrayData addObject:accx];
                                                  
                                                  NSNumber *accy = [NSNumber numberWithDouble:SKData.userAcceleration.y];
                                                  [returnArrayData addObject:accy];
                                                  
                                                  NSNumber *accz = [NSNumber numberWithDouble:SKData.userAcceleration.z];
                                                  [returnArrayData addObject:accz];
                                                  
                                                  //gravity
                                                  NSNumber *gravx = [NSNumber numberWithDouble:SKData.gravity.x];
                                                  [returnArrayData addObject:gravx];
                                                  
                                                  NSNumber *gravy = [NSNumber numberWithDouble:SKData.gravity.y];
                                                  [returnArrayData addObject:gravy];
                                                  
                                                  NSNumber *gravz = [NSNumber numberWithDouble:SKData.gravity.z];
                                                  [returnArrayData addObject:gravz];
                                              }
                                              else if (sensorType==MotionActivity)
                                              {
                                                  SKMotionActivityData *SKData = (SKMotionActivityData *)sensorData;
                                                  
                                                  if([returnArrayData count]){
                                                      [returnArrayData removeAllObjects];
                                                  }
                                                  
                                                  NSString *motion = @"exception";
                                                  
                                                  if(SKData.motionActivity.stationary) motion=@"stationary";
                                                  if(SKData.motionActivity.walking) motion=@"walking";
                                                  if(SKData.motionActivity.running) motion=@"running";
                                                  if(SKData.motionActivity.automotive) motion=@"automotive";
                                                  if(SKData.motionActivity.cycling) motion=@"cycling";
                                                  if(SKData.motionActivity.unknown) motion=@"unknown";
                                                  
                                                  [returnArrayData addObject:motion];
                                              }
                                              else if (sensorType==Pedometer)
                                              {
                                                  SKPedometerData *SKData = (SKPedometerData *)sensorData;
                                                  
                                                  if([returnArrayData count]){
                                                      [returnArrayData removeAllObjects];
                                                  }
                                                  
                                                  // Dates might cause crashes To:DO
                                                  [returnArrayData addObject:SKData.pedometerData.startDate];
                                                  
                                                  [returnArrayData addObject:SKData.pedometerData.endDate];
                                                  
                                                  [returnArrayData addObject:SKData.pedometerData.numberOfSteps];
                                                  
                                                  if (![SKData.pedometerData.distance isKindOfClass:[NSNull class]])
                                                      [returnArrayData addObject:SKData.pedometerData.distance];
                                                  
                                                  if (![SKData.pedometerData.averageActivePace isKindOfClass:[NSNull class]])
                                                      [returnArrayData addObject:SKData.pedometerData.averageActivePace];
                                                  
                                                  if (![SKData.pedometerData.currentPace isKindOfClass:[NSNull class]])
                                                      [returnArrayData addObject:SKData.pedometerData.currentPace];
                                                  
                                                  if (![SKData.pedometerData.currentCadence isKindOfClass:[NSNull class]])
                                                      [returnArrayData addObject:SKData.pedometerData.currentCadence];
                                                  
                                                  if (![SKData.pedometerData.floorsAscended isKindOfClass:[NSNull class]])
                                                      [returnArrayData addObject:SKData.pedometerData.floorsAscended];
                                                  
                                                  if (![SKData.pedometerData.floorsDescended isKindOfClass:[NSNull class]])
                                                      [returnArrayData addObject:SKData.pedometerData.floorsDescended];
                                              }
                                              else if (sensorType==Altimeter)
                                              {
                                                  SKAltimeterData *SKData = (SKAltimeterData *)sensorData;
                                                  
                                                  if([returnArrayData count]){
                                                      [returnArrayData removeAllObjects];
                                                  }
                                                  
                                                  [returnArrayData addObject:SKData.altitudeData.relativeAltitude];
                                                  
                                                  [returnArrayData addObject:SKData.altitudeData.pressure];
                                              }
                                              else if (sensorType==Battery)
                                              {
                                                  SKBatteryData *SKData = (SKBatteryData *)sensorData;
                                                  
                                                  if([returnArrayData count]){
                                                      [returnArrayData removeAllObjects];
                                                  }
                                                  
                                                  NSNumber *batlvl = [NSNumber numberWithFloat:SKData.level];
                                                  [returnArrayData addObject:batlvl];
                                                  
                                                  [returnArrayData addObject:SKData.stateString];
                                              }
//                                              else if (sensorType==Location)
//                                              {
//                                                  SKLocationData *SKData = (SKLocationData *)sensorData;
//                                              }
//                                              else if (sensorType==iBeaconProximity)
//                                              {
//                                                  SKiBeaconDeviceData *SKData = (SKiBeaconDeviceData *)sensorData;
//                                              }
//                                              else if (sensorType==EddystoneProximity)
//                                              {
//                                                  SKAltimeterData *SKData = (SKAltimeterData *)sensorData;
//                                              }
                                              
                                              CDVPluginResult* result = [CDVPluginResult
                                                                         resultWithStatus:CDVCommandStatus_OK                                messageAsArray:returnArrayData];
                                              [result setKeepCallback:[NSNumber numberWithBool:YES]];
                                              [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
                                          }
                                          else
                                          {
                                              NSString *message = @"GOD DAMN NO!!";
                                              CDVPluginResult* result = [CDVPluginResult
                                                                         resultWithStatus:CDVCommandStatus_ERROR
                                                                         messageAsString:message];
                                              [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
                                          }
                                      }
                                            error:NULL]==1)
            {
                // Should never reach here
            }
            else
            {
                CDVPluginResult* result = [CDVPluginResult
                                           resultWithStatus:CDVCommandStatus_ERROR
                                           messageAsString:@"Failed to subscribe to sensor"];
                [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
            }
            
            [self.sensingKit startContinuousSensingWithSensor:isensor error:NULL];
        }
        else
        {
            CDVPluginResult* result = [CDVPluginResult
                                       resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:@"Sensor not started"];
            [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
        }
    }
    else
    {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"No sensors started"];
        [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
    }
}

- (SKSensorType)getSensorEnum:(NSString*)sensorString :(CDVInvokedUrlCommand*)command
{
    _commandglo = command;
    SKSensorType result=-1;
    /////////////// iOS - Android //////////////
    //                      - PROXIMITY
    //        Accelerometer - ACCELEROMETER
    //        Gyroscope - GYROSCOPE, GYROSCOPE_UNCALIBRATED
    //        DeviceMotion - LINEAR_ACCELERATION, GAME_ROTATION_VECTOR, GRAVITY, ROTATION_VECTOR, GEOMAGNETIC_ROTATION_VECTOR
    //        MotionActivity -
    //        Pedometer - STEP_DETECTOR, STEP_COUNTER
    //        Magnetometer - MAGNETIC_FIELD, MAGNETIC_FIELD_UNCALIBRATED, ORIENTATION
    //        Altimeter -
    //        Battery -
    //        Location -
    //        iBeaconProximity -
    //        EddystoneProximity -
    //        Microphone -
    //                          - SIGNIFICANT_MOTION
    //                          - AMBIENT_TEMPERATURE
    //                          - LIGHT
    //                          - PRESSURE
    //                          - RELATIVE_HUMIDITY
    //                          - TEMPERATURE
    if([sensorString caseInsensitiveCompare:@"PROXIMITY"] == NSOrderedSame ||
       [sensorString caseInsensitiveCompare:@"SIGNIFICANT_MOTION"] == NSOrderedSame ||
       [sensorString caseInsensitiveCompare:@"AMBIENT_TEMPERATURE"] == NSOrderedSame ||
       [sensorString caseInsensitiveCompare:@"LIGHT"] == NSOrderedSame ||
       [sensorString caseInsensitiveCompare:@"PRESSURE"] == NSOrderedSame ||
       [sensorString caseInsensitiveCompare:@"RELATIVE_HUMIDITY"] == NSOrderedSame ||
       [sensorString caseInsensitiveCompare:@"TEMPERATURE"] == NSOrderedSame)
    {   //1
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"Sensor support not available on iOS yet!"];
        [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
    }
    else if ([sensorString caseInsensitiveCompare:@"ACCELEROMETER"] == NSOrderedSame)
    {   //2
        result = Accelerometer;
    }
    else if ([sensorString caseInsensitiveCompare:@"GYROSCOPE"] == NSOrderedSame ||
             [sensorString caseInsensitiveCompare:@"GYROSCOPE_UNCALIBRATED"] == NSOrderedSame)
    {   //3
        result = Gyroscope;
    }
    else if ([sensorString caseInsensitiveCompare:@"LINEAR_ACCELERATION"] == NSOrderedSame ||
             [sensorString caseInsensitiveCompare:@"GAME_ROTATION_VECTOR"] == NSOrderedSame ||
             [sensorString caseInsensitiveCompare:@"GRAVITY"] == NSOrderedSame ||
             [sensorString caseInsensitiveCompare:@"ROTATION_VECTOR"] == NSOrderedSame ||
             [sensorString caseInsensitiveCompare:@"GEOMAGNETIC_ROTATION_VECTOR"] == NSOrderedSame)
    {   //4
        result = DeviceMotion;
    }
    else if ([sensorString caseInsensitiveCompare:@"MotionActivity"] == NSOrderedSame)
    {   //5
        result = MotionActivity;
    }
    else if ([sensorString caseInsensitiveCompare:@"STEP_DETECTOR"] == NSOrderedSame ||
             [sensorString caseInsensitiveCompare:@"STEP_COUNTER"] == NSOrderedSame)
    {   //6
        result = Pedometer;
    }
    else if ([sensorString caseInsensitiveCompare:@"MAGNETIC_FIELD"] == NSOrderedSame ||
             [sensorString caseInsensitiveCompare:@"MAGNETIC_FIELD_UNCALIBRATED"] == NSOrderedSame ||
             [sensorString caseInsensitiveCompare:@"ORIENTATION"] == NSOrderedSame)
    {   //7
        result = Magnetometer;
    }
    else if ([sensorString caseInsensitiveCompare:@"Altimeter"] == NSOrderedSame)
    {   //8
        result = Altimeter;
    }
    else if ([sensorString caseInsensitiveCompare:@"Battery"] == NSOrderedSame)
    {   //9
        result = Battery;
    }
    else if ([sensorString caseInsensitiveCompare:@"Location"] == NSOrderedSame)
    {   //10
        result = Location;
    }
    else if ([sensorString caseInsensitiveCompare:@"iBeaconProximity"] == NSOrderedSame)
    {   //11
        result = iBeaconProximity;
    }
    else if ([sensorString caseInsensitiveCompare:@"EddystoneProximity"] == NSOrderedSame)
    {   //12
        result = EddystoneProximity;
    }
    else if ([sensorString caseInsensitiveCompare:@"Microphone"] == NSOrderedSame)
    {   //13
        result = Microphone;
    }
    else
    {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"Unrecognized Sensor Name!"];
        [self.commandDelegate sendPluginResult:result callbackId:_commandglo.callbackId];
    }
    return result;
    
    
    /////////////// Android //////////////
    //    PROXIMITY
    //    ACCELEROMETER
    //    GYROSCOPE
    //    GYROSCOPE_UNCALIBRATED
    //    LINEAR_ACCELERATION
    //    GAME_ROTATION_VECTOR
    //    GRAVITY
    //    ROTATION_VECTOR
    //    GEOMAGNETIC_ROTATION_VECTOR
    //    STEP_DETECTOR
    //    STEP_COUNTER
    //    MAGNETIC_FIELD
    //    MAGNETIC_FIELD_UNCALIBRATED
    //    ORIENTATION
    //    SIGNIFICANT_MOTION
    //    AMBIENT_TEMPERATURE
    //    LIGHT
    //    PRESSURE
    //    RELATIVE_HUMIDITY
    //    TEMPERATURE
    
    
    
    /////////////// iOS - Android //////////////
    //                      - PROXIMITY
    //        Accelerometer - ACCELEROMETER
    //        Gyroscope - GYROSCOPE, GYROSCOPE_UNCALIBRATED
    //        Magnetometer - LINEAR_ACCELERATION
    //        DeviceMotion - GAME_ROTATION_VECTOR, GRAVITY, ROTATION_VECTOR, GEOMAGNETIC_ROTATION_VECTOR
    //        MotionActivity -
    //        Pedometer - STEP_DETECTOR, STEP_COUNTER
    //        Magnetometer - MAGNETIC_FIELD, MAGNETIC_FIELD_UNCALIBRATED, ORIENTATION
    //        Altimeter -
    //        Battery -
    //        Location -
    //        iBeaconProximity -
    //        EddystoneProximity -
    //        Microphone -
    //                          - SIGNIFICANT_MOTION
    //                          - AMBIENT_TEMPERATURE
    //                          - LIGHT
    //                          - PRESSURE
    //                          - RELATIVE_HUMIDITY
    //                          - TEMPERATURE
    
    
    //ios sensor list in enum order
    
    //    Accelerometer
    //    Gyroscope
    //    Magnetometer
    //    DeviceMotion
    //    MotionActivity
    //    Pedometer
    //    Altimeter
    //    Battery
    //    Location
    //    iBeaconProximity
    //    EddystoneProximity
    //    Microphone
}

- (NSArray*) getSensorArray
{
    NSArray *sensarray = [NSArray arrayWithObjects:
                          @"Accelerometer",
                          @"Gyroscope",
                          @"Magnetometer",
                          @"DeviceMotion",
                          @"MotionActivity",
                          @"Pedometer",
                          @"Altimeter",
                          @"Battery",
                          @"Location",
                          @"iBeaconProximity",
                          @"EddystoneProximity",
                          @"Microphone",
                          nil];
    return sensarray;
}

@end

