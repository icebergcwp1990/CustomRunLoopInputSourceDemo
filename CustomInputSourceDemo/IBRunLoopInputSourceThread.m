//
//  IBRunLoopInputSourceThread.m
//  CustomInputSourceDemo
//
//  Created by Caowanping on 11/24/16.
//  Copyright (c) 2016 iceberg. All rights reserved.
//

#import "IBRunLoopInputSourceThread.h"
#import "IBRunLoopInputSource.h"

#pragma mark - RunLoop Observer CallBack

void runLoopObserverCallBack (CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    switch (activity)
    {
        case kCFRunLoopEntry:
            NSLog(@"RunLoop Entry...");
            break;
        case kCFRunLoopBeforeTimers:
             NSLog(@"RunLoop Before Timers...");
            break;
        case kCFRunLoopBeforeSources:
             NSLog(@"RunLoop Before Sources...");
            break;
        case kCFRunLoopBeforeWaiting:
             NSLog(@"RunLoop Before Waiting...");
            break;
        case kCFRunLoopAfterWaiting:
             NSLog(@"RunLoop After Waiting...");
            break;
        case kCFRunLoopExit:
             NSLog(@"RunLoop Exit...");
            break;
            
        default:
            break;
    }
}

#pragma mark - IBRunLoopInputSourceThread Class

@interface IBRunLoopInputSourceThread ()<IBRunLoopInputSourceTestDelegate>

@property (nonatomic , strong) IBRunLoopInputSource * inputSource;

@end

@implementation IBRunLoopInputSourceThread

- (void)main
{
    @autoreleasepool {
      
        //创建InputSource
        self.inputSource = [[IBRunLoopInputSource alloc] init];
        [self.inputSource setDelegate:self];
        //添加InputSource到当前线程RunLoop
        [self.inputSource addToCurrentRunLoop];
        //配置RunLoop监听器
        [self configureRunLoopObserver];
        
        while (!self.cancelled) {
            
            //作为对照，执行线程其他非InputSource任务
            [self doOtherTask];
            //切入RunLoop
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
        }
        
    }
}

//配置RunLoop监听器
- (void)configureRunLoopObserver
{
    NSRunLoop * currentRunLoop = [NSRunLoop currentRunLoop];
    
    CFRunLoopObserverContext context = {0,(__bridge void *)(self) , NULL , NULL , NULL};
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(
                                                            kCFAllocatorDefault,
                                                            kCFRunLoopAllActivities,
                                                            YES,
                                                            0,
                                                            &runLoopObserverCallBack,
                                                            &context);
    
    if (observer) {
        CFRunLoopAddObserver([currentRunLoop getCFRunLoop], observer, kCFRunLoopDefaultMode);
    }
}

- (void)doOtherTask
{
    NSLog(@"Do other task: 🐴🐴🐴🐴🐴🐴🐴🐴🐴🐴");

}

#pragma mark - IBRunLoopInputSourceTestDelegate

//处理InputSource数据函数
- (void)inputSourceForTest:(id)data
{
    //此处仅输出数据，做测试而已
    NSLog(@"%s %@" , __func__ , data);
    
}

@end
