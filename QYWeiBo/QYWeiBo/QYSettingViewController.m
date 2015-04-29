//
//  QYSettingViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-11.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYSettingViewController.h"
#import "QYAccountInfo.h"
#import "Common.h"

@interface QYSettingViewController ()

@end

@implementation QYSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([[QYAccountInfo shareAccountInfo] isLogin]){
        self.logoutButton.hidden = NO;
    }else{
        self.logoutButton.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)logout:(id)sender {
    [[QYAccountInfo shareAccountInfo] deleteAccoutInfo];
    
    [self.navigationController popViewControllerAnimated:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogout object:nil];
}

@end
