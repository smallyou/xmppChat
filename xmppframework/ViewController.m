//
//  ViewController.m
//  xmppframework
//
//  Created by 23 on 2016/12/6.
//  Copyright © 2016年 23. All rights reserved.
//

#import "ViewController.h"
#import "XMPPFramework.h"

#import "CMXMPPManager.h"


#import "ContactViewController.h"

@interface ViewController () <XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


@end

@implementation ViewController

#pragma mark - 懒加载


- (IBAction)login {
 
   //连接服务器
    [[CMXMPPManager shareManager] connectToXMPPServerWithUsername:self.usernameTextField.text password:self.passwordTextField.text handler:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"连接服务器成功");
            ContactViewController *contact = [[ContactViewController alloc]init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:contact];
            [self presentViewController:nav animated:YES completion:nil];
        }else{
            NSLog(@"连接服务器失败 ---- %@",error);
        }
    }];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}




@end
