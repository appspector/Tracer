//
//  ASScope.m
//  Package
//
//  Created by Deszip on 01/03/2019.
//  Copyright © 2019 AppSpector. All rights reserved.
//

#import "ASScope.h"

@interface ASScope ()

@property (strong, nonatomic) NSMutableDictionary <NSString *, ASSpan *> *spans;

@end

@implementation ASScope

+ (instancetype)scopeWithName:(NSString *)name log:(os_log_t)log {
    return [[ASScope alloc] initWithName:name log:log];
}

- (instancetype)initWithName:(NSString *)name log:(os_log_t)log {
    if (self = [super init]) {
        _spans = [NSMutableDictionary dictionary];
        _name = name;
        if (@available(iOS 12.0, macOS 10.14, *)) {
            _signpostID = os_signpost_id_make_with_id(log, self);
        } else {
            _signpostID = 0;
        }
    }
    
    return self;
}

- (BOOL)addSpan:(ASSpan *)span {
    if (self.spans[span.name]) {
        return NO;
    }
    
    self.spans[span.name] = span;
    return YES;
}

- (void)removeSpan:(NSString *)spanName {
    [self.spans removeObjectForKey:spanName];
}

- (ASSpan *)spanNamed:(NSString *)spanName {
    return self.spans[spanName];
}

- (NSUInteger)spanCount {
    return self.spans.count;
}

@end
