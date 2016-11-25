//
//  IBRunLoopContext.h
//  CustomInputSourceDemo
//
//  Created by Caowanping on 11/24/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IBRunLoopInputSource;

@interface IBRunLoopContext : NSObject

@property (nonatomic, readonly) CFRunLoopRef runLoop;

@property (nonatomic, readonly) IBRunLoopInputSource * runLoopInputSource;

- (id)initWithSource:(IBRunLoopInputSource *)runLoopSource andLoop:(CFRunLoopRef )runLoop;

@end
