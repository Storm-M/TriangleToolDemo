//
//  ViewController.m
//  TriangleToolDemo
//
//  Created by jianglihui on 2017/6/28.
//  Copyright © 2017年 ND. All rights reserved.
//

#import "ViewController.h"
#import "ToolTriangleToolView.h"
#import "UIViewExt.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat angle = 45; //30度
    int width = 500;    //分辨率500宽。iPad的分辨率1024*768
    ToolTriangleToolView *triangleView = [[ToolTriangleToolView alloc] initWithFrame:CGRectMake((self.view.width-width)/2, (self.view.height-width)/2, width, width*tan(angle/180.0*M_PI))];
    triangleView.angle = angle;
    triangleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:triangleView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
