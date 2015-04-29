//
//  QRCodeController.m
//  QYWeiBo
//
//  Created by qingyun on 14-12-22.
//  Copyright (c) 2014年 河南青云. All rights reserved.
//

#import "QRCodeController.h"
#import <AVFoundation/AVFoundation.h>

@interface QRCodeController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong)AVCaptureDevice *device;
@property (nonatomic, strong)AVCaptureDeviceInput *input;
@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureMetadataOutput *output;

@property (nonatomic, strong)UIImageView *animationImageView;
@property (nonatomic, strong)NSTimer *timer;
@property (nonatomic,  strong)UIView *preView;



@end

@implementation QRCodeController

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
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = NO;
    self.preView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.preView];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = close;
    self.title = @"二维码";
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    
    UIImageView *boundImage = [[UIImageView alloc] initWithFrame:CGRectMake(40, 20, 240, 240)];
    UIImage * image = [UIImage imageNamed:@"qrcode_border"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 26, 26)];
    boundImage.image = image;
    [self.view addSubview:boundImage];
    boundImage.clipsToBounds = YES;
    
    self.animationImageView = [[UIImageView alloc] initWithFrame:boundImage.bounds];
    [self.animationImageView setImage:[UIImage imageNamed:@"qrcode_scanline_qrcode"]];
    [boundImage addSubview:self.animationImageView];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(changeImage:) userInfo:nil repeats:YES];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reading];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopRead];
}

//开始启用二维码扫描
-(void)reading{
    NSError *error;
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.session = session;
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (self.input) {
        [self.session addInput:self.input];
    }else{
        NSLog(@"%@",error);
        return;
    }
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [self.output setMetadataObjectsDelegate:self queue:queue];
    NSArray *types = [self.output availableMetadataObjectTypes];
    [self.output setMetadataObjectTypes:types];
    
    
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [layer setFrame:self.view.layer.bounds];
    
    
    UIGraphicsBeginImageContextWithOptions(self.preView.frame.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0, 0, 0, .4f);
    CGContextAddRect(context, self.preView.bounds);
    CGContextFillPath(context);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextAddRect(context,CGRectMake(40, 20, 240, 240));
    CGContextFillPath(context);
    
    UIImage *maskImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *maskLayer = [[CALayer alloc] init];
    maskLayer.bounds = self.preView.bounds;
    maskLayer.position = _preView.center;
    maskLayer.contents = (__bridge id)maskImage.CGImage;
//    maskLayer.opaque = YES;
    layer.mask = maskLayer;
    layer.masksToBounds = YES;
    [self.preView.layer addSublayer:layer];
    [self.session startRunning];
    
}

//停止二维码扫描的方法
-(void)stopRead{
    [self.session stopRunning];
}

-(void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)changeImage:(NSTimer *)timer{
    self.animationImageView.frame = CGRectOffset(self.animationImageView.frame, 0, 5);
    if (self.animationImageView.frame.origin.y >= self.animationImageView.frame.size.height - 120) {
        self.animationImageView.frame = CGRectMake(0, -self.animationImageView.frame.size.height , self.animationImageView.frame.size.width, self.animationImageView.frame.size.height);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"%@", [[metadataObjects firstObject] stringValue]);
    [self performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:YES];
    
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
