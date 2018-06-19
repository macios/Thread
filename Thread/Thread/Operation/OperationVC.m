//
//  OperationVC.m
//  Thread
//
//  Created by ac hu on 2018/6/19.
//  Copyright © 2018年 ac hu. All rights reserved.
//

#import "OperationVC.h"

@interface OperationVC ()

@end

@implementation OperationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatBtn];
    
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

@end
