//
//  ViewController.m
//  太阳系1
//
//  Created by 姚立飞 on 2017/10/12.
//  Copyright © 2017年 姚立飞. All rights reserved.
//

#import "ViewController.h"
#import "SCenViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)clickBtn:(id)sender {
    SCenViewController *vc = [[SCenViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}




@end
