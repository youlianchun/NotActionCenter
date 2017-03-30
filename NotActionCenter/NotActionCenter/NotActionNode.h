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
 手动触发通知事件 
 发送时候atOnce为NO时候
 */
-(void)manualTriggerNotAction;//禁止实现接口

/**
 挂载通知

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
@end

@interface NotActionNode : NSObject

@end
