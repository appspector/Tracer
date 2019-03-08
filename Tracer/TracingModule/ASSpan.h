//
//  ASSpan.h
//  Package
//
//  Created by Deszip on 01/03/2019.
//  Copyright © 2019 AppSpector. All rights reserved.
//

#import <Foundation/Foundation.h>
@import os.signpost;

NS_ASSUME_NONNULL_BEGIN

@interface ASSpan : NSObject

@property (copy, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly) os_signpost_id_t signpostID;

+ (instancetype)spanWithName:(NSString *)name log:(os_log_t)log;

@end

NS_ASSUME_NONNULL_END
