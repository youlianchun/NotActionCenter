//
//  NSObject+NotAction.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NSObject+NotAction.h"
#import <objc/runtime.h>
#import "NotActionCenter.h"

@interface NotActionCenter ()
-(void)manualTriggerWithNode:(id)node;
-(void)mountWithNode:(id)node key:(NSString*)key;
-(void)unMountWithNode:(id)node;
@end

@interface NSObject ()<NotActionCenterFunction>
@end

@implementation NSObject (NotAction)

-(void)manualTriggerNotAction {
    [[NotActionCenter defaultCenter] manualTriggerWithNode:self];
}

-(void)mountNotActionWithKey:(NSString*)key {
    [[NotActionCenter defaultCenter] mountWithNode:self key:key];
}

-(void)unMountNotAction {
    [[NotActionCenter defaultCenter] unMountWithNode:self];
}

@end
