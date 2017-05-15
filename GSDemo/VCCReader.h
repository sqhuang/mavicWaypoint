//
//  VCCReader.h
//  FileReader
//
//  Created by qiu on 2016/11/4.
//  Copyright © 2016年 qiu. All rights reserved.
//
//  NSMutableArray *vccReader is a array whose type is VCCData
//  
#import "VCCDroneWaypoint.h"

@interface VCCReader : NSObject
@property NSMutableArray *vccReader;
- (instancetype)initReaderwith:(NSString*) path;
- (NSInteger)getNumberofRecords;
- (void)showWhatWeRead;
- (VCCDroneWaypoint *)DataAtIndex:(NSInteger)index;
@end
