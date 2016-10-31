NOTE: this library was converted to **Swift 3** and made a pod! See the objectivec or swift2 branch for the old style.

This project is a mac and iOS database for airports worldwide. A Cocoa framework Core Data model and accompanying Swift classes are used. Runway and frequency information is also included.

Add this line to your Podfile:
```
pod 'iAirportsDB', :git => 'https://github.com/ckhsponge/iairportsdb.git'
```

This databse is used in the wildly popular [NRST: Descent Rate & Airport Finder](https://itunes.apple.com/us/app/nrst-descent-rate-airport/id828514590?ls=1&mt=8) for iOS.

Now you can find airports using:
* IADBAirport.findNear(CLLocation, withinNM:CLLocationDistance)
* IADBAirport.findNear(CLLocation, withinNM:CLLocationDistance, types:[IADBAirport.AirportType]?)
* IADBAirport.findAllByIdentifier(String)

Or in Objective C:
* [IADBAirport findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance]
* [IADBAirport findAllByIdentifier:(NSString *) identifier]
* [IADBNavigationAid findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance]
* [IADBNavigationAid findAllByIdentifier:(NSString *) identifier]
* [IADBLocation findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance]
* [IADBLocation findAllByIdentifier:(NSString *) identifier]

