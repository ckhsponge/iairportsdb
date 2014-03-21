This project is a mac and iOS database for airports worldwide. A Cocoa framework Core Data model and accompanying Objective C classes is used. Runway and frequency information is also included.

This databse is used in the wildly popular [NRST: Descent Rate & Airport Finder](https://itunes.apple.com/us/app/nrst-descent-rate-airport/id828514590?ls=1&mt=8) for iOS.

To get started quickly:

* Create an XCode project
* In the projects directory run:
* $ mkdir lib
* $ git submodule add https://github.com/ckhsponge/iairportsdb.git ./lib/iairportsdb
* In XCode add the group /lib and /lib/iairportsdb
* Select the iairportsdb group
* Right click and Add files to your project
* Select /lib/iairportsdb/db and /lib/iairportsdb/models
* Make sure "Create groups for any added folders" is selected
* You are done!

Now you can find airports using:
* [Airport findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance]
* [Airport findAllByIdentifier:(NSString *) identifier]
*

