//
//  Meow.h
//  Meow
//
//  Created by BlueCocoa on 2017/8/25.
//  Copyright © 2017 BlueCocoa. All rights reserved.
//

#ifndef __MEOW__
#define __MEOW__

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/// Meow relies on choose and fishhook
///  - choose,   https://github.com/BlueCocoa/choose
///  - fishhook, https://github.com/facebook/fishhook

typedef void (^meow_for_each_ivar_block)(id, Ivar);

@interface Meow : NSObject

/// print all ivar (name and value) of given object
+ (void)printAllIvar:(id)object;

/// print all ivar name of given class
+ (void)printAllIvarOfClass:(Class)aClass;

/// iterate each ivar in given object
+ (void)printAllIvar:(id)object withBlock:(meow_for_each_ivar_block)foreach;

/// monitoring class
+ (void)initWithClass:(Class)aClass;
+ (void)initWithClassName:(NSString *)className;

@end

#endif /* __MEOW__ */

