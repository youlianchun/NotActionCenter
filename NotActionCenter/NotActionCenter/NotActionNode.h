//
//  NotActionNode.h
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* kNotActionCenter_unMount = @"kNotActionCenter_unMount";

@protocol NotActionCenterFunction <NSObject>
@optional

/**
 手动触发推送事件
 发送时候atOnce为NO时候
 */
-(void)manualTriggerNotAction;//禁止实现接口

/**
 挂载推送(对象释放后会自行取消挂载)
 未取消挂载对象均可收到推送
 
 @param key 定位关键字
 */
-(void)mountNotActionWithKey:(NSString*)key;//禁止实现接口

/**
 取消挂载
 */
-(void)unMountNotAction;//禁止实现接口
@end

@protocol NotActionNodeProtocol <NotActionCenterFunction>
-(void)notActionWithName:(NSString*)actionName object:(id)object;
/**
 YES 时候原本手动执行代码将自动执行，收到事件时候会进行检测
 
 @return <#return value description#>
 */
-(BOOL)notActionTriggerNotActionAtOnceInManual;
@end

@interface NotActionNode : NSObject

@end
