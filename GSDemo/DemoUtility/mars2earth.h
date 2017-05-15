//
//  mars2earth.h
//  vcc_drone
//
//  Created by kexie on 16/10/16.
//  Copyright © 2016年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface mars2earth : NSObject

    /*
	*将gps坐标转换为火星坐标
	*wgLon, wgLat为gps经纬度
	*mgLon, mgLon为火星经纬度
     */


+ (CLLocationCoordinate2D) gpsPoint2MarsPoint:(CLLocationCoordinate2D)gpsPoint;
+ (CLLocationCoordinate2D) MarsPoint2gpsPoint:(CLLocationCoordinate2D)marsPoint;

//+ (void) gpsPoint2MarsPoint:(double)wgLon wgLat:(double)wgLat mgLat:(double*)mgLat mgLon:(double*)mgLon;
//+ (void) marsPoint2BaiduPoint:(double)mgLon mgLat:(double)mgLat bdLat:(double*)bdLat bdLon:(double*)bdLon;
//+ (void) gpsPoint2BaiduPoint:(double)wgLon wgLat:(double)wgLat bdLat:(double*)bdLat bdLon:(double*)bdLon;
//+ (double) transformLat:(double)x y:(double) y;
//+ (double) transformLon:(double)x y:(double) y;
//
//
//+ (void) baiduPoint2marsPoint:(double)bdLon bdLat:(double) bdLat mgLon:(double*)mgLon mgLat:(double*)mgLat;
//+ (void) marsPoint2gpsPoint:(double)mgLon mgLat:(double)mgLat wgLon:(double*)wgLon wgLat:(double*)wgLat;
//+ (void) delta:(double)wgsLat wgsLng:(double)wgsLng lat:(double*)lat lng:(double*)lng;
//+ (void) baiduPoint2gpsPoint:(double)bdLon bdLat:(double)bdLat wgLon:(double*)wgLon wgLat:(double*)wgLat;

extern const double PI = M_PI;
extern const double a = 6378245.0;
extern const double ee = 0.00669342162296594323;
extern const double xPI = 3.14159265358979324 * 3000.0 / 180.0;

@end
