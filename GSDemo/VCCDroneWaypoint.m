//
//  VCCReader.m
//  FileReader
//
//  Created by qiu on 2016/11/4.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "VCCDroneWaypoint.h"

@implementation VCCDroneWaypoint
- (instancetype)initWithLongtitude:(double)longtitude Latitude:(double) latitude Height:(double) height Heading:(double)heading Pitch:(double)pitch{
    //call the superclass's designated initializer
    self = [super init];
    if (self) {
        _longti = longtitude;
        _lati   = latitude;
        _height = height;
        _heading= heading;
        _pitch  = pitch;
    }
    return self;
}

- (NSString *)description{
    NSString *descriptionString = [[NSString alloc] initWithFormat:@"(%lf, %lf) height: %lf  heading: %lf  pitch: %lf", self.longti, self.lati, self.height, self.heading, self.pitch];
    return descriptionString;
}
@end
