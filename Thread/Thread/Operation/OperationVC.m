//
//  OperationVC.m
//  Thread
//
//  Created by ac hu on 2018/6/19.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "OperationVC.h"

@interface OperationVC ()
@property(nonatomic,assign)NSInteger ticketSurplusCount;
@property(nonatomic,strong)NSLock *lock;
@end

@implementation OperationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatBtn];
    
    //（一）.简单调用.若需要监听其完成需要建立KVO
    // 1.子类创建 NSInvocationOperation 对象，在当前线程执行
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    [op start];
    
    //2.非当前线程调用
    // 在其他线程使用子类 NSInvocationOperation
    [NSThread detachNewThreadSelector:@selector(task2) toTarget:self withObject:nil];
    
    // 3.创建 NSBlockOperation
    //NSBlockOperation如果只有一个块的话在当前线程，多个的话会开新线程
    [self BlockOperation];
    
    //4.将操作加入到队列
//    // 主队列获取方法
//    NSOperationQueue *queueMain = [NSOperationQueue mainQueue];
//    // 自定义队列创建方法
//    NSOperationQueue *queueNew = [[NSOperationQueue alloc] init];
//    4.1:先创建操作再加入队列
    [self addOperation];
    //4.2直接加入队列
    [self addOperationWithBlockToQueue];
    
    //5.串行、并行
    [self setMaxConcurrentOperationCount];
    
    //6.依赖
    //- (void)addDependency:(NSOperation *)op; 添加依赖
    //- (void)removeDependency:(NSOperation *)op; 移除依赖
    //@property (readonly, copy) NSArray<NSOperation *> *dependencies; 在当前操作开始执行之前完成执行的所有操作对象数组。
    //A 执行完操作，B 才能执行操作,那么操作 B 依赖于操作 A
    [self addDependency];
    
//    7.线程同步和线程安全
    [self initTicketStatusNotSave];
    
    [self other];
}

- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]); // 打印当前线程
    
    self.ticketSurplusCount = 50;
    self.lock = [[NSLock alloc] init];
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    // 3.创建卖票操作 op1
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf saleTicketNotSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketNotSafe {
    while (1) {
        // 加锁
        [self.lock lock];
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%d 窗口:%@", (int)self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else {
            // 解锁
            [self.lock unlock];
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

-(void)addDependency{
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
//    NSOperation 优先级
//    NSOperationQueuePriorityVeryLow = -8L,
//    NSOperationQueuePriorityLow = -4L,
//    NSOperationQueuePriorityNormal = 0,
//    NSOperationQueuePriorityHigh = 4,
//    NSOperationQueuePriorityVeryHigh = 8
    //    op1.queuePriority = NSOperationQueuePriorityNormal;//准备就绪的操作，按优先级高的执行
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.添加依赖
    [op2 addDependency:op1]; // 让op2 依赖于 op1，则先执行op1，在执行op2
    
    // 4.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
}

-(void)addOperationWithBlockToQueue{
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.使用 addOperationWithBlock: 添加操作到队列中
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"直接1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"直接2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"直接3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

- (void)setMaxConcurrentOperationCount {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.设置最大并发操作数-并非最大线程数，一个操作可能有多个线程
//    queue.maxConcurrentOperationCount = 1; // 串行队列
     queue.maxConcurrentOperationCount = 2; // 并发队列
    // queue.maxConcurrentOperationCount = 8; // 并发队列
    
    // 3.添加操作
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"MaxCon1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"MaxCon2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"MaxCon3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"MaxCon4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}

-(void)addOperation{
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    // 使用 NSInvocationOperation 创建操作1
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    
    // 使用 NSInvocationOperation 创建操作2
    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task2) object:nil];
    
    // 使用 NSBlockOperation 创建操作3
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"op3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op3 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:.2]; // 模拟耗时操作
            NSLog(@"op4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.使用 addOperation: 添加所有操作到队列中
    [queue addOperation:op1]; // [op1 start]
    [queue addOperation:op2]; // [op2 start]
    [queue addOperation:op3]; // [op3 start]
}

-(void)BlockOperation{
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:1]; // 模拟耗时操作
            NSLog(@"BlockB线程%@-%d", [NSThread currentThread],i); // 打印当前线程
        }
    }];
    [op1 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:1]; // 模拟耗时操作
            NSLog(@"BlockA线程%@-%d", [NSThread currentThread],i); // 打印当前线程
        }
    }];
    [op1 start];
}

- (void)task1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:0.5]; // 模拟耗时操作
        NSLog(@"Invocation线程%@", [NSThread currentThread]); // 打印当前线程
    }
}

- (void)task2 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:0.5]; // 模拟耗时操作
        NSLog(@"NewThread线程%@", [NSThread currentThread]); // 打印当前线程
    }
}

-(void)creatBtn{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 40, 100, 50);
    [btn setTitle:@"back" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(toBackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)toBackClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)other{
//    操作NSOperation常用方法
//    - (void)cancel;可取消操作，实质是标记 isCancelled 状态。
//    判断操作状态方法
//    - (BOOL)isFinished;判断操作是否已经结束。
//    - (BOOL)isCancelled;判断操作是否已经标记为取消。
//    - (BOOL)isExecuting;判断操作是否正在在运行。
//    - (BOOL)isReady;判断操作是否处于准备就绪状态，这个值和操作的依赖关系相关。
//
//    操作同步
//    - (void)waitUntilFinished;阻塞当前线程，直到该操作结束。可用于线程执行顺序的同步。
//    - (void)setCompletionBlock:(void (^)(void))block;completionBlock会在当前操作执行完毕时执行 completionBlock。
//    - (void)addDependency:(NSOperation *)op;添加依赖，使当前操作依赖于操作 op 的完成。
//    - (void)removeDependency:(NSOperation *)op;移除依赖，取消当前操作对操作 op 的依赖。
//    @property (readonly, copy) NSArray *dependencies;在当前操作开始执行之前完成执行的所有操作对象数组。
    
    
//    队列NSOperationQueue 常用属性和方法
//    取消/暂停/恢复操作
//    - (void)cancelAllOperations;可以取消队列的所有操作。
//    - (BOOL)isSuspended;判断队列是否处于暂停状态。 YES 为暂停状态，NO 为恢复状态。
//    - (void)setSuspended:(BOOL)b;可设置操作的暂停和恢复，YES 代表暂停队列，NO 代表恢复队列。
//    操作同步
//    - (void)waitUntilAllOperationsAreFinished;阻塞当前线程，直到队列中的操作全部执行完毕。
//    添加/获取操作`
//    - (void)addOperationWithBlock:(void (^)(void))block;向队列中添加一个 NSBlockOperation 类型操作对象。
//    - (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait;向队列中添加操作数组，wait 标志是否阻塞当前线程直到所有操作结束
//    - (NSArray *)operations;当前在队列中的操作数组（某个操作执行结束后会自动从这个数组清除）。
//    - (NSUInteger)operationCount;当前队列中的操作数。
//    获取队列
//    + (id)currentQueue;获取当前队列，如果当前线程不是在 NSOperationQueue 上运行则返回 nil。    
//    + (id)mainQueue;获取主队列。
}
@end
