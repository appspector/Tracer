//
//  ViewController.m
//  Tracer
//
//  Created by Deszip on 07/03/2019.
//  Copyright © 2019 AppSpector. All rights reserved.
//

#import "ViewController.h"

#import "ASTracer.h"
#import "ASSampleOperation.h"

static void *ASOperationsCountContext = &ASOperationsCountContext;
static NSString * const kQueueOperationsKey = @"operations";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *queuesLabel;
@property (weak, nonatomic) IBOutlet UILabel *operationsLabel;

@property (strong, nonatomic) NSMutableArray <NSOperationQueue *> *queues;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[ASTracer tracer] startTracingOperations];
    
    self.queues = [NSMutableArray array];
    [self updateCounters];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UI updates -

- (void)startObserving:(NSOperationQueue *)queue {
    [queue addObserver:self forKeyPath:kQueueOperationsKey options:0 context:ASOperationsCountContext];
}

- (void)stopObserving:(NSOperationQueue *)queue {
    [queue removeObserver:self forKeyPath:kQueueOperationsKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == ASOperationsCountContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateCounters];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateCounters {
    [self.queuesLabel setText:[NSString stringWithFormat:@"%li", self.queues.count]];
    __block NSUInteger operationsCount = 0;
    [self.queues enumerateObjectsUsingBlock:^(NSOperationQueue *queue, NSUInteger idx, BOOL *stop) {
        operationsCount += queue.operations.count;
    }];
    [self.operationsLabel setText:[NSString stringWithFormat:@"%li", operationsCount]];
}

#pragma mark - Actions -

- (IBAction)addQueue:(id)sender {
    NSOperationQueue *queue = [NSOperationQueue new];
    [self.queues addObject:queue];
    [self startObserving:queue];
    [self updateCounters];
}

- (IBAction)removeLastQueue:(id)sender {
    if (self.queues.count > 0) {
        NSOperationQueue *queue = [self.queues lastObject];
        [queue cancelAllOperations];
        [self stopObserving:queue];
        [self.queues removeObject:queue];
        [self updateCounters];
    }
}

- (IBAction)addOperation:(id)sender {
    if (self.queues.count > 0) {
        NSUInteger queueIndex = arc4random_uniform((uint32_t)self.queues.count);
        ASSampleOperation *op = [ASSampleOperation new];
        [self.queues[queueIndex] addOperation:op];
    }
}

- (IBAction)cancelOperation {
    [self.queues enumerateObjectsUsingBlock:^(NSOperationQueue *queue, NSUInteger idx, BOOL *stop) {
        if (queue.operations.count > 0) {
            [[queue.operations firstObject] cancel];
            *stop = YES;
        }
    }];
}

@end
