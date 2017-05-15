//
//  VCCReader.h
//  FileReader
//
//  Created by qiu on 2016/11/4.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCCDroneWaypoint : NSObject
//
@property (nonatomic)  double  longti;
@property (nonatomic)  double  lati;
@property (nonatomic)  double  height;
@property (nonatomic)  double  heading;
@property (nonatomic)  double  pitch;
//method
- (instancetype)initWithLongtitude:(double)longtitude Latitude:(double) latitude Height:(double) height Heading:(double)heading Pitch:(double)pitch;
@end
