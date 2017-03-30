//
//  NotActionCenter.h
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotActionNode.h"

@interface NotActionCenter : NSObject

/**
 发送事件
 atOnce NO时同名事件近保留最新一个

 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param cls 目标类
 @param key 定位关键字
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClass:(Class<NotActionNodeProtocol>)cls key:(NSString*)key actionName:(NSString*)actionName object:(id)object;

/**
 类组播事件
 atOnce NO时同名事件近保留最新一个

 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param cls 目标类
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClass:(Class<NotActionNodeProtocol>)cls actionName:(NSString*)actionName object:(id)object;

/**
 广播事件
 atOnce NO时同名事件近保留最新一个

 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object;

+(NotActionCenter*)defaultCenter;

@end
