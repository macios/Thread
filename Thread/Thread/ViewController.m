//
//  ViewController.m
//  Thread
//
//  Created by ac hu on 2018/6/18.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "ViewController.h"
#import "GCDVC.h"
#import "OperationVC.h"

@interface ViewController ()
@property (nonatomic, strong) NSThread *threadA;
@property (nonatomic, strong) NSThread *threadB;
@property (nonatomic, assign) NSInteger ticketsCount;
@property (nonatomic, strong) NSLock *lock;// 线程锁

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    线程和进程
    //
    //    进程就是一个独立的应用程序，是cpu调度的独立单元，享有独立的系统资源（内存）
    //    线程是进程中的执行单元，是cpu调用的最小单位，一个进程可以有多个线程但至少有一个，它们中有一个为主线程，其他为分线程
    //
    //    多线程编程
    //
    //    在我们编写程序时，有的任务会花取大量时间进行处理，所以我们为了防止这些任务阻塞到我们的主线程，造成UI卡顿，会用到多线程编程。
    //    多个线程可以同时执行的，提高完成任务效率。
    [self nsThread];
    
    [self creatBtn];
}

-(void)creatBtn{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 40, 100, 50);
    [btn setTitle:@"GCD" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(toGCDClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btna = [UIButton buttonWithType:UIButtonTypeSystem];
    btna.frame = CGRectMake(20, 100, 100, 50);
    [btna setTitle:@"Operation" forState:UIControlStateNormal];
    [btna addTarget:self action:@selector(toOperationClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btna];
}

-(void)toGCDClick{
    [self presentViewController:[GCDVC new] animated:YES completion:nil];
}

-(void)toOperationClick{
    [self presentViewController:[OperationVC new] animated:YES completion:nil];
}

-(void)nsThread{
    
    //    //参数：1.分线程执行的函数 2.分线程方法的执行者 3.参数
    //    [NSThread detachNewThreadSelector:@selector(threadMethod1) toTarget:self withObject:nil];
    //
    //    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMethod2) object:nil];
    //    thread.name = @"分线程";
    //    // 启动线程
    //    [thread start];
    //
    //    //后台开辟线程
    //    // 在performSelector系列方法中 只有此方法可以开辟分线程
    //    [self performSelectorInBackground:@selector(threadMethod3) withObject:nil];
    
    //    // 此方法指定的testMehtod是在主线程中执行的
    //    [self performSelector:@selector(testMehtod)];
    //    // 退出线程 一般不使用
    //    [NSThread exit];
    //    //获取当前线程
    //    [NSThread currentThread];
    //    //判断是否是主线程
    //    [NSThread isMainThread];
    //    //获取主线程
    //    [NSThread mainThread]
    //    // 让当前线程休眠10s
    //    [NSThread sleepForTimeInterval:10];
    ////    注意：在分线程中不能操作UI，需要回到主线程中操作UI
    //    // 参数：1.回到主线程执行的方法 2.参数 3.是否要锁住当前线程等待主线程方法执行完毕
    //    [self performSelectorOnMainThread:@selector(mainThreadMethod) withObject:nil waitUntilDone:
    
    //使用线程锁达到同步
    // 创建线程锁
    self.lock = [NSLock new];
    self.ticketsCount = 10;
    //创建两个线程去买票
    self.threadA = [[NSThread alloc] initWithTarget:self selector:@selector(sellTickets) object:nil];
    self.threadA.name = @"售票员A";

    self.threadB = [[NSThread alloc] initWithTarget:self selector:@selector(sellTickets) object:nil];
    self.threadB.name = @"售票员B";
    

}

// 点一下 模拟同时开始卖票
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.threadA start];
    [self.threadB start];
}

#pragma mark - lock形式
//NSLock实现：在多任务时，多个线程同时访问一个对象，会锁住这个代码块，只有等到当前线程任务执行完毕，其他线程才能接着执行
- (void)sellTickets
{
    //while模拟售票员一直在在卖票
    while (YES){
        // 加锁和解锁一定要成对出现
        // 加锁
        //意思就是阻塞同时访问这块资源的其他线程，只有当当前线程访问完毕，下一个线程才能够接着访问，实现线程的同步，按顺序执行。
        [_lock lock];
        // 1.获取票数
        NSInteger count = self.ticketsCount;
        // 2.检查票数
        if (count > 0)
        {
            // 3.暂停一会分线程  0.002 （保证两个都获取到了总票数 模拟理论上的情况）
            [NSThread sleepForTimeInterval:2];
            // 4.票数等于检查票数减一
            self.ticketsCount = count - 1;
            // 解锁
            [_lock unlock];
        }
        else
        {
            //没票
            [NSThread exit];
        }
        NSLog(@"当前线程%@ 剩余%d",[NSThread currentThread],(int)self.ticketsCount);
    }
    
//    while (YES) {
//        // self表示一把锁 多个资源共用一把锁
//        // 括号内
//        @synchronized (self) {
//            // 1.获取票数
//            NSInteger count = self.ticketsCount;
//            // 2.检查票数
//            if (count > 0)
//            {
//                // 3.暂停一会分线程  0.002 （保证两个都获取到了总票数 模拟理论上的情况）
//                [NSThread sleepForTimeInterval:0.002];
//                // 4.票数等于检查票数减一
//                self.ticketsCount = count - 1;
//                // 打印当前线程、以及剩余票数
//                NSLog(@"%@_____%ld", [NSThread currentThread], self.ticketsCount);
//            }
//            else
//            {
//                //没票
//                [NSThread exit];
//            }
//        }
//    }
}



@end

