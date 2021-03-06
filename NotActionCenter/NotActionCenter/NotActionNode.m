//
//  NotActionNode.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NotActionNode.h"

NSString* const kNotActionCenter_UnMount = @"kNotActionCenter_UnMount";


@interface NotActionNode ()
@property (nonatomic, copy) NSString *cls;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *hashKey;
@property (nonatomic, weak) NSObject<NotActionNodeProtocol> * nodeObject;
@property (nonatomic, strong) NSMutableArray <NSString*>*actionNameArray_allWillDo;//按照时间排序
@property (nonatomic, strong) NSMutableDictionary <NSString *, id>* actionDict_allWillDo;//同名事件近保留最新一个
@end

@implementation NotActionNode

-(void)dealloc {
    _actionNameArray_allWillDo = nil;
    _actionDict_allWillDo = nil;
}

#pragma mark- GET SET

-(NSMutableArray<NSString *> *)actionNameArray_allWillDo {
    if (!_actionNameArray_allWillDo) {
        _actionNameArray_allWillDo = [NSMutableArray array];
    }
    return _actionNameArray_allWillDo;
}

-(NSMutableDictionary<NSString *,id> *)actionDict_allWillDo {
    if (!_actionDict_allWillDo) {
        _actionDict_allWillDo = [NSMutableDictionary dictionary];
    }
    return _actionDict_allWillDo;
}

#pragma mark- receiveAction

-(void)receiveActionWithName:(NSString*)actionName object:(id)object transmitAtOnce:(BOOL)atOnce {
    [self.actionNameArray_allWillDo removeObject:actionName];
    [self.actionDict_allWillDo removeObjectForKey:actionName];
    BOOL atOnceInManual = NO;
    if ([self.nodeObject respondsToSelector:@selector(notActionTriggerNotActionAtOnceInManual)]) {
        atOnceInManual = [self.nodeObject notActionTriggerNotActionAtOnceInManual];
    }
    if (atOnce || atOnceInManual) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self transmitActionWithName:actionName object:object];
        });
    }else{
        [self.actionNameArray_allWillDo addObject:actionName];
        if (object) {
            [self.actionDict_allWillDo setObject:object forKey:actionName];
        }
    }
}

#pragma mark- transmitAction

-(void)transmitAction {
    NSArray <NSString*>*arr = [_actionNameArray_allWillDo copy];
    [_actionNameArray_allWillDo removeAllObjects];
    NSDictionary <NSString *, id>* dict = [_actionDict_allWillDo copy];
    [_actionDict_allWillDo removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i<arr.count; i++) {
            NSString *actionName = arr[i];
            id object = dict[arr[i]];
            [self transmitActionWithName:actionName object:object];
        }
    });
}

-(void)transmitActionWithName:(NSString*)actionName object:(id)object {
    if ([actionName isEqualToString:kNotActionCenter_UnMount]) {
        [self.nodeObject unMountNotAction];
    }else{
        [self.nodeObject notActionWithName:actionName object:object];
    }
}

@end

