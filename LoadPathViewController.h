//
//  LoadPathViewController.h
//  GSDemo
//
//  Created by qiu on 02/03/2017.
//  Copyright © 2017 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadPathViewController;
@protocol LoadPathViewControllerDelegte <NSObject>

- (void)goBtnActionInLoadPathViewController:(LoadPathViewController *)loadpathVC;

@end

@interface LoadPathViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *fileNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *samplefTextField;
@property (weak, nonatomic) IBOutlet UITextField *rTextField;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) id<LoadPathViewControllerDelegte>delegate;

- (IBAction)goBtnAction:(id)sender;

@end
