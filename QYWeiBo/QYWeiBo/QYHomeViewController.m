//
//  QYHomeViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QYHomeViewController.h"
#import "AFNetworking.h"
#import "Common.h"
#import "QYAccountInfo.h"
#import "QYWeiBoCell.h"
#import "QYTwitterFooterView.h"
#import "QYTwitter.h"
#import "QYDataBaseEngine.h"
#import "QYUser.h"
#import "QYTwitterController.h"
#import "QRCodeController.h"

@interface QYHomeViewController ()

@property (nonatomic ,strong)NSMutableArray *weiBoData;
@property (nonatomic , strong)QYWeiBoCell *tempCell;
@property (nonatomic)BOOL refreshing;

@end

@implementation QYHomeViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"首页";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"tabbar_home"] selectedImage:[UIImage imageNamed:@"tabbar_home_selected"]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        label.text = @"hello";
        label.textColor = [UIColor blackColor];
        self.navigationItem.titleView = label;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"QRCode" style:UIBarButtonItemStyleBordered target:self action:@selector(qrCode)];
    self.navigationItem.rightBarButtonItem = right;
    
    //从数据库查询数据
    
    NSArray *twitter = [QYDataBaseEngine selectTwitterFromDB];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"twitterData.created_at" ascending:NO];
    
    twitter = [twitter sortedArrayUsingDescriptors:@[sort]];
//    twitter = [twitter sortedArrayUsingFunction:intSort context:nil];
    self.weiBoData = [NSMutableArray arrayWithArray:twitter];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTwitter:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"QYWeiBoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"QYWeiBoCell"];
    
    //注册footerView;
    [self.tableView registerNib:[UINib nibWithNibName:@"TwitterFooterView" bundle:[NSBundle mainBundle]] forHeaderFooterViewReuseIdentifier:@"FooterView"];
    
    self.tempCell = [[[NSBundle mainBundle] loadNibNamed:@"QYWeiBoCell4Height" owner:nil options:nil] objectAtIndex:0];
//    self.tempCell = [self.tableView dequeueReusableCellWithIdentifier:@"QYWeiBoCell"];
    //从网路请求数据
    [self loadData];
    
}

NSInteger intSort(id num1, id num2, void *context)
{
    return [[num2 twitterData].created_at compare:[num1 twitterData].created_at];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom

-(void)loadData{
    
    if (self.refreshing == YES) {
        return;
    }
    self.refreshing = YES;
    if (![[QYAccountInfo shareAccountInfo] isLogin]) {
        return;
    }
    NSString *urlString = [kBaseUrl stringByAppendingPathComponent:@"statuses/home_timeline.json"];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[[QYAccountInfo shareAccountInfo] token] forKey:access_token];
    [dictionary setObject:@20 forKey:@"count"];
    if (self.weiBoData.count > 0) {
        [dictionary setObject:[[self.weiBoData.firstObject twitterData] twitterId] forKey:@"since_id"];
    }
    
//    NSDictionary *paras = @{access_token:[[QYAccountInfo shareAccountInfo] token], @"count":@5 @"since_id":};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", operation.responseObject);
        NSArray *weibos = [responseObject objectForKey:@"statuses"];
        
        NSMutableArray *twitterArray = [NSMutableArray array];
        for (NSDictionary *twitter in weibos) {
            [twitterArray addObject:[[QYTwitter alloc]initWithDictionary:twitter]];
        }
        if (self.weiBoData) {
            [twitterArray addObjectsFromArray:self.weiBoData];
        }
        self.weiBoData = twitterArray;
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
        [QYDataBaseEngine saveTwitterToDatabase:weibos];
        self.refreshing = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        NSLog(@"responseString:????%@", operation.responseString);
        self.refreshing = NO;
    }];
}

-(void)loadMoreTwitter{
    if (![[QYAccountInfo shareAccountInfo] isLogin]) {
        return;
    }
    self.refreshing = YES;
    NSString *urlString = [kBaseUrl stringByAppendingPathComponent:@"statuses/home_timeline.json"];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[[QYAccountInfo shareAccountInfo] token] forKey:access_token];
    [dictionary setObject:@20 forKey:@"count"];
    if (self.weiBoData.count > 0) {
        [dictionary setObject:[[self.weiBoData.lastObject twitterData] twitterId] forKey:@"max_id"];
    }
    
    //    NSDictionary *paras = @{access_token:[[QYAccountInfo shareAccountInfo] token], @"count":@5 @"since_id":};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", operation.responseObject);
        NSArray *weibos = [responseObject objectForKey:@"statuses"];
        
        NSMutableArray *twitterArray = [NSMutableArray array];
        for (NSDictionary *twitter in weibos) {
            [twitterArray addObject:[[QYTwitter alloc]initWithDictionary:twitter]];
        }
        
        if (!self.weiBoData) {
            self.weiBoData = [NSMutableArray array];
        }
        
        if (self.weiBoData.count > 0) {
            QYTwitter *lastTwitter = self.weiBoData.lastObject;
            QYTwitter *fistTwitter = twitterArray.firstObject;
            if ([lastTwitter.twitterData.twitterId isEqualToString:fistTwitter.twitterData.twitterId]) {
                [twitterArray removeObjectAtIndex:0];
            }
        }
        
        [self.weiBoData addObjectsFromArray:twitterArray];
        [self.tableView reloadData];
        
        [QYDataBaseEngine saveTwitterToDatabase:weibos];
        self.refreshing = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        self.refreshing = NO;
    }];

}

#pragma mark - action

-(void)qrCode{
    QRCodeController *qrCodeVC = [[QRCodeController alloc] init];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:qrCodeVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

-(void)refreshTwitter:(id)sender{
    NSLog(@"refresh");
    
    [self loadData];
}

-(void)showPersionInfo:(id)sender{
//    UIButton *button = (UIButton *)sender;
//    NSInteger section = button.tag;
//    NSDictionary *twitterInfo = self.weiBoData[section];
//    NSDictionary *userInfo = twitterInfo[@"user"];
//    NSLog(@"%@", userInfo[@"name"]);
}

-(void)sectionFooterAction:(id)sender{
    
}

-(void)retwitter:(id)sender{
    
}

-(void)comment:(id)sender{
    
}

-(void)likeTwiter:(id)sender{
    
}

#pragma mark - table view DataSource Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.weiBoData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QYWeiBoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QYWeiBoCell" forIndexPath:indexPath];
    
//    //取出cell。contentVIew的所有约束，遍历查找符合条件的，并且移除
    NSArray *contraints = cell.contentView.constraints;
    for (NSLayoutConstraint *contraint in contraints) {
        if (contraint.firstItem == cell.transmitImage && contraint.firstAttribute == NSLayoutAttributeBottom) {
            [cell.contentView removeConstraint:contraint];
        }
    }
    
    [cell setTwitterData:self.weiBoData[indexPath.section]];
    
    [cell.nickNameLabel addTarget:self action:@selector(showPersionInfo:) forControlEvents:UIControlEventTouchUpInside];
    cell.nickNameLabel.tag = indexPath.section;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //当剩余没有显示的cell剩余5条的时候，加载更多
    if (self.weiBoData.count - indexPath.section < 5) {
        [self loadMoreTwitter];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QYWeiBoCell *cell = self.tempCell;
    QYTwitter *tweeted = self.weiBoData[indexPath.section];
    CGFloat height = [cell cellHeight4TwitterData:tweeted];
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30.f;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    QYTwitterFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"FooterView"];
    
    QYTwitter *twitter = [self.weiBoData objectAtIndex:section];
    [footerView.retwitterButton setTitle:[@(twitter.twitterData.reposts_count) stringValue] forState:UIControlStateNormal];
    footerView.retwitterButton.tag = section;
    [footerView.retwitterButton addTarget:self action:@selector(retwitter:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView.commentButton setTitle:[@(twitter.twitterData.comments_count) stringValue] forState:UIControlStateNormal];
    [footerView.commentButton setTag:section];
    [footerView.commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView.likeButton setTitle:[@(twitter.twitterData.attitudes_count) stringValue] forState:UIControlStateNormal];
    [footerView.likeButton setTag:section];
    [footerView.likeButton addTarget:self action:@selector(likeTwiter:) forControlEvents:UIControlEventTouchUpInside];
    
    return footerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QYTwitter *twitter = self.weiBoData[indexPath.section];
    QYTwitterController *twitterVC = [[QYTwitterController alloc] init];
    twitterVC.hidesBottomBarWhenPushed = YES;
    twitterVC.twitter = twitter;
    [self.navigationController pushViewController:twitterVC animated:YES];
    
}

@end
