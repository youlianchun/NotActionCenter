//
//  NotActionCenter+Class.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/4/12.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NotActionCenter+Class.h"

@implementation NotActionCenter (Class)
-(void)pushActionAtOnce:(BOOL)atOnce toClassString:(NSString*)cls key:(NSString*)key actionName:(NSString*)actionName object:(id)object {
    Class c = NSClassFromString(cls);
    if (c) {
        [self pushActionAtOnce:atOnce toClass:c key:key actionName:actionName object:object];
    }
}

-(void)pushActionAtOnce:(BOOL)atOnce toClassString:(NSString*)cls actionName:(NSString*)actionName object:(id)object {
    Class c = NSClassFromString(cls);
    if (c) {
        [self pushActionAtOnce:atOnce toClass:c actionName:actionName object:object];
    }
}

-(void)pushActionAtOnce:(BOOL)atOnce toClassStringArray:(NSArray<NSString*>*)clsArray actionName:(NSString*)actionName object:(id)object {
    for (NSString*cls in clsArray) {
        [self pushActionAtOnce:atOnce toClassString:cls actionName:actionName object:object];
    }
}

@end
