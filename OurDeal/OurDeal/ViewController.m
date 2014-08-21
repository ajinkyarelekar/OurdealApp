//
//  ViewController.m
//  OurDeal
//
//  Created by Nanostuffs on 7/21/14.
//  Copyright (c) 2014 Ajinkya. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
#import "ScanViewiOS6ViewController.h"
#import "AppDelegate.h"
@interface ViewController ()
{
    AppDelegate *delegate;
}
@end

@implementation ViewController
{
    UIAlertView *LoadingAlt;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    delegate =[[UIApplication sharedApplication]delegate];
	// Do any additional setup after loading the view, typically from a nib.
    LoadingAlt=[[UIAlertView alloc]initWithTitle:@"Authenticating" message:@"Please Wait" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.frame=CGRectMake(self.view.frame.origin.x,-100, self.view.frame.size.width, self.view.frame.size.height-20);
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame=CGRectMake(self.view.frame.origin.x,0, self.view.frame.size.width, self.view.frame.size.height+20);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)performLogin
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    if (self.txtUserName.text!=nil && ![self.txtUserName.text isEqualToString:@""])
    {
        NSString *loginStr=[self.txtUserName.text stringByAppendingString:@":XU8KNZWvU5jgj7p"];
        NSData *plainData = [loginStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String=[plainData base64Encoding];
        
        NSString *token=(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)base64String, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
        
        NSURL *url=[NSURL URLWithString:@"https://staging-merchant.ourdeal.com.au/API/V1/auth/token"];
        
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPMethod:@"POST"];
        
        NSString *contentType = [NSString stringWithFormat:@"Token token=\"%@\"",token];
        [request addValue:contentType forHTTPHeaderField: @"Authorization"];
        request.timeoutInterval=15.0;
        
        NSData *data =[[NSData alloc]init];
        NSURLResponse *response;
        NSError *err=nil;
        
        data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        [LoadingAlt dismissWithClickedButtonIndex:0 animated:YES];
        if(data)
        {
            NSError *error;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            BOOL status=[[responseDict valueForKey:@"success"] boolValue];
            if (status)
            {
                if ([[[[[UIDevice currentDevice]systemVersion]componentsSeparatedByString:@"."] firstObject]intValue]>=7)
                {
                    ScanViewController *nextVC = [storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
                    nextVC.userToken=token;
                    [self performSelectorOnMainThread:@selector(showScannerView:) withObject:nextVC waitUntilDone:NO];
                }
                else
                {
                    delegate.username=base64String;
                    
                    ScanViewiOS6ViewController *nextVCiOS6=[storyboard instantiateViewControllerWithIdentifier:@"ScanViewiOS6ViewController"];
                    nextVCiOS6.userToken=token;
                    [self performSelectorOnMainThread:@selector(showScanViewiOS6ViewController:) withObject:nextVCiOS6 waitUntilDone:NO];
                }
                _txtUserName.text=@"";
            }
            else
            {
                [self ShowAlertWithMessage:@"Invalid username. User not authenticated"];
            }
        }
        else
        {
            [self ShowAlertWithMessage:@"We were unable to get in contact with the server. Please try again."];
        }
        
    }
    else
    {
        [LoadingAlt dismissWithClickedButtonIndex:0 animated:YES];
        [self performSelectorOnMainThread:@selector(ShowAlertWithMessage:) withObject:@"Please Enter Username" waitUntilDone:YES];
    }
}

-(void)ShowAlertWithMessage:(NSString*)msg
{
    UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Oops!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alt performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];// show];
}

- (IBAction)BtnloginClicked:(id)sender
{
    [self.view endEditing:YES];
    [LoadingAlt show];
    
    [self performSelectorInBackground:@selector(performLogin) withObject:nil];
}

- (IBAction)forgotUsername:(id)sender
{
    
}

- (IBAction)readFAQ:(id)sender
{
    _FAQview.hidden=NO;
    [_FAQview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://merchant.ourdeal.com.au/FAQs"]]];
    [self showLoginView];
    _hideFAQ.hidden=NO;
}

- (IBAction)hideFAQ:(id)sender
{
    [self hideLoginView];
    _hideFAQ.hidden=YES;
}

-(void)showScannerView:(ScanViewController*)nextVC
{
    [self presentViewController:nextVC animated:YES completion:nil];
}

-(void)showScanViewiOS6ViewController:(ScanViewiOS6ViewController*)nextVC
{
    [self presentViewController:nextVC animated:YES completion:nil];
}

-(void)showLoginView
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect viewframe=_FAQview.frame;
        
        viewframe.origin.x=0;
        
        _FAQview.frame=viewframe;
        
    }];
}

-(void)hideLoginView
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect viewframe=_FAQview.frame;
        
        viewframe.origin.x=-_FAQview.frame.size.width;
        
        _FAQview.frame=viewframe;
        
    }];
}

@end
