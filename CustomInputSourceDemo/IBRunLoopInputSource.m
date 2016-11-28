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

#pragma mark - Custom InputSource RunLoop CallBack

//inputsource部署回调
void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    IBRunLoopInputSource* inputSource = (__bridge IBRunLoopInputSource*)info;
    //创建一个context，包含当前输入源和RunLoop
    IBRunLoopContext * theContext = [[IBRunLoopContext alloc] initWithSource:inputSource andLoop:rl];
    //将context传入主线程建立强引用，用于后续操作
    [(AppDelegate *)[NSApp delegate] performSelectorOnMainThread:@selector(registerSource:)
                          withObject:theContext waitUntilDone:NO];
    //InputSource弱引用context，因为context已经强引用InputSource，避免循环引用，用于后续移除操作
    inputSource.context = theContext;
}

//inputsource执行任务回调
void RunLoopSourcePerformRoutine (void *info)
{
    IBRunLoopInputSource*  inputSource = (__bridge IBRunLoopInputSource*)info;
    //执行InputSource相关的处理
    [inputSource performSourceCommands];
}

//inputsource移除回调
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    IBRunLoopInputSource* inputSource = (__bridge IBRunLoopInputSource*)info;
    //移除主线程中InputSource对应的Context引用
    if (inputSource.context)
    {
        [(AppDelegate *)[NSApp delegate] performSelectorOnMainThread:@selector(removeSource:)
                                                          withObject:inputSource.context waitUntilDone:YES];
    }
    
    
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
        
        //InputSource上下文，共有8个回调函数，目前只实现三个
        CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
            &RunLoopSourceScheduleRoutine,
            &RunLoopSourceCancelRoutine,
            &RunLoopSourcePerformRoutine};
        
        //初始化自定义InputSource
        _runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
        
    }
    
    return self;
}

//添加自定义InputSource到当前RunLoop
- (void)addToCurrentRunLoop
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    //添加到当前RunLoop的kCFRunLoopDefaultMode下
    CFRunLoopAddSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

//从当前RunLoop移除自定义InputSource
- (void)invalidateFromCurrentRunLoop
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    
    CFRunLoopRemoveSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

//从指定RunLoop移除自定义InputSource
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

//执行InputSource指令
- (void)performSourceCommands
{
    //根据指令获得对应的数据
    id data = [self.commandInfo objectForKey:@(_currCommand)];
    
    if (!data) {
        data = [NSString stringWithFormat:@"Empty data for command : %ld" , _currCommand ];
    }
    
    //通过代理进行处理
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputSourceForTest:)]) {
        [self.delegate inputSourceForTest:data];
    }
   
}

#pragma mark - Command

//添加指令到InputSource
- (void)addCommand:(NSInteger)command withData:(id)data
{
    if (data)
    {
        [self.commandInfo setObject:data forKey:@(command)];
    }
    
}

//触发InputSource指令
- (void)fireCommand:(NSInteger)command onRunLoop:(CFRunLoopRef)runloop
{
    _currCommand = command;
    
    //通知InputSource准备触发指令
    CFRunLoopSourceSignal(_runLoopSource);
    //唤醒InputSource所在的RunLoop
    CFRunLoopWakeUp(runloop);
}

@end
