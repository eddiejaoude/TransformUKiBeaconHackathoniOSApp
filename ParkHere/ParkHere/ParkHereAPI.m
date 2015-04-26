//
//  ParkHereAPI.m
//  ParkHere
//
//  Created by Alexandre JACQUEMOT on 26/04/2015.
//  Copyright (c) 2015 TransformiBeaconHackathon. All rights reserved.
//

#import "ParkHereAPI.h"

static NSString * const ParkHereAPIURLString = @"https://transform2015-hackathon.herokuapp.com";

static NSString * const PHJSON_BEACON = @"beacon";
static NSString * const PHJSON_PHONE = @"phone";
static NSString * const PHJSON_UUID = @"uid";


@implementation ParkHereAPI

+ (ParkHereAPI *)sharedParkHereAPI;
{
    static ParkHereAPI *_sharedParkHereAPI = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedParkHereAPI = [[self alloc] initWithBaseURL:[NSURL URLWithString:ParkHereAPIURLString]];
    });
    
    return _sharedParkHereAPI;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

- (void)getCarParkInformationUsingBeaconId:(NSString *)beaconId success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    NSString *GETRequestString = [NSString stringWithFormat:@"%@/api/parkings/%@/spaces", ParkHereAPIURLString, beaconId];
    
    [self GET:GETRequestString parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          success(responseObject);
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          failure(error);
      }];
}

- (void)postCheckIntoParkingSpaceWithBeaconId:(NSString *)beaconId userPhone:(NSString *)phoneUUID success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    NSString *POSTRequestString = [NSString stringWithFormat:@"%@/api/parkings/checks/ins", ParkHereAPIURLString];
    NSDictionary *parameters = @{PHJSON_PHONE: @{PHJSON_UUID: phoneUUID},
                                 PHJSON_BEACON: @{PHJSON_UUID: beaconId}};
    
    [self POST:POSTRequestString parameters:parameters
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           success(responseObject);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           failure(error);
       }];
}

- (void)postCheckOutParkingSpaceWithBeaconId:(NSString *)beaconId userPhone:(NSString *)phoneUUID success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    NSString *POSTRequestString = [NSString stringWithFormat:@"%@/api/parkings/checks/outs", ParkHereAPIURLString];
    NSDictionary *parameters = @{PHJSON_PHONE: @{PHJSON_UUID: phoneUUID},
                                 PHJSON_BEACON: @{PHJSON_UUID: beaconId}};
    
    [self POST:POSTRequestString parameters:parameters
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           success(responseObject);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           failure(error);
       }];
}

@end
