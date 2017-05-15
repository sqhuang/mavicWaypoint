//
//  DataStructures.h
//  vcc_drone
//
//  Created by waysup on 16/11/24.
//  Copyright © 2016年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>


//definition of A Aircraft Status Pack
typedef struct {
    //int32_t packID;
    
    Float32 longitude;
    Float32 latitude;
    Float32 altitude;
    
    Float32 gimbalPitch;
    Float32 gimbalYaw;
    Float32 gimbalRoll;
    
    Float32 AircraftPitch;
    Float32 AircraftYaw;
    Float32 AircraftRoll;
    
    Float32 Vx;
    Float32 Vy;
    Float32 Vz;
}AircraftStatusPacket;//size (4B * 13) = 52 Bytes


