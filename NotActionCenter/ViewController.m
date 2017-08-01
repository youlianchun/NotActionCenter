//
//  ViewController.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/28.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import "NotActionCenter.h"

@interface ViewController ()<NotActionNodeProtocol>
@property (weak, nonatomic) IBOutlet UILabel *lab;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Title%lu",self.navigationController.viewControllers.count];
    [self mountNotActionWithKey:self.title];
    [self mountTriggerWithSelector:@selector(viewWillAppear:)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)notActionWithName:(NSString*)actionName object:(id)object {
    self.lab.text = object;
    NSLog(@"notActionWithName_ViewController1");
}

@end
