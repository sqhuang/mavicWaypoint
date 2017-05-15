//
//  DJIGSButtonViewController.h
//  GSDemo
//
//  Created by OliverOu on 10/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DJIGSViewMode) {
    DJIGSViewMode_ViewMode,
    DJIGSViewMode_EditMode,
    DJIGSViewMode_WatchMode,
};

@class DJIGSButtonViewController;

@protocol DJIGSButtonViewControllerDelegate <NSObject>

- (void)stopBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)clearBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)focusMapBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)cameraBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)startBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)addBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)configBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)switchToMode:(DJIGSViewMode)mode inGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)captureBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)recordBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)modeflagBtn:(UIButton *)button withActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)loadpathBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;
- (void)pathgoBtnActionInGSButtonVC:(DJIGSButtonViewController *)GSBtnVC;

@end

@interface DJIGSButtonViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *focusMapBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *configBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *captureBtn;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *modeflagBtn;
@property (weak, nonatomic) IBOutlet UIButton *loadpathBtn;
@property (weak, nonatomic) IBOutlet UIButton *pathgoBtn;

@property (assign, nonatomic) DJIGSViewMode mode;
@property (weak, nonatomic) id <DJIGSButtonViewControllerDelegate> delegate;

- (IBAction)backBtnAction:(id)sender;
- (IBAction)stopBtnAction:(id)sender;
- (IBAction)clearBtnAction:(id)sender;
- (IBAction)focusMapBtnAction:(id)sender;
- (IBAction)editBtnAction:(id)sender;
- (IBAction)startBtnAction:(id)sender;
- (IBAction)addBtnAction:(id)sender;
- (IBAction)configBtnAction:(id)sender;
- (IBAction)cameraBtnAction:(id)sender;
- (IBAction)captureBtnAction:(id)sender;
- (IBAction)recordBtnAction:(id)sender;
- (IBAction)modeflagBtnAction:(id)sender;
- (IBAction)loadpathBtnAction:(id)sender;
- (IBAction)pathgoBtnAction:(id)sender;

@end
