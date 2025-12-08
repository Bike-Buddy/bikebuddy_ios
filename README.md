# bikebuddy_ios

This repo includes the code for the iPhone used to run BikeBuddy.

## Directories 
* The `BikeBuddy` directory contains the main code used to run the BikeBuddy app
* The `BikeBuddy.xcodeproj` directory contains the XCode configuration files required for development setup
* The `BikeBuddyTests` directory contains code used for app testing
* The `BikeBuddyUITests` directory contains code used for UI testing

## Main Features
* Bluetooth Low Energy connection to an ESP32 microcontroller  
* Writing data to SwiftData persistent data storage 
* Displaying collected metrics to the user, along with the ability to delete collected data
* Presenting bike maintenance suggestions to the user 

## Future work
* Improve BLE communications to enable two-way communications
* Pedal and braking cadence detection
* More rigorous testing of backend and UI/UX functionality via XCode testing
* Flexible software architecture using better OOP design principles 
* Enhancing data collection with weather and location services (WeatherKit, MapKit)
