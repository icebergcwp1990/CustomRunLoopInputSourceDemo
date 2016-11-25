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
      
        self.inputSource = [[IBRunLoopInputSource alloc] init];
        [self.inputSource setDelegate:self];
        [self.inputSource addToCurrentRunLoop];
        
        [self configureRunLoopObserver];
        
        while (!self.cancelled) {
            
//            NSLog(@"Enter Run Loop...");
            
            [self finishOtherTask];
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
//            NSLog(@"Exit Run Loop...");
            
        }
        
    }
}

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

- (void)finishOtherTask
{
    NSLog(@"OtherTask: 🐴🐴🐴🐴🐴🐴🐴🐴🐴🐴");

}

#pragma mark - IBRunLoopInputSourceTestDelegate

- (void)inputSourceForTest:(id)data
{
    NSLog(@"%s %@" , __func__ , data);
    
}

@end
