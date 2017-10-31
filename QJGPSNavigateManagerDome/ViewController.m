//
//  ViewController.m
//  QJGPSNavigateManagerDome
//
//  Created by qujie on 2017/10/31.
//  Copyright © 2017年 linkin. All rights reserved.
//

#import "ViewController.h"
#import "QJGPSNavigateManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton * but = [[UIButton alloc] init];
    [but setTitle:@"从我的位置到北京天安门" forState:UIControlStateNormal];
    [but setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(goBeiJing) forControlEvents:UIControlEventTouchUpInside];
    but.clipsToBounds = YES;
    but.layer.cornerRadius = 5 ;
    but.frame = CGRectMake(30, 0, self.view.frame.size.width - 60, 50);
    but.center = self.view.center ;
    [self.view addSubview:but];
}

-(void)goBeiJing
{
    [[QJGPSNavigateManager manager] startGPSNavigateWithDestinationName:@"北京天安门" failure:^(QJGPSErrorType gpsErrorType, NSString *errorMessage) {
        NSLog(@"error = %@",errorMessage);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
