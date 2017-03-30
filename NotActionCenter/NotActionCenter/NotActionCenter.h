//
//  NotActionCenter.h
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotActionNode.h"

@interface NotActionCenter : NSObject

-(void)pushNotActionAtOnce:(BOOL)atOnce toClass:(Class<NotActionNodeProtocol>)cls key:(NSString*)key actionName:(NSString*)actionName object:(id)object;

-(void)pushNotActionAtOnce:(BOOL)atOnce toClass:(Class<NotActionNodeProtocol>)cls actionName:(NSString*)actionName object:(id)object;

-(void)pushNotActionAtOnce:(BOOL)atOnce actionName:(NSString*)actionName object:(id)object;

+(NotActionCenter*)defaultCenter;

@end
