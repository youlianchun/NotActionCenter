//
//  SendViewController.m
//  NotActionCenter
//
//  Created by YLCHUN on 2017/3/29.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "SendViewController.h"
#import "NotActionCenter.h"

@interface SendViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segYN;

@end

@implementation SendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)send:(id)sender {
    NSString *name = @"";
    NSString*param = self.textView.text;
    NSString *key = self.textField.text;
    BOOL YN = self.segYN.selectedSegmentIndex==0?YES:NO;
    Class cls = nil;
    if (self.segment.selectedSegmentIndex == 0) {
        cls = NSClassFromString(@"ViewController");
    }
    if (self.segment.selectedSegmentIndex == 1) {
        cls = NSClassFromString(@"ViewController2");
    }
    [[NotActionCenter defaultCenter] pushNotActionAtOnce:YN toClass:cls key:key actionName:name object:param];
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
