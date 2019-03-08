//
//  ASSpan.m
//  Package
//
//  Created by Deszip on 01/03/2019.
//  Copyright © 2019 AppSpector. All rights reserved.
//

#import "ASSpan.h"

@implementation ASSpan

+ (instancetype)spanWithName:(NSString *)name log:(os_log_t)log {
    return [[ASSpan alloc] initWithName:name log:log];
}

- (instancetype)initWithName:(NSString *)name log:(os_log_t)log {
    if (self = [super init]) {
        _name = name;
        if (@available(iOS 12.0, macOS 10.14, *)) {
            _signpostID = os_signpost_id_make_with_id(log, self);
        } else {
            _signpostID = 0;
        }
    }
    
    return self;
}

@end
