//
//  NotActionCenter.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NotActionCenter.h"
#import "NotActionNode.h"

typedef NSMutableDictionary<NSString*, NotActionNode *> NotActionNodeDict_NodeKey;
typedef NSMutableDictionary<NSString*, NotActionNodeDict_NodeKey *> NotActionNodeDict_Key;
typedef NSMutableDictionary<NSString*, NotActionNodeDict_Key *>  NotActionNodeDict_Class;

@interface NSObject ()
@property (nonatomic, readonly)NSString *nodeKey;
@end

@interface NotActionNode ()
@property (nonatomic, copy) NSString *cls;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *nodeObjectKey;//nodeObject.nodeKey
@property (nonatomic, weak) id<NotActionNodeProtocol> nodeObject;
@property (nonatomic, readonly) BOOL isLive;//是否活跃(对象存在且挂载中)
-(void)transmitAction;
-(void)receiveActionWithName:(NSString*)actionName object:(id)object transmitAtOnce:(BOOL)atOnce;
@end

@interface NotActionCenter ()
@property (nonatomic, retain) NotActionNodeDict_NodeKey *notActionNodeDict_node;
@property (nonatomic, retain) NotActionNodeDict_Class *notActionNodeDict_map;
@property (nonatomic, assign) BOOL unLiveClearing;
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
    _notActionNodeDict_node = nil;
    _notActionNodeDict_map = nil;
}

#pragma mark- GET SET

-(NotActionNodeDict_NodeKey *)notActionNodeDict_node {
    if (!_notActionNodeDict_node) {
        _notActionNodeDict_node = [NotActionNodeDict_NodeKey dictionary];
    }
    return _notActionNodeDict_node;
}

-(NotActionNodeDict_Class *)notActionNodeDict_map {
    if (!_notActionNodeDict_map) {
        _notActionNodeDict_map = [NotActionNodeDict_Class dictionary];
    }
    return _notActionNodeDict_map;
}

#pragma mark- pushNotAction

-(void)pushActionAtOnce:(BOOL)atOnce toClass:(Class)cls key:(NSString*)key actionName:(NSString*)actionName object:(id)object {
    if (cls == nil) {
        [self pushActionAtOnce:atOnce actionName:actionName object:object];
    }else {
        if (![cls conformsToProtocol:@protocol(NotActionNodeProtocol)]) {
            NSString *error = [NSString stringWithFormat:@"⚠️ toClass: %@ 未继承NotActionNodeProtocol协议", NSStringFromClass(cls)];
            NSAssert(NO, error);
            return;
        }
        if (key.length == 0){
            [self pushActionAtOnce:atOnce toClass:cls actionName:actionName object:object];
        }else{
            [NotActionCenter actionQueuSyncDo:^{
                NSString* class = NSStringFromClass([cls class]);
                NotActionNodeDict_Key *dict0 = [_notActionNodeDict_map objectForKey:class];
                NotActionNodeDict_NodeKey *dict1 = [dict0 objectForKey:key];
                NSArray *arr = [dict1 allValues];
                for (NotActionNode *notActionNode in arr) {
                    [self transmitActionToNode:notActionNode atOnce:atOnce actionName:actionName object:object];
                }
            }];
        }
    }
}

-(void)pushActionAtOnce:(BOOL)atOnce toClass:(Class)cls actionName:(NSString*)actionName object:(id)object {
    if (![cls conformsToProtocol:@protocol(NotActionNodeProtocol)]) {
        NSString *error = [NSString stringWithFormat:@"⚠️ toClass: %@ 未继承NotActionNodeProtocol协议", NSStringFromClass(cls)];
        NSAssert(NO, error);
        return;
    }
    [NotActionCenter actionQueuSyncDo:^{
        NSString* class = NSStringFromClass([cls class]);
        NotActionNodeDict_Key *dict0 = [_notActionNodeDict_map objectForKey:class];
        NSArray *arr = [dict0 allValues];
        for (NotActionNodeDict_NodeKey *dict1 in arr) {
            NSArray *arr = [dict1 allValues];
            for (NotActionNode *notActionNode in arr) {
                [self transmitActionToNode:notActionNode atOnce:atOnce actionName:actionName object:object];
            }
        }
    }];
}

-(void)pushActionAtOnce:(BOOL)atOnce toNotActionNode:(NSObject<NotActionNodeProtocol>*)node actionName:(NSString*)actionName object:(id)object {
    [NotActionCenter actionQueuSyncDo:^{
        NSString* nodeKey = node.nodeKey;
        NotActionNode *notActionNode = [_notActionNodeDict_node objectForKey:nodeKey];
        [self transmitActionToNode:notActionNode atOnce:atOnce actionName:actionName object:object];
    }];

}

-(void)pushActionAtOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object {
    [NotActionCenter actionQueuSyncDo:^{
        NSArray *arr = [_notActionNodeDict_node allValues];
        for (NotActionNode *notActionNode in arr) {
            [self transmitActionToNode:notActionNode atOnce:atOnce actionName:actionName object:object];
        }
    }];
}

-(void)transmitActionToNode:(NotActionNode*)notActionNode atOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object {
    if (notActionNode) {
        if (notActionNode.isLive) {
            [notActionNode receiveActionWithName:actionName object:object transmitAtOnce:atOnce];
        }else{
            [self unMountWithActionNode:notActionNode];
        }
    }
}

#pragma mark- unMount

-(void)unMountWithNode:(NSObject<NotActionNodeProtocol>*)node {
    NSString* nodeKey = node.nodeKey;
    NotActionNode *notActionNode = [_notActionNodeDict_node objectForKey:nodeKey];
    [self unMountWithActionNode:notActionNode];
}

-(void)unMountWithActionNode:(NotActionNode*)notActionNode {
    NSString *class = notActionNode.cls;
    NSString *key = notActionNode.key;
    NSString *nodeKey = notActionNode.nodeObjectKey;
    NotActionNodeDict_Key *dict0 = [_notActionNodeDict_map objectForKey:class];
    NotActionNodeDict_NodeKey *dict1 = [dict0 objectForKey:key];
    [dict1 removeObjectForKey:nodeKey];
    if (dict1.allKeys.count == 0) {
        [dict0 removeObjectForKey:key];
    }
    if (dict0.allKeys.count == 0) {
        [_notActionNodeDict_map removeObjectForKey:class];
    }
    [_notActionNodeDict_node removeObjectForKey:nodeKey];
}

#pragma mark- mount

-(void)mountWithNode:(NSObject<NotActionNodeProtocol>*)node key:(NSString*)key {
    NSString* nodeKey = node.nodeKey;
    NSString* oldKey = [self.notActionNodeDict_node objectForKey:nodeKey].key;
    if ([oldKey isEqualToString:key]) {
        return;
    }
    NSString* class = NSStringFromClass([node class]);
    if (oldKey) {
        NotActionNode *notActionNode = [self.notActionNodeDict_node objectForKey:nodeKey];
        [self unMountWithActionNode:notActionNode];
    }
    NotActionNodeDict_Key *dict0 = [self.notActionNodeDict_map objectForKey:class];
    if (!dict0) {
        dict0 = [NotActionNodeDict_Key dictionary];
        [self.notActionNodeDict_map setObject:dict0 forKey:class];
    }
    NotActionNodeDict_NodeKey *dict1 = [dict0 objectForKey:key];
    if (!dict1) {
        dict1 = [NotActionNodeDict_NodeKey dictionary];
        [dict0 setObject:dict1 forKey:key];
    }
    NotActionNode *notActionNode = [[NotActionNode alloc] init];
    notActionNode.cls = class;
    notActionNode.key = key;
    notActionNode.nodeObjectKey = nodeKey;
    notActionNode.nodeObject = node;
    [dict1 setObject:notActionNode forKey:nodeKey];
    [self.notActionNodeDict_node setObject:notActionNode forKey:nodeKey];
    [self unLiveClear_start];
}

-(void)manualTriggerWithNode:(NSObject<NotActionNodeProtocol>*)node {
    NSString* nodeKey = node.nodeKey;
    NotActionNode *notActionNode = self.notActionNodeDict_node[nodeKey];
    if (notActionNode) {
        if (notActionNode.isLive) {
            [notActionNode transmitAction];
        }else {
            [self unMountWithActionNode:notActionNode];
        }
    }
}

#pragma mark- unLiveClear

-(void)unLiveClear_start {
    if (!self.unLiveClearing) {
        [self unLiveClear_next];
    }
}

-(void)unLiveClear_next {
    if([_notActionNodeDict_node allValues].count>0){
        self.unLiveClearing = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self unLiveClear_do];
        });
    }else{
        self.unLiveClearing = NO;
    }
}

-(void)unLiveClear_do {
    [NotActionCenter actionQueuSyncDo:^{
        NSArray * arr = [_notActionNodeDict_node allValues];
        for (NotActionNode *notActionNode in arr) {
            if (notActionNode && !notActionNode.isLive) {
                [self unMountWithActionNode:notActionNode];
            }
        }
        [self unLiveClear_next];
    }];
}

@end
