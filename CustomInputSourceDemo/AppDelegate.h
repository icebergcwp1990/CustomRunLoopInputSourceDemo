//
//  AppDelegate.h
//  CustomInputSourceDemo
//
//  Created by Caowanping on 11/24/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IBRunLoopContext;


@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)registerSource:(IBRunLoopContext*)sourceInfo;

- (void)removeSource:(IBRunLoopContext*)sourceInfo;

@end

