//
//  AppDelegate.m
//  CustomInputSourceDemo
//
//  Created by Caowanping on 11/24/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import "AppDelegate.h"
#import "IBRunLoopContext.h"
#import "IBRunLoopInputSource.h"
#import "IBRunLoopInputSourceThread.h"

@interface AppDelegate ()
{
    
}

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic , strong) NSMutableArray * sourcesToPing;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self startWorkThread];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - Work Thread

- (void)startWorkThread
{
    IBRunLoopInputSourceThread * workThread = [IBRunLoopInputSourceThread new];
    
    [workThread start];
}

#pragma mark - Creator

- (NSMutableArray *)sourcesToPing
{
    if (!_sourcesToPing) {
        _sourcesToPing = [NSMutableArray new];
    }
    
    return _sourcesToPing;
}

#pragma mark - IBAction

- (IBAction)Command_1_ButtonDidClicked:(id)sender
{
    [self addCommand:1 withData:[NSString stringWithFormat:@"Command 1 date: %@" ,[[NSDate date] description]]];
}

- (IBAction)Command_2_ButtonDidClicked:(id)sender
{
    [self addCommand:2 withData:[NSString stringWithFormat:@"Command 2 date: %@" ,[[NSDate date] description]]];
}

- (IBAction)invalidateInputSource:(id)sender
{
    IBRunLoopContext *runLoopContext = [self.sourcesToPing objectAtIndex:0];
    IBRunLoopInputSource *inputSource = runLoopContext.runLoopInputSource;
    
    //在此处调用invalidate无效，因为此处的RunLoop是主线程的，而非InputSource所在的工作线程
//    [inputSource invalidateFromCurrentRunLoop];
    
    //在InputSource所在的工作线程移除
    [inputSource invalidateFromRunLoop:runLoopContext.runLoop];
    
    
}

#pragma mark - Test

- (void)addCommand:(NSInteger)command withData:(id)data
{
    NSAssert([self.sourcesToPing count] !=  0, @"Empty Input Source...");
    
    if (self.sourcesToPing.count > 0) {
        
        //此处默认取第一个用于测试，可优化
        IBRunLoopContext *runLoopContext = [self.sourcesToPing objectAtIndex:0];
        IBRunLoopInputSource *inputSource = runLoopContext.runLoopInputSource;
        //向数据源添加指令
        [inputSource addCommand:command withData:data];
        //添加后并非要立刻触发，此处仅用于测试
        [inputSource fireCommand:command onRunLoop:runLoopContext.runLoop];
    }
    
}

#pragma mark - Custom Input Source

//注册子线程中InputSource对应的context,用于后续通信
- (void)registerSource:(IBRunLoopContext*)sourceInfo
{
    [self.sourcesToPing addObject:sourceInfo];
}
//移除子线程中InputSource对应的context
- (void)removeSource:(IBRunLoopContext*)sourceInfo
{
    [self.sourcesToPing enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isEqual:sourceInfo])
        {
           [self.sourcesToPing removeObject:obj];
            *stop = YES;
        }
        
    }];
  
}

@end
