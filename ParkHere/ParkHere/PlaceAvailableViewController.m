//
//  PlaceAvailableViewController.m
//  ParkHere
//
//  Created by Alexandre JACQUEMOT on 25/04/2015.
//  Copyright (c) 2015 TransformiBeaconHackathon. All rights reserved.
//

#import "PlaceAvailableViewController.h"

static NSString * const cellIdentifier = @"placeAvailableCell";

@interface PlaceAvailableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayOfPlacesAvailable;

@end

@implementation PlaceAvailableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage* logoImage = [UIImage imageNamed:@"park_here"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
    logoView.frame = CGRectMake(0, 0, logoImage.scale*44.0, 44.0);
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoView;
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_button"] style:UIBarButtonItemStyleDone target:self action:@selector(goToPreviousView:)];
    [leftBarButton setTintColor:[UIColor colorWithRed:241.0/255.0 green:91.0/255.0 blue:91.0/255.0 alpha:1.0]];
    self.navigationItem.leftBarButtonItem = leftBarButton;
}

- (void)goToPreviousView:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayOfPlacesAvailable.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
