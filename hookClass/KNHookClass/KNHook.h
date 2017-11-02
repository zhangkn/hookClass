//
//  KNHook.h
//  hookClass
//
//  Created by devzkn on 02/11/2017.
//  Copyright © 2017 Weiliu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface KNHook : NSObject

+(void)hookClass:(NSString*)hookString;

@end
