//
//  DemoUtility.m
//  GSDemo
//
//  Created by DJI on 3/21/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "DemoUtility.h"
#import <DJISDK/DJISDK.h>

inline void ShowMessage(NSString *title, NSString *message, id target, NSString *cancleBtnTitle)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:target cancelButtonTitle:cancleBtnTitle otherButtonTitles:nil];
        [alert show];
    });
}

@implementation DemoUtility

+(DJIFlightController*) fetchFlightController {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).flightController;
    }
    
    return nil;
}

+(DJIGimbal*) fetchGimbal {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).gimbal;
    }
    else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]) {
        return ((DJIHandheld*)[DJISDKManager product]).gimbal;
    }
    
    return nil;
}

+ (DJICamera*) fetchCamera {
    if (![DJISDKManager product]) {
        return nil;
    }
    
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }else if ([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]){
        return ((DJIHandheld *)[DJISDKManager product]).camera;
    }
    return nil;
}
@end
