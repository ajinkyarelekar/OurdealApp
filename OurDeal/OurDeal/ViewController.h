//
//  ViewController.h
//  OurDeal
//
//  Created by Nanostuffs on 7/21/14.
//  Copyright (c) 2014 Ajinkya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *txtUserName;
@property (strong, nonatomic) IBOutlet UIWebView *FAQview;
@property (strong, nonatomic) IBOutlet UIButton *hideFAQ;
- (IBAction)BtnloginClicked:(id)sender;
- (IBAction)forgotUsername:(id)sender;
- (IBAction)readFAQ:(id)sender;
- (IBAction)hideFAQ:(id)sender;
@end
