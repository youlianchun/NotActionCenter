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
#import "NotActionNode.h"

@interface NotActionCenter ()
+(void)actionQueuSyncDo:(void(^)())syncCode;
-(void)manualTriggerWithNode:(id)node;
-(void)mountWithNode:(id)node key:(NSString*)key;
-(void)unMountWithNode:(id)node;
@end

@interface NSObject ()<NotActionCenterFunction>
@property (nonatomic, copy)NSString *nodeKey;
@property (nonatomic, readonly)BOOL isMountNotAction;
@end

@implementation NSObject (NotAction)

-(void)manualTriggerNotAction {
    [NotActionCenter actionQueuSyncDo:^{
        if (self.isMountNotAction) {
            [[NotActionCenter defaultCenter] manualTriggerWithNode:self];
        }
    }];
}

-(void)mountNotActionWithKey:(NSString*)key {
    [NotActionCenter actionQueuSyncDo:^{
        if (!self.isMountNotAction) {
            NSString *k = key;
            if (k.length == 0) {
                k = NSStringFromClass([self class]);
            }
            [[NotActionCenter defaultCenter] mountWithNode:self key:k];
        }
    }];
}

-(void)unMountNotAction {
    [NotActionCenter actionQueuSyncDo:^{
        if (self.isMountNotAction) {
            [[NotActionCenter defaultCenter] unMountWithNode:self];
            self.nodeKey = nil;
        }
    }];
}

-(BOOL)isMountNotAction {
    if ([self conformsToProtocol:@protocol(NotActionNodeProtocol)]) {
        NSString *nodeKey = objc_getAssociatedObject(self, @selector(nodeKey));
        return nodeKey.length>0;
    }else{
        return NO;
    }
}

-(NSString *)nodeKey {
    NSString *nodeKey = objc_getAssociatedObject(self, @selector(nodeKey));
    if (nodeKey.length == 0) {
        nodeKey = [self uuid];
        self.nodeKey = nodeKey;
    }
    return nodeKey;
}

-(void)setNodeKey:(NSString *)nodeKey {
    objc_setAssociatedObject(self, @selector(nodeKey), nodeKey, OBJC_ASSOCIATION_COPY);
}

- (NSString*)uuid {
    CFUUIDRef uuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, uuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
    CFRelease(uuid);
    CFRelease(uuidString);
    return result;
}

@end
