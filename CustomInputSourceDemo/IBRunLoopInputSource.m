//
//  IBRunLoopSource.m
//  CustomInputSourceDemo
//
//  Created by Caowanping on 11/24/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import "IBRunLoopInputSource.h"
#import "IBRunLoopContext.h"
#import "AppDelegate.h"

void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    IBRunLoopInputSource* obj = (__bridge IBRunLoopInputSource*)info;

    IBRunLoopContext * theContext = [[IBRunLoopContext alloc] initWithSource:obj andLoop:rl];
    
    [(AppDelegate *)[NSApp delegate] performSelectorOnMainThread:@selector(registerSource:)
                          withObject:theContext waitUntilDone:NO];
}

void RunLoopSourcePerformRoutine (void *info)
{
    IBRunLoopInputSource*  obj = (__bridge IBRunLoopInputSource*)info;
    [obj sourceCommandsFired];
}

void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    IBRunLoopInputSource* obj = (__bridge IBRunLoopInputSource*)info;
   
    IBRunLoopContext* theContext = [[IBRunLoopContext alloc] initWithSource:obj andLoop:rl];
    
    [(AppDelegate *)[NSApp delegate] performSelectorOnMainThread:@selector(removeSource:)
                          withObject:theContext waitUntilDone:YES];
}

@interface IBRunLoopInputSource ()
{
    CFRunLoopSourceRef _runLoopSource;
    
    NSInteger _currCommand;
}

@property (nonatomic , strong) NSMutableDictionary * commandInfo;

@end

@implementation IBRunLoopInputSource

#pragma mark - Init

- (id)init
{
    self = [super self];
    
    if (self) {
        
        //共有8个回调函数，目前只实现三个
        CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
            &RunLoopSourceScheduleRoutine,
            &RunLoopSourceCancelRoutine,
            &RunLoopSourcePerformRoutine};
        
        _runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
        
    }
    
    return self;
}

- (void)addToCurrentRunLoop
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    
    CFRunLoopAddSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

- (void)invalidateFromCurrentRunLoop
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    
    CFRunLoopRemoveSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

- (void)invalidateFromRunLoop:(CFRunLoopRef )runLoop
{
    CFRunLoopRemoveSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

#pragma mark - Comman Info

- (NSMutableDictionary *)commandInfo
{
    if (!_commandInfo) {
        _commandInfo = [NSMutableDictionary new];
    }
    
    return _commandInfo;
}

#pragma mark - Handler

- (void)sourceCommandsFired
{
    NSLog(@"%s" , __func__);
    
    id data = [self.commandInfo objectForKey:@(_currCommand)];
    
    if (!data) {
        data = [NSString stringWithFormat:@"Empty data for command : %ld" , _currCommand ];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputSourceForTest:)]) {
        [self.delegate inputSourceForTest:data];
    }
   
}

#pragma mark - Command

- (void)addCommand:(NSInteger)command withData:(id)data
{
    if (data)
    {
        [self.commandInfo setObject:data forKey:@(command)];
    }
    
}

- (void)fireCommand:(NSInteger)command onRunLoop:(CFRunLoopRef)runloop
{
    _currCommand = command;
    
    CFRunLoopSourceSignal(_runLoopSource);
    CFRunLoopWakeUp(runloop);
}

@end
