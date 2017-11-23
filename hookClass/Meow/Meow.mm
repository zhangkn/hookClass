//
//  Meow.m
//  Meow
//
//  Created by BlueCocoa on 2017/8/25.
//  Copyright © 2017 BlueCocoa. All rights reserved.
//

#import "Meow.h"
#import <map>
#import "choose.h"
#import "fishhook.h"

#pragma mark
#pragma mark - global definitions / variables

static std::map<Class, Meow *> classMeow;
static NSMutableArray * meowmeow; // store all Meow objects
static void __attribute__((constructor)) meow_initializer(); // init the meowmeow array above
static void meow_find_ivar_belong_and_print(long long * object);
static void meow_ivar_adding_to_class(Class);

#pragma mark
#pragma mark - directly access to ivar

static void(*meow_orig_objc_storeStrong)(long long * object, id value);
static void meow_objc_storeStrong(long long *object, id value);

static void(*meow_orig_objc_storeWeak)(long long * object, id value);
static void meow_objc_storeWeak(long long * object, id value);

#pragma mark
#pragma mark - add ivar in runtime

static void(*meow_orig_class_addIvar)(Class _Nullable cls, const char * _Nonnull name, size_t size,
                                      uint8_t alignment, const char * _Nullable types);
static void meow_class_addIvar(Class _Nullable cls, const char * _Nonnull name, size_t size,
                               uint8_t alignment, const char * _Nullable types);

static void(*meow_orig_class_addProperty)(Class _Nullable cls, const char * _Nonnull name,
                                          const objc_property_attribute_t * _Nullable attributes,
                                          unsigned int attributeCount);
static void meow_class_addProperty(Class _Nullable cls, const char * _Nonnull name,
                                   const objc_property_attribute_t * _Nullable attributes,
                                   unsigned int attributeCount);

static id(*meow_orig_class_createInstance)(Class _Nullable cls, size_t extraBytes);
static id meow_class_createInstance(Class _Nullable cls, size_t extraBytes);

#define FOR_EACH_IVAR_START(class)\
unsigned int classIvarCount_ ## __LINE__;\
Ivar * ivars_ ## __LINE__ = class_copyIvarList(class, &classIvarCount_ ## __LINE__);\
for (int ivar_iterator_ ## __LINE__ = 0; ivar_iterator_ ## __LINE__ < classIvarCount_ ## __LINE__; ivar_iterator_ ## __LINE__ ++) {\
Ivar ivar = ivars_ ## __LINE__[ivar_iterator_ ## __LINE__];

#define FOR_EACH_IVAR_END }

#pragma mark
#pragma mark - \Meow/

@interface Meow()

/// the class
@property (readonly, getter=theClass) Class _class;

/// current _class instance size
@property size_t classSize;

/// all instace of _class
@property (nonatomic) NSMutableArray * objects;

@end

@implementation Meow

+ (void)printAllIvar:(id)object {
    FOR_EACH_IVAR_START([object class])
        const char * name = ivar_getName(ivar);
        NSLog(@"[INFO] %@ - ivar<%s>:%@\n", object, name, object_getIvar(object, ivar));
    FOR_EACH_IVAR_END
}

+ (void)printAllIvarOfClass:(Class)aClass {
    FOR_EACH_IVAR_START(aClass)
        const char * name = ivar_getName(ivar);
        NSLog(@"[INFO] %@ - ivar:%s\n", aClass, name);
    FOR_EACH_IVAR_END
}

+ (void)printAllIvar:(id)object withBlock:(meow_for_each_ivar_block)foreach {
    FOR_EACH_IVAR_START([object class])
        foreach(object, ivar);
    FOR_EACH_IVAR_END
}

+ (void)initWithClass:(Class)aClass {
    // check input
    if (!object_isClass(aClass)) return;
    
    // whether this class is being monitored or not
    Meow * meow = nil;
    if (classMeow.find(aClass) == classMeow.end()) {
        meow = [[Meow alloc] init];
        [meow setClass:aClass];
        [meowmeow addObject:meow];
    } else {
        meow = classMeow[aClass];
    }
}

+ (void)initWithClassName:(NSString *)className {
    [self initWithClass:objc_getClass(className.UTF8String)];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.objects = [NSMutableArray new];
    }
    return self;
}

- (void)setClass:(Class)aClass {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        [self setValue:aClass forKey:@"_class"];
        
        // directly acccess
        rebind_symbols((struct rebinding []){
            {"objc_storeStrong", (void *)meow_objc_storeStrong, (void **)&meow_orig_objc_storeStrong},
            {"objc_storeWeak", (void *)meow_objc_storeWeak, (void **)&meow_orig_objc_storeWeak}
        }, 2);
        
        // add ivar in runtime
        rebind_symbols((struct rebinding []){
            {"class_addIvar", (void *)meow_class_addIvar, (void **)&meow_orig_class_addIvar},
            {"class_addProperty", (void *)meow_class_addProperty, (void **)&meow_orig_class_addProperty}
        }, 2);
        
        // hook class_createInstance
        rebind_symbols((struct rebinding []){
            {"class_createInstance", (void *)meow_class_createInstance, (void **)&meow_orig_class_createInstance}
        }, 1);
        
        // hook [aClass init]
        Method initMethod = class_getInstanceMethod(aClass, @selector(init));
        IMP meow_orig_init = method_getImplementation(initMethod);
        IMP meow_init = imp_implementationWithBlock(^(id object, SEL sel){
            id obj = ((id(*)(id, SEL))(meow_orig_init))(object, sel);
            
            // hold weak reference to that object
            __weak id weakObject = obj;
            NSLog(@"[INFO] new object of %s. range <%p, %p>", class_getName(self._class), obj, (long long *)(__bridge void *)(obj) + self.classSize);
            [self.objects addObject:weakObject];
            return obj;
        });
        class_replaceMethod(self._class, @selector(init), meow_init, "@@:@");
        
        [self updateIvarList];
        [self updateObjects];
    });
}

- (void)updateIvarList {
    self.classSize = class_getInstanceSize(self._class);
    
    NSLog(@"[INFO] update ivar list for <%@>", self._class);
    [Meow printAllIvarOfClass:self._class];
}

- (void)updateObjects {
    NSArray * objects = [choose choose:self._class];
    for (id object in objects) {
        NSLog(@"[INFO] object:%@", object);
        [Meow printAllIvar:object];
        
        // hold weak reference to those objects
        __weak id weakObject = object;
        [self.objects addObject:weakObject];
    }
}

@end

void __attribute__((constructor)) meow_initializer() {
    meowmeow = [NSMutableArray new];
}

void meow_find_ivar_belong_and_print(long long * object) {
    BOOL keepFinding = YES;
    for (int i = 0; keepFinding && i < meowmeow.count; i++) {
        Meow * meow = meowmeow[i];
        for (int j = 0; keepFinding && j < meow.objects.count; j++) {
            id obj = meow.objects[j];
            if ((long long *)(__bridge void *)(obj) < object && object < (long long *)(__bridge void *)(obj) + meow.classSize) {
                keepFinding = NO;
                NSLog(@"[INFO] object:%@ ivar changed", obj);
                [Meow printAllIvar:obj withBlock:^(id object, Ivar ivar) {
                    const char * name = ivar_getName(ivar);
                    NSLog(@"[INFO]        %@ - ivar<%s>:%@\n", obj, name, object_getIvar(obj, ivar));
                }];
            }
        }
    }
}

void meow_ivar_adding_to_class(Class cls) {
    BOOL keepFinding = YES;
    for (int i = 0; keepFinding && i < meowmeow.count; i++) {
        Meow * meow = meowmeow[i];
        if (strcmp(class_getName(meow._class), class_getName(cls)) == 0) {
            [meow updateIvarList];
            keepFinding = NO;
        }
    }
}

void meow_objc_storeStrong(long long *object, id value) {
    meow_orig_objc_storeStrong(object, value);
    if (!(*object == 0 && value == nil)) {
        meow_find_ivar_belong_and_print(object);
    }
}

void meow_objc_storeWeak(long long *object, id value) {
    meow_orig_objc_storeWeak(object, value);
    if (!(*object == 0 && value == nil)) {
        meow_find_ivar_belong_and_print(object);
    }
}

void meow_class_addIvar(Class _Nullable cls, const char * _Nonnull name, size_t size,
                               uint8_t alignment, const char * _Nullable types) {
    meow_orig_class_addIvar(cls, name, size, alignment, types);
    meow_ivar_adding_to_class(cls);
}

static void meow_class_addProperty(Class _Nullable cls, const char * _Nonnull name,
                                   const objc_property_attribute_t * _Nullable attributes,
                                   unsigned int attributeCount) {
    meow_orig_class_addProperty(cls, name, attributes, attributeCount);
    meow_ivar_adding_to_class(cls);
}

static id meow_class_createInstance(Class _Nullable cls, size_t extraBytes) {
    id obj = meow_orig_class_createInstance(cls, extraBytes);
    if (classMeow.find(cls) != classMeow.end()) {
        Meow * meow = classMeow[cls];
        __weak id weakObject = obj;
        [meow.objects addObject:weakObject];
    }
    return obj;
}

