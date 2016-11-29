NOTE: this library was converted to **Swift 3** and made a pod! See the objectivec or swift2 branch for the old style.

This project is a mac and iOS database for airports worldwide. A Cocoa framework Core Data model and accompanying Swift classes are used. Runway and frequency information is also included.

Add this line to your Podfile:
```
pod 'iAirportsDB', :git => 'https://github.com/ckhsponge/iairportsdb.git'
```
**IMPORTANT:** The pod now only includes an empty database. Download a complete database using the below command.
```
curl -O https://raw.githubusercontent.com/ckhsponge/iairportsdb/master/Example/data/iAirportsDBExample.sqlite
```
Add the downloaded file to your Xcode project and then configure IADB to use it using:
```
IADBModel.setPersistence(path: Bundle.main.path(forResource: "iAirportsDBExample", ofType: "sqlite")!)
```

This databse is used in the wildly popular [NRST: Descent Rate & Airport Finder](https://itunes.apple.com/us/app/nrst-descent-rate-airport/id828514590?ls=1&mt=8) for iOS.

Here are some stubs of the data you get:
```
class IADBAirport {
    var identifier: String // gps code
    var latitude: Double
    var longitude: Double
    var name: String
    var type: String
    var elevationFeet: NSNumber? // for objc compatibility Int32? is not allowed, -1 is a valid elevation
    var code: String // iata code e.g. ICN, this is what is printed on boarding passes
    var municipality: String /// Normally the nearby city e.g. Seoul
    var runways:[IADBRunway]
    var frequencies:[IADBFrequency]
}

class IADBRunway {
    var closed: Bool
    var lighted: Bool
    var headingTrue: Float // runway 12 will have a magnetic heading of ~120
    var identifierA: String // e.g. 12
    var identifierB: String // e.g. 30
    var lengthFeet: Int32
    var surface: String // e.g. TURF
    var widthFeet: Int32
}

class IADBFrequency {
    var mhz: Float
    var name: String // e.g. APP
    var type: String // e.g. NORCAL APP
}
```

Find airports using:
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

