//
//  ViewController.m
//  ParkHere
//
//  Created by Alexandre JACQUEMOT on 25/04/2015.
//  Copyright (c) 2015 TransformiBeaconHackathon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage* logoImage = [UIImage imageNamed:@"park_here"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
    logoView.frame = CGRectMake(0, 0, logoImage.scale*44.0, 44.0);
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
