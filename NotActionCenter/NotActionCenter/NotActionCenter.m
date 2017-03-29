//
//  NotActionCenter.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NotActionCenter.h"
#import "NotActionNode.h"

@interface NSObject ()
@property (nonatomic, readonly)NSString *nodeKey;
@end

@interface NotActionNode ()
@property (nonatomic, copy) NSString *nodeObjectKey;
@property (nonatomic, weak) id<NotActionNodeProtocol> nodeObject;
@property (nonatomic, readonly) BOOL manualTrigger;//手动触发通知, 默认NO,
@property (nonatomic, readonly) BOOL isLive;//是否活跃
-(void)transmitAction;
-(void)receiveActionWithName:(NSString*)actionName object:(id)object transmitAtOnce:(BOOL)atOnce;
@end

@interface NotActionCenter ()
@property (nonatomic, retain) NSMutableDictionary<NSString*/*对象唯一编号*/,NSString*/*key*/>*notActionNodeKeyDict;//用于手动转发
@property (nonatomic, retain) NSMutableDictionary<NSString*/*对象类*/,NSMutableDictionary<NSString */*key*/,NSMutableArray<NotActionNode*> *> *> *notActionNodeDict;
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

-(NSMutableDictionary<NSString *,NSString *> *)notActionNodeKeyDict {
    if (!_notActionNodeKeyDict) {
        _notActionNodeKeyDict = [NSMutableDictionary<NSString *,NSString *> dictionary];
    }
    return _notActionNodeKeyDict;
}

-(NSMutableDictionary<NSString*,NSMutableDictionary<NSString *,NSMutableArray<NotActionNode*> *> *> *)notActionNodeDict {
    if (!_notActionNodeDict) {
        _notActionNodeDict = [NSMutableDictionary<NSString*,NSMutableDictionary<NSString *,NSMutableArray<NotActionNode*> *> *> dictionary];
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
            NSMutableDictionary *dict = [self.notActionNodeDict objectForKey:class];
            NSMutableArray *arr = [dict objectForKey:key];
            [self pushNotActionWithKeyArray:arr atOnce:atOnce actionName:actionName object:object];
        }];
    }
}
-(void)pushNotActionAtOnce:(BOOL)atOnce toClass:(Class)cls actionName:(NSString*)actionName object:(id)object {
    [NotActionCenter actionQueuSyncDo:^{
        NSString* class = NSStringFromClass([cls class]);
        NSMutableDictionary *dict = [self.notActionNodeDict objectForKey:class];
        [self pushNotActionWithClassDict:dict atOnce:atOnce actionName:actionName object:object];
    }];
}

-(void)pushNotActionAtOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object {
    [NotActionCenter actionQueuSyncDo:^{
        NSArray *keys_cls = [self.notActionNodeDict allKeys];
        for (int k = 0; k<keys_cls.count; k++) {
            NSMutableDictionary *dict = [self.notActionNodeDict objectForKey:keys_cls[k]];
            [self pushNotActionWithClassDict:dict atOnce:atOnce actionName:actionName object:object];
        }
    }];
}

//根据类
-(void)pushNotActionWithClassDict:(NSMutableDictionary<NSString *,NSMutableArray<NotActionNode*> *> *)dict atOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object  {
    NSArray *keys = [dict allKeys];
    for (int j = 0; j<keys.count; j++) {
        NSMutableArray *arr = [dict objectForKey:keys[j]];
        for (int i=0; i<arr.count; i++) {
            [self pushNotActionWithKeyArray:arr atOnce:atOnce actionName:actionName object:object];
        }
    }
}

//根据类下的key
-(void)pushNotActionWithKeyArray:(NSMutableArray<NotActionNode*>*)array atOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object  {
    for (int i=0; i<array.count; i++) {
        NotActionNode *notActionNode = array[i];
        if (notActionNode) {
            if (notActionNode.isLive) {
                [notActionNode receiveActionWithName:actionName object:object transmitAtOnce:atOnce];
            }else{
                [array removeObject:notActionNode];
                i--;
            }
        }
    }
}

-(void)unMountWithNode:(NSObject<NotActionNodeProtocol>*)node {
    NSString* nodeKey = node.nodeKey;
    NSString* key = [_notActionNodeKeyDict objectForKey:nodeKey];
    if (key) {
        NSString* class = NSStringFromClass([node class]);
        NSMutableDictionary *dict = [_notActionNodeDict objectForKey:class];
        NSMutableArray *arr = [dict objectForKey:key];
        for (int i=0; i<arr.count; i++) {
            NotActionNode *notActionNode = arr[i];
            if ([notActionNode.nodeObjectKey isEqualToString:nodeKey]) {
                [arr removeObject:notActionNode];
                break;
            }
        }
        if (arr.count == 0) {
            [dict removeObjectForKey:key];
        }
        [_notActionNodeKeyDict removeObjectForKey:nodeKey];
    }
}

-(void)mountWithNode:(NSObject<NotActionNodeProtocol>*)node key:(NSString*)key {
    NSString* nodeKey = node.nodeKey;
    NSString* oldKey = [self.notActionNodeKeyDict objectForKey:nodeKey];
    if ([oldKey isEqualToString:key]) {
        return;
    }
    [self.notActionNodeKeyDict setObject:key forKey:nodeKey];
    NSString* class = NSStringFromClass([node class]);

    NSMutableDictionary *dict = [self.notActionNodeDict objectForKey:class];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        [self.notActionNodeDict setObject:dict forKey:class];
    }
    if (oldKey) {
        NSMutableArray *arr = [dict objectForKey:oldKey];
        for (int i=0; i<arr.count; i++) {
            NotActionNode *notActionNode = arr[i];
            if ([notActionNode.nodeObjectKey isEqualToString:nodeKey]) {
                [arr removeObject:notActionNode];
                break;
            }
        }
        if (arr.count == 0) {
            [dict removeObjectForKey:oldKey];
        }
    }
    NSMutableArray *arr = [dict objectForKey:key];
    if (!arr) {
        arr = [NSMutableArray array];
        [dict setObject:arr forKey:key];
    }
    
    NotActionNode *notActionNode = [[NotActionNode alloc] init];
    notActionNode.nodeObject = node;
    notActionNode.nodeObjectKey = nodeKey;
    [arr addObject:notActionNode];
    
}

-(void)manualTriggerWithNode:(NSObject<NotActionNodeProtocol>*)node {
    NSString* nodeKey = node.nodeKey;
    NSString* key = self.notActionNodeKeyDict[nodeKey];
    NSString* class = NSStringFromClass([node class]);
    NSMutableDictionary *dict = [self.notActionNodeDict objectForKey:class];
    NSMutableArray *arr = [dict objectForKey:key];
    BOOL unLive = NO;
    for (int i=0; i<arr.count; i++) {
        NotActionNode *notActionNode = arr[i];
        if (notActionNode) {
            if (notActionNode.isLive) {
                if ([notActionNode.nodeObjectKey isEqual:nodeKey]) {
                    [notActionNode transmitAction];
                }
            }else{
                [arr removeObject:notActionNode];
                [_notActionNodeKeyDict removeObjectForKey:notActionNode.nodeObjectKey];
                unLive = YES;
                i--;
            }
        }
    }
    if (unLive && arr.count == 0) {
        [dict removeObjectForKey:key];
    }
}

-(void)unLiveClear {
    [NotActionCenter actionQueuSyncDo:^{
        NSArray *keys = [_notActionNodeDict allKeys];
        for (int i = 0; i<keys.count; i++) {
            NSMutableDictionary *dict = [_notActionNodeDict objectForKey:keys[i]];
            NSArray *_keys = [dict allKeys];
            for (int j = 0; j<_keys.count ; j++) {
                NSMutableArray *arr = [dict objectForKey:_keys[j]];
                BOOL unLive = NO;
                for (int i=0; i<arr.count; i++) {
                    NotActionNode *notActionNode = arr[i];
                    if (!notActionNode.isLive) {
                        [arr removeObject:notActionNode];
                        [_notActionNodeKeyDict removeObjectForKey:notActionNode.nodeObjectKey];
                        unLive = YES;
                        i--;
                    }
                }
                if (unLive && arr.count == 0) {
                    [dict removeObjectForKey:_keys[j]];
                }
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self unLiveClear];
        });
    }];
}

@end
