// https://github.com/Quick/Quick

import Quick
import Nimble
import CoreLocation
@testable import iAirportsDB

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("these will pass") {
            let path = Bundle.main.path(forResource: "iAirportsDBExample", ofType: "sqlite")!
            IADBModel.setPersistence(path: path)
            
            it("can find") {
                let sfo = IADBAirport.find(identifier:"KSFO")!
                expect(sfo.identifier).to(equal("KSFO"))
                expect(sfo.name).to(contain("San Francisco"))
                
                let oak = IADBAirport.find(identifier:"KOAK")!
                expect(oak.identifier).to(equal("KOAK"))
                
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: Date())
                let airports = IADBAirport.findNear(location, withinNM: 18.0)
                expect(airports).to(contain(sfo))
                expect(airports.array).toNot(contain(oak))
                
                
            }
            
            it("can find by type") {
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: Date())

                var types:[IADBAirport.AirportType]? = nil
                var airports = IADBAirport.findNear(location, withinNM: 30.0, types: types)
                let sql:IADBAirport! = IADBAirport.find(identifier:"KSQL")
                let sfo:IADBAirport! = IADBAirport.find(identifier:"KSFO")
                let commodore:IADBAirport! = IADBAirport.find(identifier:"22CA")
                expect(airports).to(contain(sql))
                expect(airports).to(contain(sfo))
                expect(airports).to(contain(commodore))
                
                types = []
                airports = IADBAirport.findNear(location, withinNM: 30.0, types: types)
                expect(airports).toNot(contain(sql))
                expect(airports).toNot(contain(sfo))
                expect(airports).toNot(contain(commodore))
                
                airports = IADBAirport.findNear(location, withinNM: 30.0, types: [IADBAirport.AirportType.Large])
                expect(airports).toNot(contain(sql))
                expect(airports).to(contain(sfo))
                expect(airports).toNot(contain(commodore))
                
                airports = IADBAirport.findNear(location, withinNM: 30.0, types: [IADBAirport.AirportType.Large, IADBAirport.AirportType.Medium, IADBAirport.AirportType.Small])
                expect(airports).to(contain(sql))
                expect(airports).to(contain(sfo))
                expect(airports).toNot(contain(commodore))
                
                airports = IADBAirport.findNear(location, withinNM: 30.0, types: [IADBAirport.AirportType.Seaplane])
                expect(airports).toNot(contain(sql))
                expect(airports).toNot(contain(sfo))
                expect(airports).to(contain(commodore))
            }
            
            it("has frequencies") {
                let sql = IADBAirport.find(identifier:"KSQL")
                expect(sql?.identifier).to(equal("KSQL"))
                expect(sql?.frequencies.map{$0.mhz}).to(contain(Float(125.9))) //SQL ATIS
            }
            
            it("has runways") {
                let sql = IADBAirport.find(identifier:"KSQL")
                expect(sql?.identifier).to(equal("KSQL"))
                expect(sql?.runways.count).to(equal(1))
                let runway:IADBRunway! = sql?.runways[0]
                expect([runway.identifierA, runway.identifierB]).to(contain("12"))
                expect([runway.identifierA, runway.identifierB]).to(contain("30"))
            }
            
            it("can guess runway heading") {
                expect(IADBRunway.identifierDegrees("")).to(equal(-1))
                expect(IADBRunway.identifierDegrees("L")).to(equal(-1))
                expect(IADBRunway.identifierDegrees("0")).to(equal(0.0))
                expect(IADBRunway.identifierDegrees("00")).to(equal(0.0))
                expect(IADBRunway.identifierDegrees("00X")).to(equal(0.0))
                expect(IADBRunway.identifierDegrees("4")).to(equal(40.0))
                expect(IADBRunway.identifierDegrees("04")).to(equal(40.0))
                expect(IADBRunway.identifierDegrees("04R")).to(equal(40.0))
                expect(IADBRunway.identifierDegrees("1L")).to(equal(10.0))
                expect(IADBRunway.identifierDegrees("01L")).to(equal(10.0))
                expect(IADBRunway.identifierDegrees("10")).to(equal(100.0))
                expect(IADBRunway.identifierDegrees("10L")).to(equal(100.0))
                expect(IADBRunway.identifierDegrees("15")).to(equal(150.0))
                expect(IADBRunway.identifierDegrees("15L")).to(equal(150.0))
                expect(IADBRunway.identifierDegrees("36")).to(equal(360.0))
                expect(IADBRunway.identifierDegrees("36L")).to(equal(360.0))
            }
            
            it("has navaids") {
                let osi = IADBNavigationAid.find(identifier:"OSI")
                expect(osi?.identifier).to(equal("OSI"))
                let oak = IADBNavigationAid.find(identifier:"OAK")
                expect(oak?.identifier).to(equal("OAK"))
                
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: Date())
                let navs = IADBNavigationAid.findNear(location, withinNM: 18.0)
                expect(navs).to(contain(osi!))
                expect(navs).toNot(contain(oak!))
            }
            
            it("can find mixed") {
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: Date())
                let locations = IADBLocation.findNear(location, withinNM: 18.0)
                
                let sfo:IADBAirport! = IADBAirport.find(identifier:"KSFO")
                let oak:IADBAirport! = IADBAirport.find(identifier:"KOAK")
                let osi:IADBNavigationAid! = IADBNavigationAid.find(identifier:"OSI")
                let oakVor:IADBNavigationAid! = IADBNavigationAid.find(identifier:"OAK")
                
                expect(locations).to(contain(sfo))
                expect(locations).toNot(contain(oak))
                expect(locations).to(contain(osi))
                expect(locations).toNot(contain(oakVor))
            }
            
            it("can sort") {
                //half moon bay
                let location = CLLocation(coordinate: CLLocationCoordinate2DMake(37.0 + 30.81 / 60.0, -122 - 30.07 / 60.0), altitude: 100.0, horizontalAccuracy: 100.0, verticalAccuracy: 100.0, course: 15.0, speed: 10.0, timestamp: Date())
                
                let airports = IADBAirport.findNear(location, withinNM: 30.0)
                let sfo:IADBAirport! = IADBAirport.find(identifier:"KSFO")
                let oak:IADBAirport! = IADBAirport.find(identifier:"KOAK")
                
                expect(airports.index(of: sfo)) < airports.index(of: oak)!
                airports.sortInPlace(oak.location)
                expect(airports.index(of: oak)) < airports.index(of: sfo)!
            }
            
            it("can find korea") {
                var airports = IADBAirport.findAll(identifierOrCode:"ICN")
                let icn = IADBAirport.find(identifier:"RKSI")
                expect(airports).to(contain(icn!))
                
                airports = IADBAirport.findAll(identifierOrCodeOrMunicipality:"Seoul")
                expect(airports).to(contain(icn!))
                
                //airports = IADBAirport.findAll(identifierOrCodeOrMunicipality:"seoul") //TODO case insensitive search
                //expect(airports).to(contain(icn!))
                
                airports = IADBAirport.findAll(identifierOrCode:"icn")
                expect(airports).to(contain(icn!))
            }
            
            it("can have long runway") {
                let airport = IADBAirport.find(identifier:"CPC7")
                expect(airport?.longestRunwayFeet()) > 60000
            }
            
            it("has hard runways") {
                expect(IADBRunway.isHard(surface: "concrete")).to(beTrue())
                expect(IADBRunway.isHard(surface: "PEM")).to(beTrue())
                expect(IADBRunway.isHard(surface: "asphalt")).to(beTrue())
                expect(IADBRunway.isHard(surface: "asf")).to(beTrue())
                expect(IADBRunway.isHard(surface: "bitumen")).to(beTrue())
                expect(IADBRunway.isHard(surface: "tarmac")).to(beTrue())
                expect(IADBRunway.isHard(surface: "unpaved")).to(beFalse())
                expect(IADBRunway.isHard(surface: "grass")).to(beFalse())
            }
            
            it("finds fast") {
                let start = Date()
                let airports = IADBAirport.findAll(identifierOrCode:"ICN")
                let icn = IADBAirport.find(identifier:"RKSI")
                expect(airports).to(contain(icn!))
                expect( -1.0 * start.timeIntervalSinceNow ) < 0.1
            }
            
            it("finds blank") {
                let airports = IADBAirport.findAll(identifierOrCode:"")
                expect(airports.count).to(equal(0))
            }
        }
    }
}
