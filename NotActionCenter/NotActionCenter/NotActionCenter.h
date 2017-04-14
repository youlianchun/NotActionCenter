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
-(void)pushActionAtOnce:(BOOL)atOnce toClass:(Class<NotActionNodeProtocol> __nullable)cls key:(NSString * __nullable)key actionName:(NSString * __nullable)actionName object:(id __nullable)object;

/**
 单播事件
 atOnce NO时同名事件近保留最新一个
 
 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param node 目标节点
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toNotActionNode:(NSObject<NotActionNodeProtocol> * __nonnull)node actionName:(NSString * __nullable)actionName object:(id __nullable)object;


+(nonnull NotActionCenter*)defaultCenter;

@end




#pragma mark -
#pragma mark - NotActionCenter_Interface

@interface NotActionCenter (Interface)

/**
 类组播事件
 atOnce NO时同名事件近保留最新一个
 
 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param cls 目标类
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClass:(Class<NotActionNodeProtocol> __nullable)cls actionName:(NSString* __nullable)actionName object:(id __nullable)object;

/**
 key组播事件
 
 @param atOnce atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param key 目标key
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toKey:(NSString* __nullable)key actionName:(NSString* __nullable)actionName object:(id __nullable)object;

/**
 广播事件
 atOnce NO时同名事件近保留最新一个
 
 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce actionName:(NSString* __nullable)actionName object:(id __nullable)object;


/**
 发送事件
 atOnce NO时同名事件近保留最新一个
 
 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param cls 目标类
 @param key 定位关键字
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClassString:(NSString* __nonnull)cls key:(NSString* __nullable)key actionName:(NSString* __nullable)actionName object:(id __nullable)object;

/**
 类组播事件
 atOnce NO时同名事件近保留最新一个
 
 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param cls 目标类
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClassString:(NSString* __nonnull)cls actionName:(NSString* __nullable)actionName object:(id __nullable)object;

/**
 类组播事件（多类）
 atOnce NO时同名事件近保留最新一个
 
 @param atOnce YES 立刻执行，NO 时目标对象执行 manualTriggerNotAction触发
 @param clsArray 目标类
 @param actionName 事件名
 @param object 参数
 */
-(void)pushActionAtOnce:(BOOL)atOnce toClassStringArray:(NSArray<NSString*>* __nullable)clsArray actionName:(NSString* __nullable)actionName object:(id __nullable)object;

@end
