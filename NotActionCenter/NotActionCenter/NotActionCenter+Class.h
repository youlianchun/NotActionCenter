//
//  NotActionCenter+Class.h
//  NotActionCenter
//
//  Created by YLCHUN on 2017/4/12.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NotActionCenter.h"

@interface NotActionCenter (Class)
/**
 发送事件
 atOnce NO时同名事件近保留最新一个
 
 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param cls 目标类
 @param key 定位关键字
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClassString:(NSString*)cls key:(NSString*)key actionName:(NSString*)actionName object:(id)object;

/**
 类组播事件
 atOnce NO时同名事件近保留最新一个
 
 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param cls 目标类
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClassString:(NSString*)cls actionName:(NSString*)actionName object:(id)object;

/**
 类组播事件（多类）
 atOnce NO时同名事件近保留最新一个

 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param clsArray 目标类
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClassStringArray:(NSArray<NSString*>*)clsArray actionName:(NSString*)actionName object:(id)object;

@end
