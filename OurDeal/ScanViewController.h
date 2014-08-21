//
//  ScanViewController.h
//  OurDeal
//
//  Created by Nanostuffs on 7/21/14.
//  Copyright (c) 2014 Ajinkya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomIOS7AlertView.h"


@interface ScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,CustomIOS7AlertViewDelegate>
{
    BOOL IsMenuVisible;
}
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIView *MenuView;
@property (strong, nonatomic) IBOutlet UIButton *menuBtn;
@property (strong, nonatomic) IBOutlet UIView *Topview;
@property (strong, nonatomic) IBOutlet UIWebView *FAQView;
@property (strong, nonatomic) IBOutlet UILabel *statusLable;

@property (strong ,nonatomic) NSString *userToken;
- (IBAction)MenubtnClicked:(id)sender;
- (IBAction)logoutBtnClicked:(id)sender;
- (IBAction)FAQBtnClicked:(id)sender;
@end
