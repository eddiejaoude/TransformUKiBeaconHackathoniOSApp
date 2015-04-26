//
//  PlaceAvailableViewController.m
//  ParkHere
//
//  Created by Alexandre JACQUEMOT on 25/04/2015.
//  Copyright (c) 2015 TransformiBeaconHackathon. All rights reserved.
//

#import "PlaceAvailableViewController.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import <KVNProgress/KVNProgress.h>
#import "ParkHereAPI.h"

static NSString * const placeCellIdentifier = @"placeAvailableCell";
static NSString * const checkCellIdentifier = @"CheckCell";
static NSString * const PHJSON_CAR_PARK = @"carPark";
static NSString * const PHJSON_NAME = @"name";
static NSString * const PHJSON_UID = @"uid";
static NSString * const PHJSON_TOTAL_COST = @"totalCost";
static NSString * const PHJSON_AVAILABLE = @"available";

@interface PlaceAvailableViewController () <UITableViewDataSource, UITableViewDelegate, ESTBeaconManagerDelegate, ESTNearableManagerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayOfPlacesAvailable;
@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTNearableManager *nearableManager;
@property (nonatomic, strong) CLBeaconRegion* region;
@property (nonatomic, assign) BOOL hasCheckedIn;
@property (nonatomic, assign) NSDictionary *beaconSelected;

@end

@implementation PlaceAvailableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_button"] style:UIBarButtonItemStyleDone target:self action:@selector(goToPreviousView:)];
    [leftBarButton setTintColor:[UIColor colorWithRed:241.0/255.0 green:91.0/255.0 blue:91.0/255.0 alpha:1.0]];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    _hasCheckedIn = NO;
    
    if (_beaconManager == nil) {
        _beaconManager = [ESTBeaconManager new];
        _beaconManager.delegate = self;
    }
    if (_nearableManager == nil) {
        _nearableManager = [ESTNearableManager new];
        _nearableManager.delegate = self;
    }
    __weak typeof(self) weakSelf = self;

    [[ParkHereAPI sharedParkHereAPI] getCarParkInformationUsingBeaconId:_beaconIdentifier success:^(NSArray *information) {
        _arrayOfPlacesAvailable = information;
        [_tableView reloadData];
        
        if (_arrayOfPlacesAvailable.count > 0) {
            UINavigationItem *navigationItem = weakSelf.navigationItem;
            navigationItem.title = _arrayOfPlacesAvailable[0][PHJSON_CAR_PARK];
        }
    } failure:^(NSError *error) {
        
    }];
    
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:241.0/255.0 green:91.0/255.0 blue:91.0/255.0 alpha:1.0]}];
}

- (void)goToPreviousView:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _arrayOfPlacesAvailable.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:placeCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSDictionary *place = _arrayOfPlacesAvailable[indexPath.row];
        
        UILabel *placeIdentifierLabel = (UILabel *)[cell viewWithTag:1];
        placeIdentifierLabel.text = place[PHJSON_NAME];
        
        UIImageView *availabilityImageView = (UIImageView *)[cell viewWithTag:2];
        
        if ([place[PHJSON_AVAILABLE] integerValue] == 1) {
            availabilityImageView.image = [UIImage imageNamed:@"available"];
        } else {
            availabilityImageView.image = [UIImage imageNamed:@"unavailable"];
        }
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:checkCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *button = (UIButton *)[cell viewWithTag:1];
        [button addTarget:self action:@selector(startToScan:) forControlEvents:UIControlEventTouchUpInside];
        
        if (!_hasCheckedIn) {
            [button setTitle:@"CHECK IN" forState:UIControlStateNormal];
        } else {
            [button setTitle:@"CHECK OUT" forState:UIControlStateNormal];
        }
        
        return cell;
    }
}

#pragma mark - ESTBeaconManagerDelegate

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    if (beacons.count > 0) {
        CLBeacon* closestBeacon = beacons[0];
        
        if (closestBeacon.proximity == CLProximityImmediate) {
            if (!_hasCheckedIn) {
                [manager stopRangingBeaconsInRegion:_region];
                [_nearableManager stopRanging];
                [self checkIntoParkingPlaceWithBeacon:closestBeacon orNearable:nil];
            } else {
                [manager stopRangingBeaconsInRegion:_region];
                [_nearableManager stopRanging];
                [self checkOutParkingPlaceWithBeacon:closestBeacon orNearable:nil];
            }
            _hasCheckedIn = !_hasCheckedIn;
        }
    }
}

#pragma mark - ESTNearableManager delegate

- (void)nearableManager:(ESTNearableManager *)manager didRangeNearables:(NSArray *)nearables withType:(ESTNearableType)type
{
    if (nearables.count > 0) {
        ESTNearable *closestNearable = nearables[0];
        
        if (closestNearable.zone == ESTNearableZoneImmediate) {
            if (!_hasCheckedIn) {
                [manager stopRanging];
                [_beaconManager stopRangingBeaconsInRegion:_region];
                [self checkIntoParkingPlaceWithBeacon:nil orNearable:closestNearable];
            } else {
                [manager stopRanging];
                [_beaconManager stopRangingBeaconsInRegion:_region];
                [self checkOutParkingPlaceWithBeacon:nil orNearable:closestNearable];
            }
            _hasCheckedIn = !_hasCheckedIn;
        }
    }
}

#pragma mark - Methods

- (void)startToScan:(id)sender {
    [KVNProgress showWithStatus:@"Scanning ..."];
    [self startRanging];
    [_nearableManager startRangingForType:ESTNearableTypeAll];
}

- (void)checkIntoParkingPlaceWithBeacon:(CLBeacon *)beacon orNearable:(ESTNearable *)nearable {
    NSString *beaconId;
    
    if (beacon) {
        beaconId = [NSString stringWithFormat:@"%@-%@", beacon.major, beacon.minor];
    } else {
        beaconId = nearable.identifier;
    }
    for (NSDictionary *dic in _arrayOfPlacesAvailable)
    {
        if ([dic[PHJSON_UID] isEqualToString:beaconId]) {
            NSLog(@"%@", dic[PHJSON_NAME]);
        }
    }
    NSString *phoneUUID = @"lol";
    
    [[ParkHereAPI sharedParkHereAPI] postCheckIntoParkingSpaceWithBeaconId:beaconId userPhone:phoneUUID
                                                                   success:^(NSDictionary *response) {
                                                                       [[ParkHereAPI sharedParkHereAPI] getCarParkInformationUsingBeaconId:beaconId success:^(NSArray *information) {
                                                                           _arrayOfPlacesAvailable = information;
                                                                           [_tableView reloadData];
                                                                           [KVNProgress dismiss];
                                                                           
                                                                           for (NSDictionary *dic in _arrayOfPlacesAvailable)
                                                                           {
                                                                               if([dic[PHJSON_UID] isEqualToString:beaconId]) {
                                                                                   _beaconSelected = dic;
                                                                               }
                                                                           }
                                                                           
                                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:[NSString stringWithFormat:@"You parked you car at %@", _beaconSelected[PHJSON_NAME]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                           [alert show];
                                                                       } failure:^(NSError *error) {
                                                                           
                                                                       }];
                                                                   } failure:^(NSError *error) {
                                                                       _hasCheckedIn = NO;
                                                                       [self startToScan:nil];
                                                                   }];
}

- (void)checkOutParkingPlaceWithBeacon:(CLBeacon *)beacon orNearable:(ESTNearable *)nearable {
    NSString *beaconId;
    
    if (beacon) {
        beaconId = [NSString stringWithFormat:@"%@-%@", beacon.major, beacon.minor];
    } else {
        beaconId = nearable.identifier;
    }
    
    NSString *phoneUUID = @"lol";
    
    [[ParkHereAPI sharedParkHereAPI] postCheckOutParkingSpaceWithBeaconId:beaconId userPhone:phoneUUID
                                                                   success:^(NSDictionary *response) {
                                                                       [[ParkHereAPI sharedParkHereAPI] getCarParkInformationUsingBeaconId:beaconId success:^(NSArray *information) {
                                                                           _arrayOfPlacesAvailable = information;
                                                                           [_tableView reloadData];
                                                                           [KVNProgress dismiss];
                                                                           
                                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" message:[NSString stringWithFormat:@"Thank you for your visit"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                           [alert show];
                                                                       } failure:^(NSError *error) {
                                                                           
                                                                       }];
                                                                   } failure:^(NSError *error) {
                                                                       _hasCheckedIn = YES;
                                                                       [self startToScan:nil];
                                                                   }];
}

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

@end
