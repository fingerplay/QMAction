//
//  QMRuntimeHelper.m
//  juanpi3
//
//  Created by 罗谨 on 15/6/24.
//  Copyright (c) 2015年 罗谨. All rights reserved.
//

#import "QMRuntimeHelper.h"
#import <objc/runtime.h>

@implementation QMRuntimeHelper

+(void)setMethodSwizzlingForClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector isInstanceMethod:(BOOL)isInstanceMethod {
    Method originalMethod;
    Method swizzledMethod;
    
    if (isInstanceMethod) {
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    } else {
        originalMethod = class_getClassMethod(class, originalSelector);
        swizzledMethod = class_getClassMethod(class, swizzledSelector);
    }

 
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (BOOL)isClass:(Class)class hasProperty:(NSString *)propertyName {
    return (class_getProperty(class, [propertyName UTF8String]) != NULL);
}

+ (void)printPropertiesOfClass:(Class)class {
    unsigned int count = 0;
    objc_property_t *propList = class_copyPropertyList(class, &count);
    for (int i=0; i<count; i++) {
        objc_property_t property = propList[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        NSLog(@"proprty = %@",propertyName);
    }
    free(propList);

}


+(BOOL)isClass:(Class)class hasInstanceMethod:(NSString*)instanceMethodName {
    SEL selector = NSSelectorFromString(instanceMethodName);
    Method method = class_getInstanceMethod(class, selector);
    return (method != NULL);
}

+(BOOL)isClass:(Class)class hasClassMethod:(NSString *)classMethodName {
    SEL selector = NSSelectorFromString(classMethodName);
    Method method = class_getClassMethod(class,selector);
    return (method != NULL);
}

+ (BOOL)isClassExist:(NSString *)className {
    Class class = objc_getClass([className UTF8String]);
    return (class!=nil);
}

+ (BOOL)hookMethodForClass:(Class)class originalMethod:(NSString*)originalMethodName isInstanceMethod:(BOOL)isInstanceMethod hookedBlock:(RuntimeHookBlock)block {
    NSString *hookedMethodName = [NSString stringWithFormat:@"hook%@",originalMethodName];
    SEL hookedSelector = NSSelectorFromString(hookedMethodName);
    
    Method originalMethod;
    if (isInstanceMethod) {
        originalMethod = class_getInstanceMethod(class, NSSelectorFromString(originalMethodName));
    } else {
        originalMethod = class_getClassMethod(class, NSSelectorFromString(originalMethodName));
    }
  
    //return type
    char* returnType = (char*)malloc(sizeof(char));
    returnType = method_copyReturnType(originalMethod);
//    printf("returnType %s ", returnType);
    //argument type
    unsigned int argumentCount = method_getNumberOfArguments(originalMethod);
    //最多保存4个参数，前面两个固定的，后面是可变的
    char* argumentType = malloc(sizeof(char)*4);
    memset(argumentType, 0, 4);
    for (unsigned int i = 0; i<argumentCount; i++) {
        method_getArgumentType(originalMethod, i, &argumentType[i], 1);
    }
    
    IMP imp;
    char *argTypes = malloc(sizeof(char) * (argumentCount+1));
    memset(argTypes, 0, argumentCount +1);
    argTypes[0] = *returnType;
//    argTypes = strcpy(argTypes, returnType);
    if (argumentCount == 2) {
        imp = imp_implementationWithBlock(^id (id _self) {
            id object = class;
            if (isInstanceMethod) {
                object = _self;
            }
            id returnValue = [QMRuntimeHelper performHookedMethod:hookedSelector withArgs:@[] forObject:object isInstanceMethod:isInstanceMethod];
            if (block) {
                block(_self, @[]);
            }

            return returnValue;
        });
        argTypes = strcat(argTypes, argumentType);

    } else if (argumentCount == 3) {
        imp = imp_implementationWithBlock(^id (id _self, id arg1){
            id returnValue;
            id object = class;
            if (isInstanceMethod) {
                object = _self;
            }
            if (arg1) {
                returnValue = [QMRuntimeHelper performHookedMethod:hookedSelector withArgs:@[arg1] forObject:object isInstanceMethod:isInstanceMethod];
                if (block) {
                    block(_self, @[arg1]);
                }
            } else {
                returnValue = [QMRuntimeHelper performHookedMethod:hookedSelector withArgs:@[] forObject:object isInstanceMethod:isInstanceMethod];
                if (block) {
                    block(_self, @[]);
                }
            }

            return returnValue;
        });
        argTypes = strcat(argTypes, argumentType);

    } else if (argumentCount == 4) {
        imp = imp_implementationWithBlock(^id (id _self, id arg1, id arg2){
            id object = class;
            if (isInstanceMethod) {
                object = _self;
            }
            id returnValue = [QMRuntimeHelper performHookedMethod:hookedSelector withArgs:@[arg1,arg2] forObject:object isInstanceMethod:isInstanceMethod];;

            if (block) {
                block(_self,@[arg1,arg2]);
            }
            return returnValue;
        });
        argTypes = strcat(argTypes, argumentType) ;


    }
    
    IMP originImp = method_getImplementation(originalMethod);
    BOOL succ;
    if (isInstanceMethod) {
        succ = class_addMethod(class, hookedSelector, originImp, argTypes);
    } else {
        succ = class_addMethod(object_getClass(class), hookedSelector, originImp, argTypes);
    }
    
    free(argTypes);
    free(returnType);
    method_setImplementation(originalMethod, imp);
//    free(returnType);
    return succ;
}

+ (id)performHookedMethod:(SEL)hookedSelector withArgs:(NSArray*)args forObject:(id)object isInstanceMethod:(BOOL)isInstanceMethod {
    id returnValue;
//    id arg1,arg2;
//    if (args.count >0) {
//        arg1 = args[0];
//    }
//    if (args.count >1) {
//        arg2 = args[1];
//    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
   
    if ([object respondsToSelector:hookedSelector]) {
        returnValue =[object performSelector:hookedSelector];
    }
   
#pragma clang diagnostic pop
    return returnValue;
}

+ (id)methodBlockForClass:(Class)class method:(SEL)methodSelector {
    IMP imp = class_getMethodImplementation(class, methodSelector);
    return imp_getBlock(imp);
}

+ (NSArray *)getClassesThatConfirmToProtocol:(Protocol *)protocol {
    NSMutableArray *classes = [NSMutableArray array];
    unsigned int classCount;
    Class* classList = objc_copyClassList(&classCount);

    int i;
    for (i=0; i<classCount; i++) {
        const char *className = class_getName(classList[i]);
        Class thisClass = objc_getClass(className);
        if (class_conformsToProtocol(thisClass, protocol)) {
            [classes addObject:thisClass];
        }
    }
    free(classList);
    return classes;
}

@end


