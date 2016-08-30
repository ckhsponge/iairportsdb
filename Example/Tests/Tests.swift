// https://github.com/Quick/Quick

import Quick
import Nimble
import CoreLocation
@testable import iAirportsDB

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("these will fail") {
            
            it("can find") {
                let sfo = IADBAirport.findByIdentifier("KSFO")
                expect(sfo?.identifier).to(equal("KSFO"))
                expect(sfo?.name).to(contain("San Francisco"))
                
                let oak = IADBAirport.findByIdentifier("KOAK")
                expect(oak?.identifier).to(equal("KOAK"))
                
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: NSDate())
                let airports = IADBAirport.findNear(location, withinNM: 18.0)
                expect(airports).to(contain(sfo!))
                expect(airports.array).toNot(contain(oak))
                
                
            }
            
            it("has frequencies") {
                let sql = IADBAirport.findByIdentifier("KSQL")
                expect(sql?.identifier).to(equal("KSQL"))
                expect(sql?.frequencies.map{$0.mhz}).to(contain(Float(125.9))) //SQL ATIS
            }
            
            it("has runways") {
                let sql = IADBAirport.findByIdentifier("KSQL")
                expect(sql?.identifier).to(equal("KSQL"))
                expect(sql?.runways.count).to(equal(1))
                let runway:IADBRunway! = sql?.runways[0]
                expect([runway.identifierA, runway.identifierB]).to(contain("12"))
                expect([runway.identifierA, runway.identifierB]).to(contain("30"))
                
                //TODO test runway direction guesing
            }
            
            it("has navaids") {
                let osi = IADBNavigationAid.findByIdentifier("OSI")
                expect(osi?.identifier).to(equal("OSI"))
                let oak = IADBNavigationAid.findByIdentifier("OAK")
                expect(oak?.identifier).to(equal("OAK"))
                
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: NSDate())
                let navs = IADBNavigationAid.findNear(location, withinNM: 18.0)
                expect(navs).to(contain(osi!))
                expect(navs).toNot(contain(oak!))
            }
            
            it("can find mixed") {
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: NSDate())
                let locations = IADBLocation.findNear(location, withinNM: 18.0)
                
                let sfo:IADBAirport! = IADBAirport.findByIdentifier("KSFO")
                let oak:IADBAirport! = IADBAirport.findByIdentifier("KOAK")
                let osi:IADBNavigationAid! = IADBNavigationAid.findByIdentifier("OSI")
                let oakVor:IADBNavigationAid! = IADBNavigationAid.findByIdentifier("OAK")
                
                expect(locations).to(contain(sfo))
                expect(locations).toNot(contain(oak))
                expect(locations).to(contain(osi))
                expect(locations).toNot(contain(oakVor))
            }
            
            it("can sort") {
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: NSDate())
                let named = IADBLocation.findAllByIdentifier("KILM")
                named.sortByCenter(location)
                
                expect(named.count).to(equal(1)) //poor sorting test!
                expect(named[0].identifier).to(equal("KILM"))
            }
            
            it("can find korea") {
                var airports = IADBAirport.findAllByIdentifierOrCode("ICN", withTypes: nil)
                let icn = IADBAirport.findByIdentifier("RKSI")
                expect(airports).to(contain(icn!))
                
                airports = IADBAirport.findAllByIdentifierOrCodeOrMunicipality("Seoul", withTypes: nil)
                expect(airports).to(contain(icn!))
            }
            
        }
    }
}
