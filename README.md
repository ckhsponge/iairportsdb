This project contains an Objective C core data model and accompanying classes for airports worldwide. Runway and frequency information is also included. To get started quickly:

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

Now you can find airport using:
[Airport findNear:(CLLocation *) location withinNM:(CLLocationDistance) distance]
[Airport findAllByIdentifier:(NSString *) identifier]
