//
//  ScanViewController.m
//  OurDeal
//
//  Created by Nanostuffs on 7/21/14.
//  Copyright (c) 2014 Ajinkya. All rights reserved.
//

#import "ScanViewController.h"

@interface ScanViewController ()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) IBOutlet UIImageView *statusView;

-(BOOL)startReading;
-(void)stopReading;
-(void)loadBeepSound;

@end

@implementation ScanViewController
{
    NSArray *ImageArray;
    UIAlertView *LoadingAlt;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LoadingAlt=[[UIAlertView alloc]initWithTitle:@"Verifying Voucher" message:@"Please Wait" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];

    IsMenuVisible=NO;
	// Do any additional setup after loading the view, typically from a nib.
    
    // Initially make the captureSession object nil.
    _captureSession = nil;
    
    // Set the initial value of the flag to NO.
    _isReading = NO;
    
    // Begin loading the sound effect so to have it ready for playback when it's needed.
    [self loadBeepSound];
    [self addLoginView:self.view];
    ImageArray=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"sidemenuicon.png"],[UIImage imageNamed:@"logout_n.png"],[UIImage imageNamed:@"faq_n.png"], nil];
    [self startReading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private method implementation

- (BOOL)startReading
{
    NSError *error;
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input)
    {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    NSArray *arr=[[NSArray alloc]initWithObjects:AVMetadataObjectTypeQRCode, nil];
//    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    [captureMetadataOutput setMetadataObjectTypes:arr];
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    CALayer *MarkerLayer=[CALayer layer];
    MarkerLayer.contents=(id)[UIImage imageNamed:@"ScanMarker.png"].CGImage;
    MarkerLayer.frame=CGRectMake(40, 77, 240, 240);
    [_videoPreviewLayer addSublayer:MarkerLayer];
    
    // Start video capture.
    [_captureSession startRunning];
    
    return YES;
}


-(void)stopReading
{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    
    [_videoPreviewLayer performSelectorOnMainThread:@selector(removeFromSuperlayer) withObject:nil waitUntilDone:YES];
    
//    [_videoPreviewLayer removeFromSuperlayer];
}


-(void)loadBeepSound
{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    
    NSError *error;
    
    // Initialize the audio player object using the NSURL object previously set.
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_videoPreviewLayer transformedMetadataObjectForMetadataObject:metadataObj];
        
        float x1,y1,x2,y2,x3,y3,x4,y4;
        
        x1=[[[transformed.corners objectAtIndex:0]valueForKey:@"X"]floatValue];
        y1=[[[transformed.corners objectAtIndex:0]valueForKey:@"Y"]floatValue];
        x2=[[[transformed.corners objectAtIndex:1]valueForKey:@"X"]floatValue];
        y2=[[[transformed.corners objectAtIndex:1]valueForKey:@"Y"]floatValue];
        x3=[[[transformed.corners objectAtIndex:2]valueForKey:@"X"]floatValue];
        y3=[[[transformed.corners objectAtIndex:2]valueForKey:@"Y"]floatValue];
        x4=[[[transformed.corners objectAtIndex:3]valueForKey:@"X"]floatValue];
        y4=[[[transformed.corners objectAtIndex:3]valueForKey:@"Y"]floatValue];
        
        if (x1>40 && y1>77 && x2>40 && y2<317 && x3<280 && y3>77 && x4<280 && y4<317)
        {
            if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
            {
                NSString *Qrdata=[metadataObj stringValue];
                
                NSArray *split=[Qrdata componentsSeparatedByString:@"/"];
                NSString *Voucher=[split lastObject];
                
                [self stopReading];
                
                [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Processing request..." waitUntilDone:NO];
                
                [LoadingAlt performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                
                [self performSelectorOnMainThread:@selector(RedeemVoucherInBackground:) withObject:Voucher waitUntilDone:NO];
                
                _isReading = NO;
                
                if (_audioPlayer)
                {
                    [_audioPlayer play];
                }
            }
        }
    }
}

-(void)RedeemVoucherInBackground:(NSString*)Vouchercode
{
    [self performSelector:@selector(RedeemVoucher:) withObject:Vouchercode afterDelay:2.0];
}

-(void)RedeemVoucher:(NSString*)Vouchercode
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://staging-merchant.ourdeal.com.au/API/V1/voucher/%@/redeem",Vouchercode]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *contentType = [NSString stringWithFormat:@"Token token=\"%@\"",_userToken];
    [request addValue:contentType forHTTPHeaderField: @"Authorization"];
    
    NSData *data =[[NSData alloc]init];
    NSURLResponse *response;
    NSError *err=nil;
    
    data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    
    if(data)
    {
        NSError *error;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        BOOL status=[[responseDict valueForKey:@"success"] boolValue];
        if (status)
            
        {
            [self performSelector:@selector(showImageViewSuccessful) withObject:nil];
            [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Position the QR code inside the box" waitUntilDone:NO];
            [self performSelector:@selector(startReading) withObject:nil afterDelay:3.0];
            [self performSelector:@selector(hideImageViewSuccessful) withObject:nil afterDelay:3.0];
        }
        else
        {
            [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Position the QR code inside the box" waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(ShowAlertWithMessage:) withObject:responseDict waitUntilDone:YES];
        }
    }
    else
    {
        UIAlertView *SuccessAlt=[[UIAlertView alloc]initWithTitle:@"Oops!" message:@"We were unable to get in contact with the server. Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [SuccessAlt performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Position the QR code inside the box" waitUntilDone:NO];
    }
    [LoadingAlt dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)hideImageViewSuccessful
{
    [_statusView setHidden:YES];
}

-(void)showImageViewSuccessful
{
    [_statusView setHidden:NO];
}


-(void)addLoginView:(UIView*)view
{
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    [view addGestureRecognizer:rightRecognizer];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftRecognizer setNumberOfTouchesRequired:1];
    [view addGestureRecognizer:leftRecognizer];
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (!IsMenuVisible)
    {
        [self showLoginView:(UIView*)gestureRecognizer.view];
    }
}
- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (IsMenuVisible)
    {
        [self hideLoginView:(UIView*)gestureRecognizer.view];
    }
}
-(void)showLoginView:(UIView*)view
{
    IsMenuVisible=YES;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect viewframe=self.Topview.frame;
        
        viewframe.origin.x=self.Topview.frame.origin.x+_MenuView.frame.size.width;
        
        self.Topview.frame=viewframe;

    }];

    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame =  self.MenuView.frame;
        frame.origin.x = 0;
        [ self.MenuView setFrame:frame];
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hideLoginView:(UIView*)view
{
    IsMenuVisible=NO;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect viewframe=self.Topview.frame;
        
        viewframe.origin.x=0;
        
        self.Topview.frame=viewframe;
        
    }];

    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame =  self.MenuView.frame;
        frame.origin.x = - self.MenuView.frame.size.width;
        [ self.MenuView setFrame:frame];
    } completion:^(BOOL finished)
     {
     }];
}
-(void)animateViewAndShow:(BOOL)flag
{
    NSInteger moveTo;
    if (flag)//show login view
    {
        moveTo = 0;
    }else
    {
        moveTo = - self.MenuView.frame.size.width;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame =  self.MenuView.frame;
        frame.origin.x = moveTo;
        [ self.MenuView setFrame:frame];
        
    } completion:^(BOOL finished)
    {
        
    }];
    
}

- (IBAction)MenubtnClicked:(id)sender
{
    if (_FAQView.hidden==NO)
    {
        _FAQView.hidden=YES;
    }
    else
    {
        if (!IsMenuVisible)
        {
            [self showLoginView:self.view];
        }
        else
        {
            [self hideLoginView:self.view];
        }
    }
}

- (IBAction)logoutBtnClicked:(id)sender
{
    [self hideLoginView:self.view];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)FAQBtnClicked:(id)sender
{
    [self hideLoginView:self.view];
    _FAQView.hidden=NO;
    
    [self.view bringSubviewToFront:_FAQView];
    [_FAQView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://merchant.ourdeal.com.au/FAQs"]]];
}


-(void)ShowAlertWithMessage:(NSDictionary*)dict
{
    NSString *msg=[dict valueForKey:@"message"];
    
    NSString *status=msg;
    
    dict = [dict valueForKey:@"voucher"];
    NSString *datestr=[dict valueForKey:@"DateRedeemed"];
    NSString *dateRefunded=[dict valueForKey:@"DateRefunded"];
    NSArray *splitrefund,*split;
    
    if (![datestr isEqual:[NSNull null]])
    {
        split=[datestr componentsSeparatedByString:@"T"];
        datestr=[split firstObject];
    }
    
    if (![dateRefunded isEqual:[NSNull null]])
    {
        splitrefund=[dateRefunded componentsSeparatedByString:@"T"];
        dateRefunded=[splitrefund firstObject];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    
    NSDate *date,*refundate;
    
    if (split)
    {
        date = [dateFormatter dateFromString:[[[split lastObject]componentsSeparatedByString:@"+"] firstObject]];
    }
    
    if (splitrefund)
    {
        NSString *temp=[[[splitrefund lastObject]componentsSeparatedByString:@"+"] firstObject];
        
        refundate=[dateFormatter dateFromString:temp];
        refundate=[dateFormatter dateFromString:[[[splitrefund lastObject]componentsSeparatedByString:@"+"] firstObject]];
    }
    
    dateFormatter.dateFormat = @"hh:mm a";
    
    NSString *pmamDateString;
    NSString *datestrRefundatepmam;
    if (date)
    {
        pmamDateString = [dateFormatter stringFromDate:date];
        pmamDateString=[pmamDateString stringByAppendingString:[NSString stringWithFormat:@" %@",datestr]];
    }
    
    
    if (refundate)
    {
        datestrRefundatepmam=[dateFormatter stringFromDate:refundate];
        datestrRefundatepmam=[datestrRefundatepmam stringByAppendingString:[NSString stringWithFormat:@" %@",dateRefunded]];
    }
    
    NSString *redeemdby=[dict valueForKey:@"RedeemedUserName"];
    
    if ([redeemdby isEqual:[NSNull null]])
    {
        redeemdby=@"-";
    }

    if ([status isEqualToString:@"Voucher has already been redeemed."])
    {
        
        msg=[msg stringByAppendingString:[NSString stringWithFormat:@"\nTime Redeemed: %@\nRedeemed By User: %@",pmamDateString,redeemdby]];
        
    }
    else if ([status rangeOfString:@"Could not find voucher code"].location != NSNotFound)
    {
        msg=@"Invalid voucher. Could not find voucher code";
    }
    else if ([status isEqualToString:@"Redeeming a refunded voucher is not permitted."])
    {
        if (!pmamDateString)
        {
            pmamDateString=@"-";
        }
        msg=[msg stringByAppendingString:[NSString stringWithFormat:@"\nTime Redeemed: %@\nTime Refunded: %@\n",pmamDateString,datestrRefundatepmam]];
    }
    else if ([status isEqualToString:@"The Pin you provided does not match with the Pin we have for this Voucher."])
    {
        msg=[msg stringByAppendingString:[NSString stringWithFormat:@"\nTime Redeemed: %@\nRedeemed By User: %@",pmamDateString,redeemdby]];
    }
    
    UIView *customAlt=[[UIView alloc]init];
    UILabel *msglbl =[[UILabel alloc]init];
    [msglbl setNumberOfLines:10];
    
    [customAlt setFrame:CGRectMake(0, 0, 290, 150)];
    
    UILabel *oopslabl=[[UILabel alloc]initWithFrame:CGRectMake(85, 20, 100, 20)];
    
    oopslabl.font=[UIFont boldSystemFontOfSize:17];
    oopslabl.text=@"Oops!";
    oopslabl.textAlignment=NSTextAlignmentCenter;
    
    [customAlt addSubview:oopslabl];
    
    [msglbl setFrame:CGRectMake(15, 0, 270, 170)];
    msglbl.font=[UIFont systemFontOfSize:14];
    msglbl.text=msg;
    [customAlt addSubview:msglbl];
    
    CustomIOS7AlertView *altc=[[CustomIOS7AlertView alloc]init];
    [altc setContainerView:customAlt];
    [altc setButtonTitles:@[@"OK"]];
    [altc setDelegate:self];
    [altc setUseMotionEffects:YES];
    [altc show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Position the QR code inside the box" waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(startReading) withObject:nil waitUntilDone:NO];
    [alertView close];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Position the QR code inside the box" waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(startReading) withObject:nil waitUntilDone:NO];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideLoginView:self.view];
}
@end
