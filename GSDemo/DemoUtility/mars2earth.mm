//
//  mars2earth.m
//  vcc_drone
//
//  Created by kexie on 16/10/16.
//  Copyright © 2016年 DJI. All rights reserved.
//

#import "mars2earth.h"

@interface mars2earth()
{

}
@end


@implementation mars2earth

+ (void) gpsPoint2MarsPoint:(double)wgLon wgLat:(double)wgLat mgLat:(double*)mgLat mgLon:(double*)mgLon
{
    double dLat = [mars2earth transformLat:(wgLon - 105.0) y:(wgLat - 35.0)];
    double dLon = [mars2earth transformLon:(wgLon - 105.0) y:(wgLat - 35.0)];
    double radLat = wgLat / 180.0 * PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0)/((a*(1-ee))/(magic * sqrtMagic)*  PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * PI);
    *mgLat = wgLat + dLat;
    *mgLon = wgLon + dLon;
};
+ (void) marsPoint2BaiduPoint:(double)mgLon mgLat:(double)mgLat bdLat:(double*)bdLat bdLon:(double*)bdLon
{
    double x = mgLon, y = mgLat;
    
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * xPI);
    
    double theta = atan2(y, x) + 0.000003 * cos(x * xPI);
    
    *bdLon = z * cos(theta) + 0.0065;
    
    *bdLat = z * sin(theta) + 0.006;
};
+ (void) gpsPoint2BaiduPoint:(double)wgLon wgLat:(double)wgLat bdLat:(double*)bdLat bdLon:(double*)bdLon
{
    double mgLon = 0.0, mgLat = 0.0;
    [mars2earth gpsPoint2MarsPoint:wgLon  wgLat:wgLat mgLat:&mgLat mgLon:&mgLon];
    [mars2earth marsPoint2BaiduPoint:mgLon mgLat:mgLat bdLat:bdLat bdLon:bdLon];
};
+ (double) transformLat:(double)x y:(double) y
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 *sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * PI) + 40.0 * sin(y / 3.0 * PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * PI) + 320 * sin(y * PI / 30.0)) * 2.0 / 3.0;
    return ret;
};
+ (double) transformLon:(double)x y:(double) y
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * PI) + 40.0 * sin(x / 3.0 * PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * PI) + 300.0 * sin(x / 30.0 * PI)) * 2.0 / 3.0;
    return ret;
};


+ (void) baiduPoint2marsPoint:(double)bdLon bdLat:(double) bdLat mgLon:(double*)mgLon mgLat:(double*)mgLat
{
    double x= bdLon - 0.0065, y = bdLat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * xPI);
    double theta = atan2(y, x) - 0.000003 * cos(x * xPI);
    *mgLon = z * cos(theta);
    *mgLat = z * sin(theta);
};
+ (void) marsPoint2gpsPoint:(double)mgLon mgLat:(double)mgLat wgLon:(double*)wgLon wgLat:(double*)wgLat
{
    double initDelta = 0.01;
    double threshold = 0.000001;
    double dLat = initDelta, dLng = initDelta;
    double mLat = mgLat - dLat, mLng = mgLon - dLng;
    double pLat = mgLat + dLat, pLng = mgLon + dLng;
    double tmpLng, tmpLat;
    for (int i = 0; i < 60; i++)
    {
        *wgLat = (mLat + pLat) / 2;
        *wgLon = (mLng + pLng) / 2;
        [mars2earth gpsPoint2MarsPoint:*wgLon wgLat:*wgLat mgLat:&tmpLat mgLon:&tmpLng];
        dLat = tmpLat - mgLat;
        dLng = tmpLng - mgLon;
        if ((fabs(dLat) < threshold) && (fabs(dLng) < threshold))
        {
            break;
        }
        if (dLat > 0)
        {
            pLat = *wgLat;
        }else{
            mLat = *wgLat;
        }
        if (dLng > 0)
        {
            pLng = *wgLon;
        }else{
            mLng = *wgLon;
        }
    }
};
+ (void) delta:(double)wgsLat wgsLng:(double)wgsLng lat:(double*)lat lng:(double*)lng
{
    double dLat = [mars2earth transformLat:(wgsLng - 105.0) y:(wgsLat - 35.0)];
    double dLng = [mars2earth transformLon:(wgsLng - 105.0) y:(wgsLat - 35.0)];
    double radLat = wgsLat /180.0 * PI;
    double magic = sin(radLat);
    magic = 1 - ee*magic*magic;
    double sqrtMagic = 1 - sqrt(magic);
    *lat = (dLat * 180.0) / (( a * (1 - ee)) / (magic * sqrtMagic) * PI);
    *lng = (dLng * 180.0) / ( a / sqrtMagic * cos( radLat ) * PI);
};
+ (void) baiduPoint2gpsPoint:(double)bdLon bdLat:(double)bdLat wgLon:(double*)wgLon wgLat:(double*)wgLat
{
    double marsLon = 0, marsLat = 0;
    [mars2earth baiduPoint2marsPoint:bdLon bdLat:bdLat mgLon:&marsLon mgLat:&marsLat];
    [mars2earth marsPoint2gpsPoint:marsLon mgLat:marsLat wgLon:wgLon wgLat:wgLat];
};



+ (CLLocationCoordinate2D) gpsPoint2MarsPoint:(CLLocationCoordinate2D)gpsPoint
{
    double gps_long = gpsPoint.longitude;
    double gps_lat = gpsPoint.latitude;
    
    
    double mars_long ;
    double mars_lat ;
    
    [mars2earth gpsPoint2MarsPoint:gps_long wgLat:gps_lat mgLat:&mars_lat mgLon:&mars_long];
    
    CLLocationCoordinate2D mars_point = CLLocationCoordinate2DMake(mars_lat, mars_long);
    return mars_point;
    
};
+ (CLLocationCoordinate2D) MarsPoint2gpsPoint:(CLLocationCoordinate2D)marsPoint
{
    double gps_long;
    double mars_long = marsPoint.longitude;
    double gps_lat;
    double mars_lat = marsPoint.latitude;
    [mars2earth marsPoint2gpsPoint:mars_long mgLat:mars_lat wgLon:&gps_long wgLat:&gps_lat];
    
    CLLocationCoordinate2D mars_point = CLLocationCoordinate2DMake(gps_lat, gps_long);
    return mars_point;
};




@end
