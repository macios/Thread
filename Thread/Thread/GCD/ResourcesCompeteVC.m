//
//  ResourcesCompeteVC.m
//  Thread
//
//  Created by ac hu on 2018/6/19.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "ResourcesCompeteVC.h"

@interface ResourcesCompeteVC ()
@property(nonatomic,strong)NSDirectoryEnumerator *enumerator;
@property(nonatomic,copy)NSString *dir;
@end

@implementation ResourcesCompeteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatBtn];
    NSString *destination = @"/tmp";
    [[NSFileManager defaultManager] removeItemAtPath: destination error: NULL];
    [[NSFileManager defaultManager] createDirectoryAtPath: destination
                              withIntermediateDirectories: YES
                                               attributes: nil
                                                    error: NULL];
    
    _dir = [@"~/test" stringByExpandingTildeInPath];
    _enumerator = [[NSFileManager defaultManager] enumeratorAtPath:_dir];
    
    //第一种直接在globalQueue跑,会同时开很多线程，同时向磁盘资源发起访问，磁盘资源访问数大量增加，资源访问碰撞
    //电脑跑耗费时间19.0，真机可能会崩,虽然线程多，但是系统太卡，时间耗费了
    //    [self compete1];
    
    //单线程操作，不卡13.9
//        [self compete2];
    
    //分配资源
    [self compete3];
    
}

-(void)compete1{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    dispatch_group_t group = dispatch_group_create();
    NSTimeInterval ff = [[NSDate date] timeIntervalSince1970];
    for(NSString *path in _enumerator)
    {
        __weak typeof (self)weekSelf = self;
        dispatch_group_async(group, globalQueue, ^{
            NSString *fullPath = [weekSelf.dir stringByAppendingPathComponent:path];
            NSData *data = [NSData dataWithContentsOfFile: fullPath];
            if(data)
            {
                NSString *pathto = [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),path];
                BOOL is = [data writeToFile:pathto atomically:YES];
                NSLog(@"线程%@ 存储成功%d",[NSThread currentThread],is);
                NSLog(@"耗费时间:%.1f",([[NSDate date] timeIntervalSince1970] - ff));
            }
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

-(void)compete2{
    dispatch_queue_t ioQueue = dispatch_queue_create("com.mikeash.imagegcd.io", NULL);
    dispatch_group_t group = dispatch_group_create();
    NSTimeInterval ff = [[NSDate date] timeIntervalSince1970];
    for(NSString *path in _enumerator)
    {
        __weak typeof (self)weekSelf = self;
        dispatch_group_async(group, ioQueue, ^{
                NSString *fullPath = [weekSelf.dir stringByAppendingPathComponent:path];
                NSData *data = [NSData dataWithContentsOfFile: fullPath];
                if(data)
                {
                        NSString *pathto = [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),path];
                        BOOL is = [data writeToFile:pathto atomically:YES];
                        NSLog(@"线程%@ 存储成功%d",[NSThread currentThread],is);
                        NSLog(@"耗费时间:%.1f",([[NSDate date] timeIntervalSince1970] - ff));
                }
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

-(void)compete3{
    dispatch_queue_t ioQueue = dispatch_queue_create("com.mikeash.imagegcd.io", NULL);
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    NSInteger cpuCount = [[NSProcessInfo processInfo] processorCount];
    dispatch_semaphore_t jobSemaphore = dispatch_semaphore_create(cpuCount * 2.f);//但是这里获取的值是nil系统崩溃了
    dispatch_group_t group = dispatch_group_create();
    //    __block uint32_t count = -1;
    NSTimeInterval ff = [[NSDate date] timeIntervalSince1970];
    for(NSString *path in _enumerator)
    {
        __weak typeof (self)weekSelf = self;
        dispatch_semaphore_wait(jobSemaphore, DISPATCH_TIME_FOREVER);
        
        dispatch_group_async(group, ioQueue, ^{
//            dispatch_group_async(group, globalQueue, ^{
                NSString *fullPath = [weekSelf.dir stringByAppendingPathComponent:path];
                NSData *data = [NSData dataWithContentsOfFile: fullPath];
                if(data)
                {
//                    dispatch_group_async(group, ioQueue, ^{
                        NSString *pathto = [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),path];
                        BOOL is = [data writeToFile:pathto atomically:YES];
                        NSLog(@"线程%@ 存储成功%d",[NSThread currentThread],is);
                        NSLog(@"耗费时间:%.1f",([[NSDate date] timeIntervalSince1970] - ff));
                        dispatch_semaphore_signal(jobSemaphore);
//                    });
                    
                }
//            });
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (void)creatBtn {
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

