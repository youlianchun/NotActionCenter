//
//  NotActionCenter.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NotActionCenter.h"
#import "NotActionNode.h"

typedef NSMutableDictionary<NSString*, NotActionNode *> NotActionNodeDict_Hash;
typedef NSMutableDictionary<NSString*, NotActionNodeDict_Hash *> NotActionNodeDict_Key;
typedef NSMutableDictionary<NSString*, NotActionNodeDict_Key *>  NotActionNodeDict_Class;

@interface NotActionNode ()
@property (nonatomic, copy) NSString *cls;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *hashKey;
@property (nonatomic, weak) id<NotActionNodeProtocol> nodeObject;
-(void)transmitAction;
-(void)receiveActionWithName:(NSString*)actionName object:(id)object transmitAtOnce:(BOOL)atOnce;
@end

@interface NotActionCenter ()
@property (nonatomic, retain) NotActionNodeDict_Hash *notActionNodeDict_hash;
@property (nonatomic, retain) NotActionNodeDict_Key *notActionNodeDict_key;
@property (nonatomic, retain) NotActionNodeDict_Class *notActionNodeDict_class;
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
    _notActionNodeDict_hash = nil;
    _notActionNodeDict_key = nil;
    _notActionNodeDict_class = nil;
}

#pragma mark- GET SET

-(NotActionNodeDict_Hash *)notActionNodeDict_hash {
    if (!_notActionNodeDict_hash) {
        _notActionNodeDict_hash = [NotActionNodeDict_Hash dictionary];
    }
    return _notActionNodeDict_hash;
}

-(NotActionNodeDict_Key *)notActionNodeDict_key {
    if (!_notActionNodeDict_key) {
        _notActionNodeDict_key = [NotActionNodeDict_Key dictionary];
    }
    return _notActionNodeDict_key;

}

-(NotActionNodeDict_Class *)notActionNodeDict_class {
    if (!_notActionNodeDict_class) {
        _notActionNodeDict_class = [NotActionNodeDict_Class dictionary];
    }
    return _notActionNodeDict_class;
}

#pragma mark- pushNotAction

-(void)pushActionAtOnce:(BOOL)atOnce toClass:(Class)cls key:(NSString*)key actionName:(NSString*)actionName object:(id)object {
    [NotActionCenter actionQueuSyncDo:^{
        NSString *_actionName = actionName?actionName:@"";
        if (cls == nil) {
            if (key.length == 0) {
                [self _transmitActionToNodeDict:_notActionNodeDict_hash atOnce:atOnce actionName:_actionName object:object];
            }else{
                NotActionNodeDict_Hash *dict1 = [_notActionNodeDict_key objectForKey:key];
                [self _transmitActionToNodeDict:dict1 atOnce:atOnce actionName:_actionName object:object];
            }
        }else if ([cls conformsToProtocol:@protocol(NotActionNodeProtocol)]) {
            NSString* class = NSStringFromClass([cls class]);
            NotActionNodeDict_Key *dict0 = [_notActionNodeDict_class objectForKey:class];
            if (key.length == 0){
                NSArray *arr = [dict0 allValues];
                for (NotActionNodeDict_Hash *dict1 in arr) {
                    [self _transmitActionToNodeDict:dict1 atOnce:atOnce actionName:_actionName object:object];
                }
            }else{
                NotActionNodeDict_Hash *dict1 = [dict0 objectForKey:key];
                [self _transmitActionToNodeDict:dict1 atOnce:atOnce actionName:_actionName object:object];
            }
        }else{
            NSString *error = [NSString stringWithFormat:@"⚠️ toClass: %@ 未继承NotActionNodeProtocol协议", NSStringFromClass(cls)];
//            NSException *excp = [NSException exceptionWithName:@"NotAction Error" reason:error userInfo:nil];
            NSAssert(NO, error);
//            [excp raise];
        }
    }];
}

-(void)pushActionAtOnce:(BOOL)atOnce toNotActionNode:(NSObject<NotActionNodeProtocol>*)node actionName:(NSString*)actionName object:(id)object {
    [NotActionCenter actionQueuSyncDo:^{
        NSString *_actionName = actionName?actionName:@"";
        NSString* hashKey = [NSString stringWithFormat:@"%ld", node.hash];
        NotActionNode *notActionNode = [_notActionNodeDict_hash objectForKey:hashKey];
        [self _transmitActionToNode:notActionNode atOnce:atOnce actionName:_actionName object:object];
    }];
}


-(void)manualTriggerWithNode:(NSObject<NotActionNodeProtocol>*)node {
    [NotActionCenter actionQueuSyncDo:^{
        NSString* hashKey = [NSString stringWithFormat:@"%ld", node.hash];
        NotActionNode *notActionNode = [_notActionNodeDict_hash objectForKey:hashKey];
        if (notActionNode) {
            if ([self isLiveCheck:notActionNode]) {
                [notActionNode transmitAction];
            }else {
                [self _unMountWithActionNode:notActionNode];
            }
        }
    }];
}

#pragma mark --

-(void)_transmitActionToNodeDict:(NotActionNodeDict_Hash*)dict atOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object {
    NSArray *arr = [dict allValues];
    for (NotActionNode *notActionNode in arr) {
        [self _transmitActionToNode:notActionNode atOnce:atOnce actionName:actionName object:object];
    }
}

-(void)_transmitActionToNode:(NotActionNode*)notActionNode atOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object {
    if (notActionNode) {
        if ([self isLiveCheck:notActionNode]) {
            [notActionNode receiveActionWithName:actionName object:object transmitAtOnce:atOnce];
        }else{
            [self unMountWithActionNode:notActionNode];
        }
    }
}


#pragma mark- unMount

-(void)unMountWithNode:(NSObject<NotActionNodeProtocol>*)node {
    [NotActionCenter actionQueuSyncDo:^{
        NSString* hashKey = [NSString stringWithFormat:@"%ld", node.hash];
        NotActionNode *notActionNode = [_notActionNodeDict_hash objectForKey:hashKey];
        [self _unMountWithActionNode:notActionNode];
    }];
}

-(void)unMountWithActionNode:(NotActionNode*)notActionNode {
    if (notActionNode) {
        [NotActionCenter actionQueuSyncDo:^{
            [self _unMountWithActionNode:notActionNode];
        }];
    }
}

#pragma mark --

-(void)_unMountWithActionNode:(NotActionNode*)notActionNode {
    NSString *hashKey = notActionNode.hashKey;
    if ([_notActionNodeDict_hash objectForKey:hashKey]) {
        NSString *class = notActionNode.cls;
        NSString *key = notActionNode.key;
        
        NotActionNodeDict_Key *dict0 = [_notActionNodeDict_class objectForKey:class];
        NotActionNodeDict_Hash *dict1 = [dict0 objectForKey:key];
        [dict1 removeObjectForKey:hashKey];
        if (dict1.allKeys.count == 0) {
            [dict0 removeObjectForKey:key];
        }
        if (dict0.allKeys.count == 0) {
            [_notActionNodeDict_class removeObjectForKey:class];
        }
        
        dict1 = [_notActionNodeDict_key objectForKey:key];
        [dict1 removeObjectForKey:hashKey];
        if (dict1.allKeys.count == 0) {
            [_notActionNodeDict_key removeObjectForKey:key];
        }
        
        [_notActionNodeDict_hash removeObjectForKey:hashKey];
    }
}

#pragma mark- mount



-(void)mountWithNode:(NSObject<NotActionNodeProtocol>*)node key:(NSString*)key {
    [NotActionCenter actionQueuSyncDo:^{
        NSString* hashKey = [NSString stringWithFormat:@"%ld", node.hash];
        NotActionNode *notActionNode;
        notActionNode = [self.notActionNodeDict_hash objectForKey:hashKey];
        
        NSString* class = NSStringFromClass([node class]);
        NSString* newKey = key.length>0?key:class;
        NSString* oldKey = notActionNode.key;
        
        if (oldKey) {
            if ([oldKey isEqualToString:newKey]) {
                return;
            }
            [self _unMountWithActionNode:notActionNode];
        }
        
        notActionNode = [[NotActionNode alloc] init];
        notActionNode.cls = class;
        notActionNode.key = newKey;
        notActionNode.hashKey = hashKey;
        notActionNode.nodeObject = node;
        
        NotActionNodeDict_Key *dict0 = [self.notActionNodeDict_class objectForKey:class];
        if (!dict0) {
            dict0 = [NotActionNodeDict_Key dictionary];
            [self.notActionNodeDict_class setObject:dict0 forKey:class];
        }
        
        NotActionNodeDict_Hash *dict1 = [dict0 objectForKey:newKey];
        if (!dict1) {
            dict1 = [NotActionNodeDict_Hash dictionary];
            [dict0 setObject:dict1 forKey:newKey];
        }
        [dict1 setObject:notActionNode forKey:hashKey];
        
        dict1 = [self.notActionNodeDict_key objectForKey:newKey];
        if (!dict1) {
            dict1 = [NotActionNodeDict_Hash dictionary];
            [self.notActionNodeDict_key setObject:dict1 forKey:newKey];
        }
        [dict1 setObject:notActionNode forKey:hashKey];
        
        [self.notActionNodeDict_hash setObject:notActionNode forKey:hashKey];
        [self unLiveClear_start];
    }];
}

#pragma mark- unLiveClear

-(void)unLiveClear_start {
    if (!self.unLiveClearing) {
        [self unLiveClear_next];
    }
}

-(void)unLiveClear_next {
    if([_notActionNodeDict_hash allValues].count>0){
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
        NSArray * arr = [_notActionNodeDict_hash allValues];
        for (NotActionNode *notActionNode in arr) {
            if (notActionNode && ![self isLiveCheck:notActionNode]) {
                [self unMountWithActionNode:notActionNode];
            }
        }
        [self unLiveClear_next];
    }];
}

-(BOOL)isLiveCheck:(NotActionNode*)notActionNode {
    if (notActionNode.nodeObject && [_notActionNodeDict_hash objectForKey:notActionNode.hashKey]) {
        return YES;
    }else{
        return NO;
    }
}
@end


#pragma mark - 
#pragma mark - NotActionCenter_Interface

@implementation NotActionCenter (Interface)

-(void)pushActionAtOnce:(BOOL)atOnce toClass:(Class)cls actionName:(NSString*)actionName object:(id)object {
    [self pushActionAtOnce:atOnce toClass:cls key:nil actionName:actionName object:object];
}

-(void)pushActionAtOnce:(BOOL)atOnce toKey:(NSString*)key actionName:(NSString*)actionName object:(id)object {
    [self pushActionAtOnce:atOnce toClass:nil key:key actionName:actionName object:object];
}

-(void)pushActionAtOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object {
    [self pushActionAtOnce:atOnce toClass:nil key:nil actionName:actionName object:object];
}

-(void)pushActionAtOnce:(BOOL)atOnce toClassString:(NSString*)cls key:(NSString*)key actionName:(NSString*)actionName object:(id)object {
    Class c = NSClassFromString(cls);
    if (c) {
        [self pushActionAtOnce:atOnce toClass:c key:key actionName:actionName object:object];
    }
}

-(void)pushActionAtOnce:(BOOL)atOnce toClassString:(NSString*)cls actionName:(NSString*)actionName object:(id)object {
    [self pushActionAtOnce:atOnce toClassString:cls key:nil actionName:actionName object:object];
}

-(void)pushActionAtOnce:(BOOL)atOnce toClassStringArray:(NSArray<NSString*>*)clsArray actionName:(NSString*)actionName object:(id)object {
    for (NSString*cls in clsArray) {
        [self pushActionAtOnce:atOnce toClassString:cls actionName:actionName object:object];
    }
}

@end
