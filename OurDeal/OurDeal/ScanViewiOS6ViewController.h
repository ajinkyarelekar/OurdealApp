//
//  ScanViewiOS6ViewController.h
//  OurDeal
//
//  Created by Nanostuffs on 7/25/14.
//  Copyright (c) 2014 Ajinkya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
@interface ScanViewiOS6ViewController : UIViewController<ZBarReaderDelegate,ZBarReaderViewDelegate>
{ 
    BOOL IsMenuVisible;
    ZBarReaderViewController *reader;
    ZBarReaderView *readerView;
}
@property (nonatomic, retain) UIImagePickerController *imgPicker;
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIView *MenuView;
@property (strong, nonatomic) IBOutlet UIButton *menuBtn;
@property (strong, nonatomic) IBOutlet UIView *Topview;
@property (strong, nonatomic) IBOutlet UIWebView *FAQView;
@property (strong, nonatomic) IBOutlet UILabel *statusLable;
@property (strong ,nonatomic) NSString *userToken;
@property (strong, nonatomic) IBOutlet UIImageView *statusView;


- (IBAction)MenubtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)FAQBtnClicked:(id)sender;

-(void)StartScan;
-(void)stopScan;

@end
