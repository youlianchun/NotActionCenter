//
//  ViewController2.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/29.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController2.h"
#import "NotActionCenter.h"

@interface ViewController2 ()<NotActionNodeProtocol>
@property (weak, nonatomic) IBOutlet UILabel *lab;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Title%ld",self.navigationController.viewControllers.count];
    [self mountNotActionWithKey:self.title];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)notActionWithName:(NSString*)actionName object:(id)object {
    self.lab.text = object;
    NSLog(@"notActionWithName_ViewController2");
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self manualTriggerNotAction];
}
@end
