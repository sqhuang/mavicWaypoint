//
//  VCCReader.m
//  FileReader
//
//  Created by qiu on 2016/11/4.
//  Copyright © 2016年 qiu. All rights reserved.
//

#import "VCCReader.h"
NSInteger N_ITEM = 5;
@implementation VCCReader
- (instancetype)initReaderwith:(NSString*) path{
    self = [super init];
    if (self) {
        _vccReader = [NSMutableArray arrayWithObjects:nil];
        NSString *error;
        NSString *str1 = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if(error == nil){
            NSLog(@"Success!\n");
            //for test
            //NSLog(@"%@",str1);
            
            
            NSArray *alldata = [str1 componentsSeparatedByString:@"\n"];
            //comment it
            //NSLog(@"alldata:%@",alldata);
            //NOTICE the -1
            unsigned long n_line = [alldata count] - 1;
            NSLog(@"Number of Records :%lu\n",n_line);
            //
            
            for (int i = 0; i < n_line; i++) {
                NSArray *record = [alldata[i] componentsSeparatedByString:@" "];
                NSInteger n_item = [record count];
                
                if (n_item != N_ITEM) {
                    NSLog(@"Data ERROR.");
                    return 0;
                }
                double tempLongti    = [record[0] doubleValue];
                double tempLati      = [record[1] doubleValue];
                double tempHeight    = [record[2] doubleValue];
                double tempheading   = [record[3] doubleValue];
                double tempPitch     = [record[4] doubleValue];
                VCCDroneWaypoint *tempData = [[VCCDroneWaypoint alloc]initWithLongtitude:tempLongti Latitude:tempLati Height:tempHeight Heading:tempheading Pitch:tempPitch];
                [_vccReader addObject:tempData];
           
        }
         NSLog(@"-data importing success-\n");
        }
        else
        {
            NSLog(@"Failed：%@",error);
        }
        

        
        
    }
    //return the address of the newly initialized object
    return self;
}

- (NSInteger)getNumberofRecords{
    return [_vccReader count];
}
- (void)showWhatWeRead{
    //test
    NSLog(@"the whole data set :\n");
    NSInteger n_line = [self getNumberofRecords];
    for (int i = 0; i<n_line; i++) {
        NSLog(@"Data %d:\n%@",i , [_vccReader objectAtIndex:i]);
        
    }
}
- (VCCDroneWaypoint *)DataAtIndex:(NSInteger)index{
    return [_vccReader objectAtIndex:index];
}
@end
