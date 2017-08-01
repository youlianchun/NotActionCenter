//
//  NSObject+NotAction.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NSObject+NotAction.h"
#import "NotActionCenter.h"
#import <MethodAspects/MethodAspects.h>

@interface NotActionCenter ()
-(void)manualTriggerWithNode:(id)node;
-(void)mountWithNode:(id)node key:(NSString*)key;
-(void)unMountWithNode:(id)node;
@end

@interface NSObject ()<NotActionCenterFunction>
@end

@implementation NSObject (NotAction)

-(void)manualTriggerNotAction {//执行后触发非即时事件
    [[NotActionCenter defaultCenter] manualTriggerWithNode:self];
}

-(void)mountNotActionWithKey:(NSString*)key {//对象挂载
    [[NotActionCenter defaultCenter] mountWithNode:self key:key];
}

-(void)unMountNotAction {//对象解挂
    [[NotActionCenter defaultCenter] unMountWithNode:self];
    methodUnAspect(self, nil);
}

-(void)mountTriggerWithSelector:(SEL)selector {//延迟事件触发点
    methodAspect(self, MAReplenish, selector, ^(){
        [self manualTriggerNotAction];
    });
}

@end
