//
//  ParkHereAPI.h
//  ParkHere
//
//  Created by Alexandre JACQUEMOT on 26/04/2015.
//  Copyright (c) 2015 TransformiBeaconHackathon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface ParkHereAPI : AFHTTPRequestOperationManager

+ (ParkHereAPI *)sharedParkHereAPI;

- (void)getCarParkInformationUsingBeaconId:(NSString *)beaconId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
- (void)postCheckIntoParkingSpaceWithBeaconId:(NSString *)beaconId userPhone:(NSString *)phoneUUID success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure;
- (void)postCheckOutParkingSpaceWithBeaconId:(NSString *)beaconId userPhone:(NSString *)phoneUUID success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure;

@end
