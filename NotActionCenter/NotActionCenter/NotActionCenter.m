//
//  NotActionCenter.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NotActionCenter.h"
#import "NotActionNode.h"

typedef  NSMutableDictionary<NSString*/*nodeKey*/,NotActionNode*> NotActionNodeKeyDict;

typedef NSMutableDictionary<NSString*/*对象类*/,
                            NSMutableDictionary<NSString */*key*/,
                                                NotActionNodeKeyDict *> *>  NotActionNodeDict;

@interface NSObject ()
@property (nonatomic, readonly)NSString *nodeKey;
@end

@interface NotActionNode ()
@property (nonatomic, copy) NSString *class;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *nodeObjectKey;//nodeObject.nodeKey
@property (nonatomic, weak) id<NotActionNodeProtocol> nodeObject;
@property (nonatomic, readonly) BOOL manualTrigger;//手动触发通知, 默认NO,
@property (nonatomic, readonly) BOOL isLive;//是否活跃(对象存在且挂载中)
-(void)transmitAction;
-(void)receiveActionWithName:(NSString*)actionName object:(id)object transmitAtOnce:(BOOL)atOnce;
@end

@interface NotActionCenter ()
@property (nonatomic, retain) NotActionNodeKeyDict *notActionNodeKeyDict;//用于手动转发
@property (nonatomic, retain) NotActionNodeDict *notActionNodeDict;
@end

@implementation NotActionCenter

static NotActionCenter* _kDefaultCenter;

+ (instancetype)defaultCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kDefaultCenter = [[self alloc] init];
    });
    return _kDefaultCenter;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kDefaultCenter = [super allocWithZone:zone];
    });
    return _kDefaultCenter;
}

- (id)copyWithZone:(NSZone *)zone {
    return _kDefaultCenter;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _kDefaultCenter;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self unLiveClear];
        });
    }
    return self;
}


/**
 同步执行代码块

 @param syncCode 同步代码块
 */
+(void)actionQueuSyncDo:(void(^)())syncCode {
    static NSOperationQueue *operationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
    });
    [operationQueue addOperationWithBlock:syncCode];
}

-(void)dealloc {
    _notActionNodeKeyDict = nil;
    _notActionNodeDict = nil;
}

-(NotActionNodeKeyDict *)notActionNodeKeyDict {
    if (!_notActionNodeKeyDict) {
        _notActionNodeKeyDict = [NotActionNodeKeyDict dictionary];
    }
    return _notActionNodeKeyDict;
}

-(NotActionNodeDict *)notActionNodeDict {
    if (!_notActionNodeDict) {
        _notActionNodeDict = [NotActionNodeDict dictionary];
    }
    return _notActionNodeDict;
}

-(void)pushNotActionAtOnce:(BOOL)atOnce toClass:(Class)cls key:(NSString*)key actionName:(NSString*)actionName object:(id)object {
    if (cls == nil) {
        [self pushNotActionAtOnce:atOnce actionName:actionName object:object];
    }else if (key.length == 0){
        [self pushNotActionAtOnce:atOnce toClass:cls actionName:actionName object:object];
    }else{
        [NotActionCenter actionQueuSyncDo:^{
            NSString* class = NSStringFromClass([cls class]);
            NSMutableDictionary *dict0 = [_notActionNodeDict objectForKey:class];
            NSMutableDictionary *dict1 = [dict0 objectForKey:key];
            NSArray *arr = [dict1 allValues];
            for (NotActionNode *notActionNode in arr) {
                if (notActionNode.isLive) {
                    [notActionNode receiveActionWithName:actionName object:object transmitAtOnce:atOnce];
                }else{
                    [self unMountWithActionNode:notActionNode];
                }
            }
        }];
    }
}
-(void)pushNotActionAtOnce:(BOOL)atOnce toClass:(Class)cls actionName:(NSString*)actionName object:(id)object {
    [NotActionCenter actionQueuSyncDo:^{
        NSString* class = NSStringFromClass([cls class]);
        NSMutableDictionary *dict0 = [_notActionNodeDict objectForKey:class];
        NSArray *arr = [dict0 allValues];
        for (NotActionNodeKeyDict *dict1 in arr) {
            NSArray *arr = [dict1 allValues];
            for (NotActionNode *notActionNode in arr) {
                if (notActionNode.isLive) {
                    [notActionNode receiveActionWithName:actionName object:object transmitAtOnce:atOnce];
                }else{
                    [self unMountWithActionNode:notActionNode];
                }
            }
        }
    }];
}

-(void)pushNotActionAtOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object {
    [NotActionCenter actionQueuSyncDo:^{
        NSArray *arr = [_notActionNodeKeyDict allValues];
        for (NotActionNode *notActionNode in arr) {
            if (notActionNode.isLive) {
                [notActionNode receiveActionWithName:actionName object:object transmitAtOnce:atOnce];
            }else{
                [self unMountWithActionNode:notActionNode];
            }
        }
    }];
}


-(void)unMountWithNode:(NSObject<NotActionNodeProtocol>*)node {
    NSString* nodeKey = node.nodeKey;
    NSString* key = [_notActionNodeKeyDict objectForKey:nodeKey].key;
    if (key) {
        NotActionNode *notActionNode = [_notActionNodeKeyDict objectForKey:nodeKey];
        [self unMountWithActionNode:notActionNode];
    }
}

-(void)unMountWithActionNode:(NotActionNode*)notActionNode {
    NSString *class = notActionNode.class;
    NSString *key = notActionNode.key;
    NSString *nodeKey = notActionNode.nodeObjectKey;
    NSMutableDictionary *dict0 = [_notActionNodeDict objectForKey:class];
    NSMutableDictionary *dict1 = [dict0 objectForKey:key];
    [dict1 removeObjectForKey:nodeKey];
    if (dict1.allKeys.count == 0) {
        [dict0 removeObjectForKey:key];
    }
    if (dict0.allKeys.count == 0) {
        [_notActionNodeDict removeObjectForKey:class];
    }
    [_notActionNodeKeyDict removeObjectForKey:nodeKey];
}

-(void)mountWithNode:(NSObject<NotActionNodeProtocol>*)node key:(NSString*)key {
    NSString* nodeKey = node.nodeKey;
    NSString* oldKey = [self.notActionNodeKeyDict objectForKey:nodeKey].key;
    if ([oldKey isEqualToString:key]) {
        return;
    }
    NSString* class = NSStringFromClass([node class]);
    if (oldKey) {
        NotActionNode *notActionNode = [self.notActionNodeKeyDict objectForKey:nodeKey];
        [self unMountWithActionNode:notActionNode];
    }
    NSMutableDictionary *dict0 = [self.notActionNodeDict objectForKey:class];
    if (!dict0) {
        dict0 = [NotActionNodeKeyDict dictionary];
        [self.notActionNodeDict setObject:dict0 forKey:class];
    }
    NSMutableDictionary *dict1 = [dict0 objectForKey:key];
    if (!dict1) {
        dict1 = [NotActionNodeKeyDict dictionary];
        [dict0 setObject:dict1 forKey:key];
    }
    NotActionNode *notActionNode = [[NotActionNode alloc] init];
    notActionNode.class = class;
    notActionNode.key = key;
    notActionNode.nodeObjectKey = nodeKey;
    notActionNode.nodeObject = node;
    [dict1 setObject:notActionNode forKey:nodeKey];
    [self.notActionNodeKeyDict setObject:notActionNode forKey:nodeKey];
}

-(void)manualTriggerWithNode:(NSObject<NotActionNodeProtocol>*)node {
    NSString* nodeKey = node.nodeKey;
    NotActionNode *notActionNode = self.notActionNodeKeyDict[nodeKey];
    if (notActionNode.isLive) {
        if ([notActionNode.nodeObjectKey isEqual:nodeKey]) {
            [notActionNode transmitAction];
        }
    }
}

-(void)unLiveClear {
    [NotActionCenter actionQueuSyncDo:^{
        NSArray * arr = [_notActionNodeKeyDict allValues];
        for (NotActionNode *notActionNode in arr) {
            if (!notActionNode.isLive) {
                [self unMountWithActionNode:notActionNode];
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self unLiveClear];
        });
    }];
}

@end
