//
//  CheckInViewController.m
//  ParkHere
//
//  Created by Alexandre JACQUEMOT on 25/04/2015.
//  Copyright (c) 2015 TransformiBeaconHackathon. All rights reserved.
//

#import "CheckInViewController.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import <KVNProgress/KVNProgress.h>
#import "PlaceAvailableViewController.h"

@interface CheckInViewController () <ESTBeaconManagerDelegate, ESTNearableManagerDelegate>

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTNearableManager *nearableManager;
@property (nonatomic, strong) CLBeaconRegion* region;

@end

@implementation CheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage* logoImage = [UIImage imageNamed:@"park_here"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
    logoView.frame = CGRectMake(0, 0, logoImage.scale*44.0, 44.0);
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoView;
}

#pragma mark - Actions

- (void)startRanging {
    _region = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EngineRegion"];
    
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self.beaconManager requestAlwaysAuthorization];
        [_beaconManager startRangingBeaconsInRegion:_region];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        [_beaconManager startRangingBeaconsInRegion:_region];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

- (IBAction)LocateCarParkInUsingBeacon:(id)sender {
    if (_beaconManager == nil) {
        _beaconManager = [ESTBeaconManager new];
        _beaconManager.delegate = self;
    }
    if (_nearableManager == nil) {
        _nearableManager = [ESTNearableManager new];
        _nearableManager.delegate = self;
    }
    
    [self startRanging];
    [_nearableManager startRangingForType:ESTNearableTypeAll];
    [KVNProgress showWithStatus:@"Scanning ..."];
}

- (IBAction)LocateCarParkInUsingLocation:(id)sender {
    // TODO for a future feature
}

#pragma mark - ESTBeaconManagerDelegate

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    if (beacons.count > 0) {
        CLBeacon* closestBeacon = beacons[0];
        
        if (closestBeacon.proximity == CLProximityImmediate) {
            [manager stopRangingBeaconsInRegion:_region];
            [_nearableManager stopRanging];
            [self presentPlaceAvailableViewControllerUsingBeacon:closestBeacon orNearable:nil orLocation:nil];
        }
    }
}

#pragma mark - ESTNearableManager delegate

- (void)nearableManager:(ESTNearableManager *)manager didRangeNearables:(NSArray *)nearables withType:(ESTNearableType)type
{
    if (nearables.count > 0) {
        ESTNearable *closestNearable = nearables[0];

        if (closestNearable.zone == ESTNearableZoneImmediate) {
            [manager stopRanging];
            [_beaconManager stopRangingBeaconsInRegion:_region];
            [self presentPlaceAvailableViewControllerUsingBeacon:nil orNearable:closestNearable orLocation:nil];
        }
    }
}

#pragma mark - Methods

- (void)presentPlaceAvailableViewControllerUsingBeacon:(CLBeacon *)beacon orNearable:(ESTNearable *)nearable orLocation:(CLLocation *)location {
    [KVNProgress dismiss];
    
    PlaceAvailableViewController *placeAvailableViewController = (PlaceAvailableViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PlaceAvailable"];
    if (beacon) {
        placeAvailableViewController.beaconIdentifier = [NSString stringWithFormat:@"%@-%@", beacon.major, beacon.minor];
    } else if (nearable) {
        placeAvailableViewController.beaconIdentifier = nearable.identifier;
    } else {

    }
    
    [self.navigationController pushViewController:placeAvailableViewController animated:YES];
}

@end
