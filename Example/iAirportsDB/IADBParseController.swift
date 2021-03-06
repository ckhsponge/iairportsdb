//
//  IADBParseController.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/20/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreLocation
import iAirportsDB

class IADBParseController {
    static let projectPath = "/Users/ckh/dev/iAirportsDB"
    static let dbPath = "\(projectPath)/Example/data/iAirportsDBExample.sqlite"
    
    static let modelTypes:[IADBModel.Type] = [IADBAirport.self, IADBFrequency.self, IADBNavigationAid.self, IADBRunway.self]
    
    init() {
    }
    
    func downloadAndParse() {
        downloadAll()
        parseAll()
    }
    
    func downloadAll() {
        for type in IADBParseController.modelTypes {
            downloadFile(fileName: fileNameForModel(type: type)!)
        }
    }
    
    func parseAll() {
        //IADBModel.setPersistantStorePath(IADBParseController.dbPath, readOnly: false)
        let path = IADBParseController.dbPath
        try! FileManager.default.removeItem(atPath: path)
        IADBModel.setPersistence(path:path, readOnly:false)
        print("Cleared local db")
        for type in IADBParseController.modelTypes {
            ModelParser(fileName: fileNameForModel(type: type)!, modelType: type).go()
        }
    }
    
    func fileNameForModel(type: IADBModel.Type) -> String? {
        switch type.descriptionShort() {
        case "IADBAirport": return "airports"
        case "IADBFrequency": return "airport-frequencies"
        case "IADBRunway": return "runways"
        case "IADBNavigationAid": return "navaids"
            default: break
        }
        return nil
    }
    
    func downloadFile(fileName: String) {
        let stringURL = "http://www.ourairports.com/data/\(fileName).csv"
        let url = URL(string: stringURL)!
        print("Downloading \(stringURL)")
        guard let urlData = NSData(contentsOf: url) else {
            fatalError("No data found!")
        }
        if urlData.length > 0 {
            let filePath = "\(IADBParseController.projectPath)/Example/data/\(fileName).csv"
            if urlData.write(toFile: filePath, atomically: true) {
                print("Wrote to \(filePath)")
            }
            else {
                print("Failed to write to \(filePath)")
            }
        }
        else {
            print("No data at \(stringURL)")
        }
    }
    
    func test() {
        let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: NSDate() as Date)
        var airports = IADBAirport.findNear(location, withinNM: 18.0)
        //should find SFO but not OAK
        //    CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(-13.81, -172.0) altitude:100.0 horizontalAccuracy:100.0 verticalAccuracy:100.0 course:15.0 speed:10.0 timestamp:[NSDate date]];
        //    AirportArray *airports = [Airport findNear:location withinNM:1000.0];
        //should find some east and west longitudes
        //    CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(-17.7, 178.75) altitude:100.0 horizontalAccuracy:100.0 verticalAccuracy:100.0 course:15.0 speed:10.0 timestamp:[NSDate date]];
        //    AirportArray *airports = [Airport findNear:location withinNM:1000.0];
        //should find some east and west longitudes
        print("Airports: \(airports.description)")
        let navs = IADBNavigationAid.findNear(location, withinNM: 18.0)
        print("navs: \(navs.description)")
        let locs = IADBLocation.findNear(location, withinNM: 18.0)
        print("mixed: \(locs.description)")
        let named = IADBLocation.findAll(identifier:"KILM")
        named.sortInPlace(location)
        print("named: \(named.description)")
        for location: IADBLocation in named.array {
            if (location is IADBAirport) {
                
            }
            let airport = (location as! IADBAirport)
            let frequencies = airport.frequencies
            for frequency: IADBFrequency in frequencies {
                print("freq: \("\(frequency.mhz) \(frequency.name)")")
            }
        }
        airports = IADBAirport.findAll(identifierOrCode:"ICN")
        print("find ICN -- \(airports)")
        airports = IADBAirport.findAll(identifierOrCodeOrMunicipality:"Seoul")
        print("find Seoul -- \(airports)")

        ObjectiveCTest().test()
    }
}
