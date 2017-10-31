//
//  PMGPSNavigateManager.m
//  139PushMail
//
//  Created by qujie on 2017/10/14.
//  Copyright © 2017年 Á´ãÈÄöÊó†Èôê. All rights reserved.
//

#import "PMGPSNavigateManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"

@interface PMGPSNavigateManager ()<CLLocationManagerDelegate , UIActionSheetDelegate>

@property (nonatomic , assign) CallBackBlock backBlock ;
@property (nonatomic , assign) ErrorBlock errorBlock ;

@property (nonatomic , copy) NSString * destinationAddress ;
//目的地经纬度
@property (nonatomic, assign) PMLocation destinationLocation;
////目前所在地经纬度
//@property (nonatomic, assign) PMLocation currentLocation;

@property (nonatomic , strong) NSMutableArray * array ;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end


@implementation PMGPSNavigateManager


+(instancetype)manager
{
    static PMGPSNavigateManager * manager = nil ;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PMGPSNavigateManager alloc] init];
    });
    
    return manager ;
}

-(void)initData
{
    self.array = [self appArrayCanOpen] ;
}

#pragma mark - 开始导航

// 
-(void)hintErrorWithErrorType:(PMGPSErrorType)errorType message:(NSString *)message failureBlock:(ErrorBlock)failure
{
    if (failure) {
        
        if (errorType == PMGPSErrorTypeWithoutApp) {
            message = @"没有安装导航地图App";
        }
        else if (errorType == PMGPSErrorTypeWithoutFindLocation){
            message = @"未找到目的地位置";
        }
        else if (errorType == PMGPSErrorTypeWithoutOpenApp){
            if (message.length) {
                message = [NSString stringWithFormat:@"无法打开%@",message];
            }
            else{
                message = [NSString stringWithFormat:@"无法打开地图"];
            }
        }
        
        failure(errorType, message);
    }
}

-(void)startGPSNavigateWithDestinationName:(NSString *)destinationName failure:(ErrorBlock)failure
{
    self.destinationAddress = destinationName ;

    [self translateWithAddress:destinationName completionHandler:^(PMLocation location) {
       
        [self startGPSNavigateWithDestinationLocation:location failure:failure];
        
    }failure:^(PMGPSErrorType gpsErrorType, NSString *errorMessage){

        [self startGPSNavigateWithDestinationLocation:((PMLocation){-100000,-100000}) failure:failure];
    }];
}

-(void)startGPSNavigateWithDestinationLocation:(PMLocation)destinationLocation failure:(ErrorBlock)failure
{
    [self setupMapURLStrWithEndLocation:destinationLocation endAddress:self.destinationAddress];
    
    self.errorBlock = failure ;
    NSMutableArray * array =  self.array ;
    self.destinationLocation = destinationLocation ;
  
    if (array.count >= 2) {
        
        NSString * title1 = nil ;
        NSString * title2 = nil ;
        NSString * title3 = nil ;
        NSString * title4 = nil ;
        NSString * title5 = nil ;
        NSInteger index = 0 ;
        
        for (NSDictionary * dic in array) {
            switch (index) {
                case 0:
                    title1 = [dic objectForKey:@"title"] ;
                    break;
                case 1:
                    title2 = [dic objectForKey:@"title"] ;
                    break;
                case 2:
                    title3 = [dic objectForKey:@"title"] ;
                    break;
                case 3:
                    title4 = [dic objectForKey:@"title"] ;
                    break;
                case 4:
                    title5 = [dic objectForKey:@"title"] ;
                    break;
                default:
                    break;
            }
            index++ ;
        }
        
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:title1,title2,title3,title4,title5, nil];
        
        [actionSheet showInView:[UIApplication sharedApplication].delegate.window];

    }
    else if (array.count >= 1){
        [self actionSheet:nil clickedButtonAtIndex:0];
    }
    else{
        [self hintErrorWithErrorType:PMGPSErrorTypeWithoutApp message:nil failureBlock:failure];
    }
}

#pragma mark - 打开地图

-(BOOL)openURLStr:(NSString *)urlStr
{
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

// 苹果地图
- (BOOL)navAppleMap:(PMLocation)destinationLoc
{
    CLLocationCoordinate2D gps = {destinationLoc.latitude,destinationLoc.longitude};
    
    MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
    currentLoc.name = @"我的位置" ;
    
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:gps addressDictionary:nil]];
    toLocation.name = self.destinationAddress ;
    
    NSArray *items = @[currentLoc,toLocation];
    NSDictionary *dic = @{
                          MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                          MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                          MKLaunchOptionsShowsTrafficKey : @(YES)
                          };
    
    return [MKMapItem openMapsWithItems:items launchOptions:dic];
}

#pragma mark - 工厂转化方法

-(void)updatLocationWithCallBackBlock:(CallBackBlock)backBlock
{
    self.backBlock = backBlock ;
    
    [self.locationManager startUpdatingLocation];
}

-(void)translateWithAddress:(NSString *)address completionHandler:(CallBackBlock)completion failure:(ErrorBlock)failure
{
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        PMLocation location = {-1,-1};
        
        if (placemarks.count > 0 && error == nil) {
            
            CLPlacemark *placemark = placemarks.firstObject;
            
            location = (PMLocation){placemark.location.coordinate.longitude , placemark.location.coordinate.latitude};
            
            if (completion) {
                completion(location);
            }
        }
        else if (placemarks.count == 0){
            NSLog(@"placemarks元素为0");
                [self hintErrorWithErrorType:PMGPSErrorTypeWithoutFindLocation message:nil failureBlock:failure];
        }
    }];
    
}

#pragma mark - 导航所需的

-(BOOL)canOpenURLStr:(NSString *)urlStr
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]];
}

-(NSMutableArray *)appArrayCanOpen
{
    NSMutableArray * mutArray = [NSMutableArray array];
    
    // 苹果地图
    NSMutableDictionary * iosMapDic = [NSMutableDictionary dictionary];
    iosMapDic[@"title"] = @"苹果地图";
    iosMapDic[@"tag"] = @0 ;
    [mutArray addObject:iosMapDic];
    
    // 百度地图
    if ([self canOpenURLStr:@"baidumap://"]) {
        NSMutableDictionary * baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[@"title"] = @"百度地图";
        baiduMapDic[@"tag"] = @2 ;
        
        [mutArray addObject:baiduMapDic];
    }
    
    // 谷歌地图
    if ([self canOpenURLStr:@"comgooglemaps://"]) {
        NSMutableDictionary *googleMapDic = [NSMutableDictionary dictionary];
        googleMapDic[@"title"] = @"谷歌地图";
        googleMapDic[@"tag"] = @3 ;
        
        [mutArray addObject:googleMapDic];
    }
    
    // 腾讯地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        NSMutableDictionary *qqMapDic = [NSMutableDictionary dictionary];
        qqMapDic[@"title"] = @"腾讯地图";
        qqMapDic[@"tag"] = @4 ;
        
        [mutArray addObject:qqMapDic];
    }
    
    // 高德地图
    if ([self canOpenURLStr:@"iosamap://"]) {
        NSMutableDictionary * gaodeMapDic = [NSMutableDictionary dictionary];
        gaodeMapDic[@"title"] = @"高德地图";
        gaodeMapDic[@"tag"] = @1 ;
        
        [mutArray addObject:gaodeMapDic];
    }

    return mutArray ;
}

-(void)setupMapURLStrWithEndLocation:(PMLocation)endLocation endAddress:(NSString *)endAddress
{
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!endAddress.length) {
        endAddress = @"目的地";
    }
    
    for (NSMutableDictionary * mapDic  in self.array) {
        switch ([[mapDic objectForKey:@"tag"] integerValue]) {
            case 1:
                // @"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=3" 这是直接导航
                mapDic[@"urlStr"] = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&backScheme=%@&did=BGVIS3&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",appName,@"navigation123456",endLocation.latitude,endLocation.longitude,endAddress];

                break;
            case 2:
                if ([endAddress isEqualToString:@"目的地"]) {
                    mapDic[@"urlStr"] = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=%@&mode=driving&coord_type=gcj02",endLocation.latitude,endLocation.longitude,endAddress];
                }
                else{
                    mapDic[@"urlStr"] = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=%@&mode=driving&coord_type=gcj02",endAddress];
                }
                
                break;
            case 3:
                
                if ([endAddress isEqualToString:@"目的地"]) {
                    mapDic[@"urlStr"] = [NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",appName,@"nav123456",endLocation.latitude, endLocation.longitude];
                }
                else{
                    mapDic[@"urlStr"] = [NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=我的位置&daddr=%@&directionsmode=driving",appName,@"navigation123456",endAddress];
                }
                
                break;
            case 4:
                
                mapDic[@"urlStr"] = [NSString stringWithFormat:@"qqmap://map/routeplan?referer=%@&from=我的位置&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0",appName,endLocation.latitude, endLocation.longitude,endAddress];
                
                break;
            default:
                break;
        }
    }
}


#pragma mark - UIActionSheetDelegate 协议
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != self.array.count) {
        
        NSString * appName = [[self.array objectAtIndex:buttonIndex] objectForKey:@"title"] ;
        BOOL isAppleMap = [appName isEqualToString:@"苹果地图"] ;
        BOOL isSuccess = YES ;
        
        if (isAppleMap) {
            isSuccess = [self navAppleMap:self.destinationLocation];
            return ;
        }
        else{
            NSString * urlStr = [[self.array objectAtIndex:buttonIndex] objectForKey:@"urlStr"];
            isSuccess = [self openURLStr:urlStr];
        }
        
        if (!isSuccess) {
            [self hintErrorWithErrorType:PMGPSErrorTypeWithoutOpenApp message:appName failureBlock:self.errorBlock] ;
            [self initData];
        }
    }
}

#pragma mark - CLLocationManagerDelegate 定位协议方法

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    PMLocation location = {newLocation.coordinate.longitude , newLocation.coordinate.latitude};
    
    if (location.latitude && location.longitude) {
        
        [manager stopUpdatingLocation];
        
        if (self.backBlock) {
            self.backBlock(location) ;
        }
    }
}

#pragma mark - 懒加载
- (CLLocationManager *)locationManager{
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        // 设置定位精确度到米
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 设置过滤器为无
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        // 一个是requestAlwaysAuthorization，一个是requestWhenInUseAuthorization
        [_locationManager requestWhenInUseAuthorization];//这句话ios8以上版本使用。
        
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder{
    
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

@end
