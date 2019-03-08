//
//  ASTracer.h
//  Package
//
//  Created by Deszip on 01/03/2019.
//  Copyright © 2019 AppSpector. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASScope.h"

NS_ASSUME_NONNULL_BEGIN

@interface ASTracer : NSObject

+ (instancetype)tracer;

- (void)startTracingOperations;

- (ASScope *)addScope:(NSString *)scopeName;
- (void)removeScope:(NSString *)scopeName;
- (void)startSpan:(NSString *)spanName inScope:(NSString *)scopeName;
- (void)stopSpan:(NSString *)spanName inScope:(NSString *)scopeName success:(BOOL)success;
    
@end

NS_ASSUME_NONNULL_END
