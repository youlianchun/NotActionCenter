//
//  NotActionNode.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NotActionNode.h"

@interface NSObject ()<NotActionCenterFunction>
@property (nonatomic, readonly)BOOL *isMountNotAction;

@end

@interface NotActionNode ()
@property (nonatomic, copy) NSString *nodeObjectKey;
@property (nonatomic, weak) NSObject<NotActionNodeProtocol> * nodeObject;

@property (nonatomic, retain) NSMutableArray <NSString*>*actionNameArray_allWillDo;//按照时间排序

@property (nonatomic, retain) NSMutableDictionary <NSString *, id>* actionDict_allWillDo;//同名事件近保留最新一个

@property (nonatomic, readonly) BOOL isLive;//是否活跃
@end

@implementation NotActionNode

-(void)dealloc {
    _actionNameArray_allWillDo = nil;
    _actionDict_allWillDo = nil;
}


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

-(BOOL)isLive {
    if (self.nodeObject) {
        return self.nodeObject.isMountNotAction;
    }
    return NO;
}

-(void)receiveActionWithName:(NSString*)actionName object:(id)object transmitAtOnce:(BOOL)atOnce {
    [self.actionNameArray_allWillDo removeObject:actionName];
    [self.actionDict_allWillDo removeObjectForKey:actionName];
    if (atOnce) {
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
    if ([actionName isEqualToString:kNotActionCenter_unMount]) {
        [self.nodeObject unMountNotAction];
    }else{
        [self.nodeObject notActionWithName:actionName object:object];
    }
}

@end
