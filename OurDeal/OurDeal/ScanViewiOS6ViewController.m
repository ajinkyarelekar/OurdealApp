//
//  ScanViewiOS6ViewController.m
//  OurDeal
//
//  Created by Nanostuffs on 7/25/14.
//  Copyright (c) 2014 Ajinkya. All rights reserved.
//

#import "ScanViewiOS6ViewController.h"
#import "AppDelegate.h"
@interface ScanViewiOS6ViewController ()

@end

@implementation ScanViewiOS6ViewController
{
    NSArray *ImageArray;
    UIAlertView *LoadingAlt;
    
    AppDelegate *delegate;
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
    delegate=[[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view.
    
    [self addLoginView:self.view];
    
    LoadingAlt=[[UIAlertView alloc]initWithTitle:@"Verifying Voucher" message:@"Please Wait" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self StartScan];
    
}
-(void)StartScan
{
    
    readerView =[[ZBarReaderView alloc]init];
    
    [readerView setFrame:_viewPreview.frame];
    
    [readerView.scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    readerView.readerDelegate = self;
    
    UIImageView *MarkerLayer=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ScanMarker.png"]];;
    MarkerLayer.frame=CGRectMake(40, 35, 240, 240);
    [readerView addSubview:MarkerLayer];
    
    readerView.torchMode=0;
    
    //////////////////////////////  y     x     h     w
    readerView.scanCrop=CGRectMake(0.21, 0.16, 0.52, 0.69);
    readerView.tracksSymbols=NO;
    
    readerView.trackingColor=[UIColor clearColor];
    
    
    [self.view addSubview:readerView];
    
    [readerView start];
    
}

-(void)stopScan
{
//    reader = nil;
//    [reader.view removeFromSuperview];
    [readerView removeFromSuperview];
    readerView=nil;
}

- (void) readerControllerDidFailToRead:(ZBarReaderController*)reader withRetry:(BOOL)retry
{
    NSLog(@"the image picker failing to read");
}

- (void)readerView:(ZBarReaderView *)view didReadSymbols: (ZBarSymbolSet *)syms fromImage:(UIImage *)img
{
    NSString *hiddenData;
    for(ZBarSymbol *sym in syms)
        hiddenData=[NSString stringWithString:sym.data];
    
    NSArray *split=[hiddenData componentsSeparatedByString:@"/"];
    NSString *Voucher=[split lastObject];
    
    [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Processing request..." waitUntilDone:NO];
    [LoadingAlt performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    
    [self performSelectorOnMainThread:@selector(stopScan) withObject:nil waitUntilDone:YES];
//    [self stopScan];
    
    [self performSelectorOnMainThread:@selector(RedeemVoucherInBackground:) withObject:Voucher waitUntilDone:NO];

    
}
- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    id results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    NSString *hiddenData;
    
    for(symbol in results)
        hiddenData=[NSString stringWithString:symbol.data];
    
    NSArray *split=[hiddenData componentsSeparatedByString:@"/"];
    NSString *Voucher=[split lastObject];

    [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Processing request..." waitUntilDone:NO];
    [LoadingAlt performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    [self stopScan];

    [self performSelectorOnMainThread:@selector(RedeemVoucherInBackground:) withObject:Voucher waitUntilDone:NO];
}

-(void)RedeemVoucherInBackground:(NSString*)Voucher
{
    [self performSelector:@selector(RedeemVoucher:) withObject:Voucher afterDelay:2.0];
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
        
        NSLog(@"%@",responseDict);
        
        BOOL status=[[responseDict valueForKey:@"success"] boolValue];
        if (status)
            
        {
            [self performSelector:@selector(showImageViewSuccessful) withObject:nil];
            [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Position the QR code inside the box" waitUntilDone:NO];
            [self performSelector:@selector(StartScan) withObject:nil afterDelay:3.0];
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
        UIAlertView *SuccessAlt=[[UIAlertView alloc]initWithTitle:@"Oops!" message:@"We were unable to contact the server. Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [SuccessAlt performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Position the QR code inside the box" waitUntilDone:NO];
    }
    [LoadingAlt performSelectorOnMainThread:@selector(dismissWithClickedButtonIndex:animated:) withObject:0 waitUntilDone:NO];
}
-(void)hideImageViewSuccessful
{
    [_statusView setHidden:YES];
}

-(void)showImageViewSuccessful
{
    [_statusView setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [self.view bringSubviewToFront:_MenuView];
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
    if (flag)
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
    
    UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"                      Oops!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    dict = [dict valueForKey:@"voucher"];
    //    NSLog(@"%@",dict);
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
//    NSString *redeemtionSource=@"Merchant portal app";
    
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
        if ([redeemdby isEqual:[NSNull null]])
        {
            redeemdby=@"-";
        }
        msg=[msg stringByAppendingString:[NSString stringWithFormat:@"\nTime Redeemed: %@\nTime Refunded: %@\n",pmamDateString,datestrRefundatepmam]];
    }
    else if ([status isEqualToString:@"The Pin you provided does not match with the Pin we have for this Voucher."])
    {
        msg=[msg stringByAppendingString:[NSString stringWithFormat:@"\nTime Redeemed: %@\nRedeemed By User: %@",pmamDateString,redeemdby]];
    }
    alt.message=msg;
    
    NSArray *subViewArray = alt.subviews;
    for(int x = 0; x < [subViewArray count]; x++)
    {
        
        //If the current subview is a UILabel...
        if([[[subViewArray objectAtIndex:x] class] isSubclassOfClass:[UILabel class]])
        {
            UILabel *label = [subViewArray objectAtIndex:x];
            label.textAlignment =NSTextAlignmentLeft;
        }
    }
    [alt show];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [_statusLable performSelectorOnMainThread:@selector(setText:) withObject:@"Position the QR code inside the box" waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(StartScan) withObject:nil waitUntilDone:NO];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideLoginView:self.view];
}
@end
