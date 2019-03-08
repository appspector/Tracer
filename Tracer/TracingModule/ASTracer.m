//
//  ASTracer.m
//  Package
//
//  Created by Deszip on 01/03/2019.
//  Copyright © 2019 AppSpector. All rights reserved.
//

#import "ASTracer.h"

@import os.signpost;

#import "ASScope.h"
#import "ASSpan.h"

#import <objc/runtime.h>
#import <objc/message.h> // for objc_msgSend

#pragma mark - Runtime tools -

static NSString * const APS_SWIZZLE_PREFIX = @"aps_";
static inline SEL aps_swizzled_selector(SEL original_selector) {
    return NSSelectorFromString([APS_SWIZZLE_PREFIX stringByAppendingString:NSStringFromSelector(original_selector)]);
}

static inline void aps_swizzle_method(SEL original_selector, Class target_class, id hook_block) {
    BOOL isInstanceMethod = YES;
    Method original_method = class_getInstanceMethod(target_class, original_selector);
    if (original_method == NULL) {
        original_method = class_getClassMethod(target_class, original_selector);
        if (original_method == NULL) {
            return;
        }
        isInstanceMethod = NO;
    }
    
    IMP implementation = imp_implementationWithBlock(hook_block);
    SEL swizzled_selector = aps_swizzled_selector(original_selector);
    
    BOOL methodAdded = NO;
    if (isInstanceMethod) {
        methodAdded = class_addMethod(target_class, swizzled_selector, implementation, method_getTypeEncoding(original_method));
    } else {
        methodAdded = class_addMethod(objc_getMetaClass(NSStringFromClass(target_class).UTF8String), swizzled_selector, implementation, method_getTypeEncoding(original_method));
    }
    if (!methodAdded) {
        return;
    }
    
    Method newMethod;
    if (isInstanceMethod) {
        newMethod = class_getInstanceMethod(target_class, swizzled_selector);
    } else {
        newMethod = class_getClassMethod(objc_getMetaClass(NSStringFromClass(target_class).UTF8String), swizzled_selector);
    }
    
    method_exchangeImplementations(original_method, newMethod);
}

static const char *subsystem = "com.tracer";
static const char *category = "Behavior";
static os_log_t tracer_log;

static ASTracer *sharedTracer;

@interface ASTracer ()

@property (strong, nonatomic) NSMutableDictionary <NSString *, ASScope *> *scopes;

@end

@implementation ASTracer

+ (instancetype)tracer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTracer = [ASTracer new];
        sharedTracer.scopes = [@{} mutableCopy];
        
        if (@available(iOS 12.0, macOS 10.14, *)) {
            tracer_log = os_log_create(subsystem, category);
        }
    });
    return sharedTracer;
}

#pragma mark - Opeartions API -

static void *ASTracerOperationObservingContext = &ASTracerOperationObservingContext;
static char kOperationQueueKey;

static NSString * const kOperationStartSelector = @"start";
static NSString * const kQueueAddSelector = @"addOperation:";
static NSString * const kOperationExecutingKeyPath = @"isExecuting";
static NSString * const kOperationFinishedKeyPath = @"isFinished";

- (void)startTracingOperations {
    // Start selector for standalone operations
    SEL start_selector = NSSelectorFromString(kOperationStartSelector);
    __auto_type startHook = ^void (id op) {
        id queue = objc_getAssociatedObject(op, &kOperationQueueKey);
        if (!queue) {
            [op addObserver:self forKeyPath:kOperationExecutingKeyPath options:0 context:ASTracerOperationObservingContext];
            [op addObserver:self forKeyPath:kOperationFinishedKeyPath options:0 context:ASTracerOperationObservingContext];
        }
        return ((void(*)(id, SEL))objc_msgSend)(op, aps_swizzled_selector(start_selector));
    };
    aps_swizzle_method(start_selector, [NSOperation class], startHook);
    
    // Add queue selector for operations added to queue
    SEL add_selector = NSSelectorFromString(kQueueAddSelector);
    __auto_type addHook = ^void (id queue, id op) {
        objc_setAssociatedObject(op, &kOperationQueueKey, queue, OBJC_ASSOCIATION_ASSIGN);
        [op addObserver:self forKeyPath:kOperationExecutingKeyPath options:0 context:ASTracerOperationObservingContext];
        [op addObserver:self forKeyPath:kOperationFinishedKeyPath options:0 context:ASTracerOperationObservingContext];
        return ((void(*)(id, SEL, id))objc_msgSend)(queue, aps_swizzled_selector(add_selector), op);
    };
    aps_swizzle_method(add_selector, [NSOperationQueue class], addHook);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == ASTracerOperationObservingContext) {
        id queue = objc_getAssociatedObject(object, &kOperationQueueKey);
        NSString *scopeName = [NSString stringWithFormat:@"%@", queue ? queue : @"No queue"];
        NSString *spanName = [NSString stringWithFormat:@"%@", object];
        
        if ([keyPath isEqualToString:kOperationExecutingKeyPath]) {
            if ([(NSOperation *)object isExecuting] && ![(NSOperation *)object isFinished]) {
                [[ASTracer tracer] addScope:scopeName];
                [[ASTracer tracer] startSpan:spanName inScope:scopeName];
            }
        }
        
        if ([keyPath isEqualToString:kOperationFinishedKeyPath]) {
            if (![(NSOperation *)object isExecuting] && [(NSOperation *)object isFinished]) {
                [[ASTracer tracer] stopSpan:spanName inScope:scopeName success:![(NSOperation *)object isCancelled]];
                [object removeObserver:self forKeyPath:keyPath context:ASTracerOperationObservingContext];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Manual API -

- (ASScope *)addScope:(NSString *)scopeName {
    if (self.scopes[scopeName]) {
        return self.scopes[scopeName];
    }
    
    ASScope *scope = [ASScope scopeWithName:scopeName log:tracer_log];
    self.scopes[scopeName] = scope;
    
    return scope;
}

- (void)removeScope:(NSString *)scopeName {
    [self.scopes removeObjectForKey:scopeName];
}

- (void)startSpan:(NSString *)spanName inScope:(NSString *)scopeName {
    if (@available(iOS 12.0, macOS 10.14, *)) {
        ASScope *scope = self.scopes[scopeName];
        if (!scope) {
            return;
        }
        
        ASSpan *span = [ASSpan spanWithName:spanName log:tracer_log];
        if ([scope addSpan:span]) {
            os_signpost_interval_begin(tracer_log, span.signpostID, "tracing", "span-start:%{public}@,scope-name:%{public}@", span.name, scope.name);
        }
    }
}

- (void)stopSpan:(NSString *)spanName inScope:(NSString *)scopeName success:(BOOL)success {
    if (@available(iOS 12.0, macOS 10.14, *)) {
        ASScope *scope = self.scopes[scopeName];
        if (!scope) {
            return;
        }
        
        ASSpan *span = [scope spanNamed:spanName];
        if (span) {
            int status = success ? 1 : 0;
            os_signpost_interval_end(tracer_log, span.signpostID, "tracing", "span-stop:%{public}@,span-success:%d", span.name, status);
            [scope removeSpan:span.name];
        }
    }
}

@end
