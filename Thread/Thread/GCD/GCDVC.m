//
//  GCDVC.m
//  Thread
//
//  Created by ac hu on 2018/6/19.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "GCDVC.h"
#import "ResourcesCompeteVC.h"

@interface GCDVC ()

@end

@implementation GCDVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatBtn];
    
    //延时操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"延时操作");
    });
    
    //全局队列
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"回到主线程刷新UI");
        });
    });
    //    dispatch_async ,异步添加进任务队列，它不会做任何等待
    //    dispatch_sync(),同步添加操作。他是等待添加进队列里面的操作完成之后再继续执行。
    
    //Serial串行，Concurrent并行
    //1.主队列：串行
//    dispatch_queue_t mainDispatchQueue = dispatch_get_main_queue();
    //2.全局队列：并行
    //执行优先级:
    // DISPATCH_QUEUE_PRIORITY_HIGH 2               高
    // DISPATCH_QUEUE_PRIORITY_DEFAULT 0            默认
    // DISPATCH_QUEUE_PRIORITY_LOW (-2)             低
    // DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN 后台
    dispatch_queue_t globalDispatchQueueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    //3.用户队列：可串行可并行
    dispatch_queue_t myCreatQueue = dispatch_queue_create("com.http.myQueue", NULL);
    //异步执行一个队列
    dispatch_async(myCreatQueue, ^{});
    //异步将一个队列放到任务组里面去执行
    dispatch_group_async(dispatch_group_create(), globalDispatchQueueHigh, ^{});
    
    //开启一个串行队列
    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("com.river.myserialdispatchqueue", NULL);
    //开启一个全局后台队列
    dispatch_queue_t globalDispatchQueueBackGround = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    //这个串行队列是在后台执行的,设置队列
    dispatch_set_target_queue(mySerialDispatchQueue, globalDispatchQueueBackGround);
    
    //    dispatch_async 函数会立即返回, block会在后台异步执行。
    //    dispatch_sync，它会等待block中的代码执行完成并返回，用处：你可能有一段代码在后台执行，而它需要从界面控制层获取一个值
    //    __block NSString *stringValue;
    //    dispatch_sync(dispatch_get_main_queue(), ^{
    ////        stringValue = textField.text;
    //    });
    
    
    //异步执行并回调-有序 →做完以后做其他功能
//    [self asyncA];
    //同步执行并回调-无序 →做完以后做其他功能
//    [self syncB];
    //异步执行并回调-无序 →做完以后做其他功能
//    [self asyncC];
    //异步同步依次执行
    [self syncD];
    
    //取消正在执行的线程
//    dispatch_suspend(globalDispatchQueueHigh);
//    globalDispatchQueueHigh = nil;
    
    //dispatch_set_target_queue详解
//    dispatch_set_target_queue(<#dispatch_object_t  _Nonnull object#>, <#dispatch_queue_t  _Nullable queue#>)
    
    //计时器
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
//    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
//    dispatch_source_set_event_handler(timer, ^{
//        NSLog(@"%@",timer);
//    });
//    dispatch_resume(timer);
    
    //dispatch_source_t详解
//    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
//    dispatch_source_set_event_handler(source, ^{
//        NSLog(@"%@",source);
//    });
//    dispatch_resume(source);
//    NSArray *arr = @[@"1",@"2",@"3",@"4",@"5"];
//    dispatch_apply([arr count], dispatch_get_global_queue(0, 0), ^(size_t index) {
//        // do some work on data at index
//        dispatch_source_merge_data(source, 1);
//    });
}

-(void)syncD{
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 10; i++) {
            NSLog(@"异步同步blockA：%d",i);
        }
    });
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 10; i++) {
            NSLog(@"异步同步blockB：%d",i);
        }
    });
}

-(void)asyncC{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    NSArray *arrB = @[@"1",@"2",@"3",@"4",@"5"];
    dispatch_async(queue,^{
        dispatch_apply([arrB count],queue, ^(size_t index){
            [NSThread sleepForTimeInterval:1];
            NSLog(@"异步C功能%zu",index);
        });
        NSLog(@"异步C功能已完成");
    });
}

-(void)syncB{
    dispatch_queue_t queueB = dispatch_get_global_queue(0, 0);
    NSArray *arrB = @[@"1",@"2",@"3",@"4",@"5"];
    dispatch_apply([arrB count],queueB, ^(size_t index){
        [NSThread sleepForTimeInterval:1];
        NSLog(@"B功能%zu",index);
    });
    NSLog(@"B功能已完成");
}

-(void)asyncA{
    dispatch_queue_t queueA = dispatch_get_global_queue(0, 0);
    dispatch_group_t groupA = dispatch_group_create();
    dispatch_group_async(groupA, queueA, ^{
        for (int i = 0; i < 10; i ++) {
            [NSThread sleepForTimeInterval:1];
            NSLog(@"异步A功能%d",i);
        }
    });
    dispatch_group_notify(groupA,queueA, ^{
        NSLog(@"异步A功能已经做完了");
    });
}

-(void)creatBtn{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 40, 100, 50);
    [btn setTitle:@"back" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(toBackClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(20, 100, 100, 200);
    [btn1 setTitle:@"ResourcesCompeteVC" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(toResourcesCompeteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}

-(void)toResourcesCompeteClick{
    [self presentViewController:[ResourcesCompeteVC new] animated:YES completion:nil];
}

-(void)toBackClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

