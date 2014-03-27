//
//  MainViewController.m
//  airportsdb
//
//  Created by Christopher Hobbs on 3/6/14.
//  Copyright (c) 2014 Toonsy Net. All rights reserved.
//

#import "MainViewController.h"
#import "AirportParser.h"
#import "FrequencyParser.h"
#import "RunwayParser.h"
#import "Airport.h"
#import "AirportArray.h"
#import "Frequency.h"
#import "Runway.h"
#import "Counter.h"
#import "IADBModel.h"
#import "IADBPersistence.h"

#define PROJECT_PATH @"/Users/ckh/dev/iairportsdb"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) downloadFile:(NSString *) fileName {
    NSString *stringURL = [NSString stringWithFormat:@"http://www.ourairports.com/data/%@.csv",fileName];
    NSURL  *url = [NSURL URLWithString:stringURL];
    NSLog(@"Downloading %@",stringURL);
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData && urlData.length > 0)
    {
        //NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        //NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"filename.png"];
        NSString *filePath = [NSString stringWithFormat:@"%@/data/%@.csv",PROJECT_PATH,fileName];
        if ( [urlData writeToFile:filePath atomically:YES] ) {
            NSLog(@"Wrote to %@", filePath);
        } else {
            NSLog(@"Failed to write to %@", filePath);
        }
    } else {
        NSLog(@"No data at %@",stringURL);
    }
}

- (IBAction)downloadData:(id)sender {
    NSArray *names = @[[[[AirportParser alloc] init] fileName],[[[FrequencyParser alloc] init] fileName],[[[RunwayParser alloc] init] fileName]];
    for(NSString *name in names) {
        [self downloadFile:name];
    }
}

- (IBAction)parseAll:(id)sender {
    [IADBModel setPersistencePath:[NSString stringWithFormat:@"%@/db/airportsdb.sqlite",PROJECT_PATH]]; //writes to a local project file instead of the compiled documents path
    [[IADBModel persistence] persistentStoreClear];
    
    [[[AirportParser alloc] init] parse];
    NSLog(@"Airports: %ld", (long) [Airport countAll]);
    
    [[[FrequencyParser alloc] init] parse];
    NSLog(@"Frequencies: %ld", (long) [Frequency countAll]);
    
    [[[RunwayParser alloc] init] parse];
    NSLog(@"Runways: %ld", (long) [Runway countAll]);
}

- (IBAction)countAll:(id)sender {
    [[[Counter alloc] init] count];
}

- (IBAction)findTest:(id)sender {
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.0+30.81/60.0, -122-30.07/60.0) altitude:100.0 horizontalAccuracy:100.0 verticalAccuracy:100.0 course:15.0 speed:10.0 timestamp:[NSDate date]];
    AirportArray *airports = [Airport findNear:location withinNM:18.0];
    //should find SFO but not OAK
    NSLog(@"Airports: %@", [airports description]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
