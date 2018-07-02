//
//  GCDAPIVC.m
//  Thread
//
//  Created by ac-hu on 2018/6/30.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "GCDAPIVC.h"

@interface GCDAPIVC ()

@end

@implementation GCDAPIVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //    Apply-for模拟循环
        [self testApply];
    
    //    group队列管理组
    //    [self group];
    //    [self groupEnterLeave];
    
    //    barrier栅栏
//        [self barrier];
    
    //    timer时间控制
    //    [self afterTime];
    
    //信号量-最高效率的线程锁
//    [self semaphore];
    
    //@property(nonatomic,atomic)
//    @synchronized
    //nonatomic 非原子性操作，线程不安全的
    //atomic 原子性操作，线程安全的，耗性能的。只能保证单个线程set、get的操作，而且耗性能,他不能保证多线程操作完整性，在遇到多个set的时候，最终得到的可能是其中任何一个值
//    线程不安全时都得加锁
//    [self nonatomic];
    [self atomic];
}


/**
 apply有for循环的功能，但是apply会等前面的异步任务完成，但是如果嵌套异步则不会等待完成,即使内部加栅栏也没有效果
 */
-(void)testApply{
    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    //    for (int i = 0; i < 10; i ++) {
    //        dispatch_async(queue, ^{
    //            NSLog(@"%d %@",i,[NSThread currentThread]);
    //        });
    //    }
    //    NSLog(@"完成");
    
    dispatch_apply(10, queue, ^(size_t index) {
        dispatch_async(queue, ^{
            NSLog(@"%zu %@",index,[NSThread currentThread]);
            //            dispatch_async(dispatch_get_global_queue(0,0), ^{
            //                NSLog(@"%zd %@",i,[NSThread currentThread]);
            //            });//如果嵌套异步则完成会提前执行

        });
//        if (index == 5) {
//            dispatch_barrier_async(queue, ^{
//                NSLog(@"barrier %@",[NSThread currentThread]);
//            });
//        }else{
//            dispatch_async(queue, ^{
//                NSLog(@"%zd %@",index,[NSThread currentThread]);
//            });
//        }
    });
    NSLog(@"完成");
}


/**
 不嵌套则会等里面任务执行，嵌套“完成”会提前执行
 */
- (void)group {
    dispatch_group_t group = dispatch_group_create();
    for (int i = 0; i < 10; i ++) {
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
            //                dispatch_async(dispatch_get_global_queue(0,0), ^{
            //                    sleep(1);
            //                    NSLog(@"%d %@",i,[NSThread currentThread]);
            //                });
            
            sleep(1);
            NSLog(@"%d %@",i,[NSThread currentThread]);
        });
    }
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"完成");
    });
}

/**
 嵌套等待任务执行完成的方法enterLeave（加入与离开）enter 与 leave需要一一对应，如果加入次数多余离开次数则notify永远不会执行，如果加入次数小于离开次数则会崩溃
 */
- (void)groupEnterLeave {
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < 10; i ++) {
        dispatch_group_enter(group);
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                sleep(1);
                NSLog(@"%d %@",i,[NSThread currentThread]);
                dispatch_group_leave(group);
            });
        });
    }
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"完成");
    });
}


/**
 栅栏：不能用全局队列,用DISPATCH_QUEUE_CONCURRENT，将两者分开，分开的两者顺序不可控.如果放在最后也可以做到监听所有任务执行完成
 */
-(void)barrier{
    dispatch_queue_t queue = dispatch_queue_create("com.aaa", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10; i ++) {
        if (i == 5) {
            dispatch_barrier_async(queue, ^{
                NSLog(@"barrier %@",[NSThread currentThread]);
            });
        }else{
            dispatch_async(queue, ^{
                NSLog(@"%d %@",i,[NSThread currentThread]);
            });
        }
    }
}

-(void)afterTime{
    //延时操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"延时操作");
    });
}

//信号量，控制同时执行任务的并发数量
-(void)semaphore{
    dispatch_semaphore_t semmaphore = dispatch_semaphore_create(2);
    dispatch_apply(10, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semmaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"%zd %@",index,[NSThread currentThread]);
        dispatch_semaphore_signal(semmaphore);
    });
    
}



/**
 -(void)setName:(NSString *)name{
 if (name != _name) {
 [_name release];
 [name retain];
 _name = name;
 }
 }
这样的操作会崩溃，因为有的线程刚刚执行release了，另一个线程又来执行，相当于一个空对象release，所以崩溃
 */
-(void)nonatomic{
    dispatch_queue_t queue = dispatch_queue_create("com.ccc", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10000000; i ++) {
        dispatch_async(queue, ^{
            self.name = [NSString stringWithFormat:@"hhhhh-%d",i];
        });
    }
}


/**
 也会蹦，但是值会不对，他只管最后一次赋值，过程不管
 */
-(void)atomic{
    dispatch_apply(10000, dispatch_queue_create("com.bbbb", DISPATCH_QUEUE_CONCURRENT), ^(size_t index) {
        self.number++;
    });
    NSLog(@"%d",self.number);
}

@end

