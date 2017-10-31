//
//  PMGPSNavigateManager.h
//  139PushMail
//
//  Created by qujie on 2017/10/14.
//  Copyright © 2017年 Á´ãÈÄöÊó†Èôê. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , PMGPSErrorType) {
    PMGPSErrorTypeWithoutApp ,
    PMGPSErrorTypeWithoutOpenApp ,
    PMGPSErrorTypeWithoutFindLocation ,
    PMGPSErrorTypeOther ,
};

typedef struct {
    
    CGFloat longitude; /**< 经度 */
    CGFloat latitude ; /**< 伟度 */
    
}PMLocation;

typedef void (^CallBackBlock)(PMLocation location);
typedef void(^ErrorBlock)(PMGPSErrorType gpsErrorType , NSString * errorMessage);


@interface PMGPSNavigateManager : NSObject


+(instancetype)manager ;

/**
 设置初始化数据
 */
-(void)initData ;


#pragma mark - 转化方法
/**
 更新当前所在的位置
 
 @param backBlock 回调，返回坐标
 */
-(void)updatLocationWithCallBackBlock:(CallBackBlock)backBlock;


/**
 转换方法

 @param address 地址名称
 @param completion 回调，返回坐标
 */
-(void)translateWithAddress:(NSString *)address completionHandler:(CallBackBlock)completion failure:(ErrorBlock)failure;



#pragma mark - 导航方法

/**
 从当前位置开始 导航去往目的地

 @param destinationName 目的地名称
 */
-(void)startGPSNavigateWithDestinationName:(NSString *)destinationName failure:(ErrorBlock)failure;


/**
 从当前位置开始 导航去往目的地

 @param DestinationLocation 目的地 的 经伟度坐标
 */
-(void)startGPSNavigateWithDestinationLocation:(PMLocation)destinationLocation failure:(ErrorBlock)failure;

@end
