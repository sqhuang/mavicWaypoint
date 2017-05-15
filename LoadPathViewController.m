//
//  LoadPathViewController.m
//  GSDemo
//
//  Created by qiu on 02/03/2017.
//  Copyright © 2017 DJI. All rights reserved.
//

#import "LoadPathViewController.h"

@interface LoadPathViewController ()

@end

@implementation LoadPathViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)goBtnAction:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(goBtnActionInLoadPathViewController:)]) {
        [_delegate goBtnActionInLoadPathViewController:self];
    }
    
}

- (void)initUI
{
    //self.altitudeTextField.text = @"100"; //Set the altitude to 100
    self.samplefTextField.text = @"9"; //Set the sp to ...
    self.rTextField.text = @"2.7"; //Set the curve to ...
   
}

@end
