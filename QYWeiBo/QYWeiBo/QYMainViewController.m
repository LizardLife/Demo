//
//  QYMainViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

//初始化控制器
//tabbarItem
//做一个加号按钮，
//moreController的展示方式

#import "QYMainViewController.h"
#import "QYHomeViewController.h"
#import "QYMessageViewController.h"
#import "QYMoreViewController.h"
#import "QYFindViewController.h"
#import "QYMeViewController.h"
#import "Common.h"
#import "LoginViewController.h"



@interface QYMainViewController ()

@end

@implementation QYMainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLogout object:nil];
}

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
    // Do any additional setup after loading the view.
    [self installViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:kLogout object:nil];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

-(void)logout:(NSNotification*)notification{
    self.selectedIndex = 3;
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - custom

-(void)installViewController{
    QYHomeViewController *homeVC = [[QYHomeViewController alloc] init];
    UINavigationController *homeNVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    QYMessageViewController *messageVC = [[QYMessageViewController alloc] init];
    UINavigationController *messageNVC = [[UINavigationController alloc] initWithRootViewController:messageVC];
    UIViewController *tempVC = [[UIViewController alloc] init];
    QYFindViewController *findVC = [[QYFindViewController alloc] init];
    UINavigationController *findNVC = [[UINavigationController alloc] initWithRootViewController:findVC];
    QYMeViewController *me = [[QYMeViewController alloc] init];
    UINavigationController *meNVC = [[UINavigationController alloc] initWithRootViewController:me];
    
    self.viewControllers = @[homeNVC, messageNVC, tempVC, findNVC, meNVC];
    self.tabBar.tintColor = [UIColor orangeColor];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
