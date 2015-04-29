//
//  LoginViewController.m
//  QYSinaOAuth
//
//  Created by qingyun on 14-12-8.
//  Copyright (c) 2014年 qingyun. All rights reserved.
//

#import "LoginViewController.h"
#import "Common.h"
#import "AFNetworking.h"
#import "QYAccountInfo.h"
#import "MBProgressHUD/MBProgressHUD.h"

@interface LoginViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"LoginView" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in storage.cookies) {
        [storage deleteCookie:cookie];
    }
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@", kAppKey, kRedirectURI]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)disMiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - webView delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"%@", request.URL);
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:kRedirectURI]) {
        NSRange range = [urlString rangeOfString:@"code="];
        NSRange codeRange = NSMakeRange(range.location + range.length, urlString.length - range.location - range.length);
        NSString *codeString = [urlString substringWithRange:codeRange];
        NSLog(@"%@", codeString);
        
        NSString *requestUrlString = @"https://api.weibo.com/oauth2/access_token";
        NSDictionary *pramas = @{@"client_id":kAppKey,
                                 @"client_secret" :kAppSecret,
                                 @"grant_type": @"authorization_code",
                                 @"redirect_uri":kRedirectURI,
                                 @"code":codeString};
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
        [manager POST:requestUrlString parameters:pramas success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccess" object:nil userInfo:responseObject];
            
            [[QYAccountInfo shareAccountInfo] saveLoginInfo:responseObject];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        return NO;
        
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

#pragma mark - action

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
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
