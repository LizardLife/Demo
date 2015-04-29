//
//  QYTableViewController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-21.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

//1.展示微博
//2.将微博的评论获取到,模型，存贮
//3.评论的ui先显示出来，高度计算，
//4.绑定ui和评论的内容，设置内容

#import "QYTwitterController.h"
#import "QYWeiBoCell.h"
#import "QYCommentCell.h"
#import "Common.h"
#import "QYAccountInfo.h"
#import "QYTwitter.h"
#import <AFNetworking.h>
#import "QYComment.h"


@interface QYTwitterController ()

@property (nonatomic, strong)NSMutableArray *commentData;//评论内容

@end

@implementation QYTwitterController

- (instancetype)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"QYWeiBoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"QYWeiBoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"QYCommentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"QYCommentCell"];
    
    [self loadComment];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)loadComment{
    //请求对应微博的评论内容；
    NSString *urlString = [kBaseUrl stringByAppendingPathComponent:@"comments/show.json"];
    QYAccountInfo *info = [QYAccountInfo shareAccountInfo];
    NSDictionary *piris = @{access_token:info.token, @"id": self.twitter.twitterData.twitterId, @"count": @50};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:piris success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        NSArray *comments = responseObject[@"comments"];
        NSMutableArray *commentsModelArray = [NSMutableArray arrayWithCapacity:comments.count];
        for (NSDictionary *info in comments) {
            [commentsModelArray addObject:[[QYComment alloc] initWirhDictionary:info]];
        }
        
        self.commentData = commentsModelArray;
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@", error);
        NSLog(@"responseString:%@", operation.responseString);
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }else
        return self.commentData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        QYWeiBoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QYWeiBoCell" forIndexPath:indexPath];
        [cell setTwitterData:self.twitter];
        return cell;
    }else{
        QYCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QYCommentCell" forIndexPath:indexPath];
        QYComment *comment = self.commentData[indexPath.row];
        [cell setComment:comment];
        return cell;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        QYWeiBoCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"QYWeiBoCell4Height" owner:nil options:nil] objectAtIndex:0];
        return [cell cellHeight4TwitterData:self.twitter];
    }else{
        QYCommentCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"QYCommentCell" owner:nil options:nil] objectAtIndex:0];
        QYComment *comment = self.commentData[indexPath.row];
        return [cell cellHeight4Comment:comment];
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/\

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
