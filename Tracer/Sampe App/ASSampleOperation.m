//
//  ASSampleOperation.m
//  Tracer
//
//  Created by Deszip on 07/03/2019.
//  Copyright © 2019 AppSpector. All rights reserved.
//

#import "ASSampleOperation.h"

@interface ASSampleOperation ()



@property (assign, nonatomic) BOOL processing;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger ticksTotal;
@property (assign, nonatomic) NSUInteger ticksPassed;

@end

@implementation ASSampleOperation

- (void)setProcessing:(BOOL)processingState {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _processing = processingState;
    
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isFinished {
    return !self.processing;
}

- (BOOL)isExecuting {
    return self.processing;
}

- (void)start {
    if (self.isCancelled) {
        return;
    }
    
    [self setProcessing:YES];
    
    self.ticksTotal = arc4random_uniform(10);
    self.ticksPassed = 0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(doWork)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

- (void)cancel {
    [super cancel];
    [self finish];
}

- (void)finish {
    [self setProcessing:NO];
}

- (void)doWork {
    self.ticksPassed += 1;
    
    if (self.isCancelled || self.ticksPassed > self.ticksTotal) {
        [self.timer invalidate];
        [self finish];
        return;
    }
    
    NSLog(@"%@: working, %lu / %lu", self, (unsigned long)self.ticksPassed, (unsigned long)self.ticksTotal);
}

@end
