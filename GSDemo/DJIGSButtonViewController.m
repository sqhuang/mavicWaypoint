//
//  DJIGSButtonViewController.m
//  GSDemo
//
//  Created by OliverOu on 10/7/15.
//  Copyright (c) 2015 DJI. All rights reserved.
//

#import "DJIGSButtonViewController.h"

@implementation DJIGSButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setMode:DJIGSViewMode_ViewMode];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property Method

- (void)setMode:(DJIGSViewMode)mode
{
    
    _mode = mode;
    [_editBtn setHidden:(mode != DJIGSViewMode_ViewMode)];
    [_focusMapBtn setHidden:(mode != DJIGSViewMode_ViewMode)];
    [_cameraBtn setHidden:(mode == DJIGSViewMode_EditMode)];
    [_backBtn setHidden:(mode != DJIGSViewMode_EditMode)];
    [_clearBtn setHidden:(mode != DJIGSViewMode_EditMode)];
    [_startBtn setHidden:(mode != DJIGSViewMode_EditMode)];
    [_stopBtn setHidden:NO];
    [_addBtn setHidden:(mode != DJIGSViewMode_EditMode)];
    [_configBtn setHidden:(mode != DJIGSViewMode_EditMode)];
    [_captureBtn setHidden:(mode != DJIGSViewMode_WatchMode)];
    [_recordBtn setHidden:(mode != DJIGSViewMode_WatchMode)];
    [_modeflagBtn setHidden:(mode != DJIGSViewMode_WatchMode)];
    [_loadpathBtn setHidden:(mode != DJIGSViewMode_ViewMode)];
    [_pathgoBtn setHidden:(mode == DJIGSViewMode_EditMode)];
    
}

#pragma mark - IBAction Methods

- (IBAction)backBtnAction:(id)sender {
    [self setMode:DJIGSViewMode_ViewMode];
    if ([_delegate respondsToSelector:@selector(switchToMode:inGSButtonVC:)]) {
        [_delegate switchToMode:self.mode inGSButtonVC:self];
    }
}

- (IBAction)stopBtnAction:(id)sender {
 
    if ([_delegate respondsToSelector:@selector(stopBtnActionInGSButtonVC:)]) {
        [_delegate stopBtnActionInGSButtonVC:self];
    }
    
}

- (IBAction)clearBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(clearBtnActionInGSButtonVC:)]) {
        [_delegate clearBtnActionInGSButtonVC:self];
    }
    
}

- (IBAction)focusMapBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(focusMapBtnActionInGSButtonVC:)]) {
        [_delegate focusMapBtnActionInGSButtonVC:self];
    }
}

- (IBAction)editBtnAction:(id)sender {
    
    [self setMode:DJIGSViewMode_EditMode];
    if ([_delegate respondsToSelector:@selector(switchToMode:inGSButtonVC:)]) {
        [_delegate switchToMode:self.mode inGSButtonVC:self];
    }
    
}

- (IBAction)startBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(startBtnActionInGSButtonVC:)]) {
        [_delegate startBtnActionInGSButtonVC:self];
    }
}

- (IBAction)addBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(addBtn:withActionInGSButtonVC:)]) {
        [_delegate addBtn:self.addBtn withActionInGSButtonVC:self];
    }
    
}

- (IBAction)configBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(configBtnActionInGSButtonVC:)]) {
        [_delegate configBtnActionInGSButtonVC:self];
    }
}

- (IBAction)cameraBtnAction:(id)sender {
    if (_mode ==DJIGSViewMode_WatchMode) {
        [self setMode:DJIGSViewMode_ViewMode];
    }
    else{
    [self setMode:DJIGSViewMode_WatchMode];
    }
    if ([_delegate respondsToSelector:@selector(cameraBtn:withActionInGSButtonVC:)]) {
        [_delegate cameraBtn:self.cameraBtn withActionInGSButtonVC:self];

    }
}

- (IBAction)captureBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(captureBtnActionInGSButtonVC:)]) {
        [_delegate captureBtnActionInGSButtonVC:self];
    }
}

- (IBAction)recordBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(recordBtnActionInGSButtonVC:)]) {
        [_delegate recordBtnActionInGSButtonVC:self];
    }
}

- (IBAction)modeflagBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(modeflagBtn:withActionInGSButtonVC:)]) {
        [_delegate modeflagBtn:self.modeflagBtn withActionInGSButtonVC:self];
    }
}

- (IBAction)loadpathBtnAction:(id)sender{
    
    if ([_delegate respondsToSelector:@selector(loadpathBtnActionInGSButtonVC:)]) {
        [_delegate loadpathBtnActionInGSButtonVC:self];
    }
}

- (IBAction)pathgoBtnAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(pathgoBtnActionInGSButtonVC:)]) {
        [_delegate pathgoBtnActionInGSButtonVC:self];
    }
}
@end
