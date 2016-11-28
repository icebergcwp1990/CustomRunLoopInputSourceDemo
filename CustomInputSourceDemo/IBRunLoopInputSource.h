//
//  IBRunLoopSource.h
//  CustomInputSourceDemo
//
//  Created by Caowanping on 11/24/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBRunLoopContext.h"

@protocol IBRunLoopInputSourceTestDelegate <NSObject>

- (void)inputSourceForTest:(id)data;

@end

//自定义Input Source
@interface IBRunLoopInputSource : NSObject

@property (nonatomic, assign) id<IBRunLoopInputSourceTestDelegate> delegate;
@property (nonatomic, weak) IBRunLoopContext * context;


- (id)init;
- (void)addToCurrentRunLoop;
- (void)invalidateFromCurrentRunLoop;
- (void)invalidateFromRunLoop:(CFRunLoopRef )runLoop;

- (void)performSourceCommands;

- (void)addCommand:(NSInteger)command withData:(id)data;
- (void)fireCommand:(NSInteger)command onRunLoop:(CFRunLoopRef)runloop;

@end
