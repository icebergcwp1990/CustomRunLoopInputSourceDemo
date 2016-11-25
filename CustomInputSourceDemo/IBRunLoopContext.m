//
//  IBRunLoopContext.m
//  CustomInputSourceDemo
//
//  Created by Caowanping on 11/24/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import "IBRunLoopContext.h"
#import "IBRunLoopInputSource.h"

@implementation IBRunLoopContext

- (id)initWithSource:(IBRunLoopInputSource *)runLoopSource andLoop:(CFRunLoopRef )runLoop
{
    self = [super init];
    if (self) {
        _runLoopInputSource = runLoopSource;
        _runLoop = runLoop;
    }
    return self;
}

@end
