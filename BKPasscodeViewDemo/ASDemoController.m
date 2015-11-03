//
//  ASDemoController.m
//  BKPasscodeViewDemo
//
//  Created by liufei on 15/10/30.
//  Copyright © 2015年 Byungkook Jang. All rights reserved.
//

#import "ASDemoController.h"
#import "ASPasscodeManager.h"

@interface ASDemoController ()

@property (nonatomic) IBOutlet UISwitch * passcodeSwitch;
@property (nonatomic) IBOutlet UIButton * deleteBtn;
@property (nonatomic) IBOutlet UIButton * updateBtn;

-(IBAction)switchChanged:(id)sender;
-(IBAction)deletePasscode:(id)sender;
-(IBAction)updatePasscode:(id)sender;
@end

@implementation ASDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.passcodeSwitch setOn:[[ASPasscodeManager manager] hasPasscode] animated:NO];
    // Do any additional setup after loading the view from its nib.
    
     self.deleteBtn.enabled = self.passcodeSwitch.on;
    self.updateBtn.enabled = self.passcodeSwitch.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)switchChanged:(id)sender{
    ASPasscodeManager * manager = [ASPasscodeManager manager];

    if (self.passcodeSwitch.on) {
        [manager inputPasscode:self complete:^(BOOL ret) {
            [self.passcodeSwitch setOn:ret animated:YES];
            self.deleteBtn.enabled = self.passcodeSwitch.on;
            self.updateBtn.enabled = self.passcodeSwitch.on;
        }];
    }else{
        [manager checkPasscode:self complete:^(BOOL ret) {
             [self.passcodeSwitch setOn:!ret animated:YES];
            self.deleteBtn.enabled = self.passcodeSwitch.on;
            self.updateBtn.enabled = self.passcodeSwitch.on;
        }];
    };
    
}

-(IBAction)deletePasscode:(id)sender{
    ASPasscodeManager * manager = [ASPasscodeManager manager];
    [manager deletePasscode:self complete:^(BOOL ret) {
        if (ret) {
            [self.passcodeSwitch setOn:!ret animated:YES];
            self.deleteBtn.enabled = self.passcodeSwitch.on;
            self.updateBtn.enabled = self.passcodeSwitch.on;
        }
    }];
}

-(IBAction)updatePasscode:(id)sender{
    ASPasscodeManager * manager = [ASPasscodeManager manager];
    [manager updatePasscode:self complete:^(BOOL ret) {
        NSLog(@"Update %@", ret?@"SUCC" : @"FAILED");
    }];
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
