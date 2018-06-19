//
//  GCDVC.m
//  Thread
//
//  Created by ac hu on 2018/6/19.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "GCDVC.h"

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
    
    //Serial串行，Concurrent并行
    //1.主队列：串行
    dispatch_queue_t mainDispatchQueue = dispatch_get_main_queue();
    //2.全局队列：并行
    //执行优先级:
    // DISPATCH_QUEUE_PRIORITY_HIGH 2               高
    // DISPATCH_QUEUE_PRIORITY_DEFAULT 0            默认
    // DISPATCH_QUEUE_PRIORITY_LOW (-2)             低
    // DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN 后台
    dispatch_queue_t globalDispatchQueueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    //3.用户队列：可串行可并行
    dispatch_queue_t myCreatQueue = dispatch_queue_create("com.http.myQueue", NULL);
    //指定dispatch_queue队列去执行
    dispatch_async(myCreatQueue, ^{
        
    });
    
    //开启一个串行队列
    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("com.river.myserialdispatchqueue", NULL);
    //开启一个全局后台队列
    dispatch_queue_t globalDispatchQueueBackGround = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    //这个串行队列是在后台执行的
    dispatch_set_target_queue(mySerialDispatchQueue, globalDispatchQueueBackGround);
    
//    dispatch_async 函数会立即返回, block会在后台异步执行。
//    dispatch_sync，它会等待block中的代码执行完成并返回，用处：你可能有一段代码在后台执行，而它需要从界面控制层获取一个值
    __block NSString *stringValue;
    dispatch_sync(dispatch_get_main_queue(), ^{
//        stringValue = textField.text;
    });
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

