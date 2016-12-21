//
//  ChatToolView.m
//  xmppframework
//
//  Created by 23 on 2016/12/19.
//  Copyright © 2016年 23. All rights reserved.
//

#import "ChatToolView.h"

@interface ChatToolView ()
@property (weak, nonatomic) IBOutlet UITextField *chatTextField;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;


@end

@implementation ChatToolView

- (IBAction)sendBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(chatToolView:didSendBtnClicked:text:)]) {
        [self.delegate chatToolView:self didSendBtnClicked:sender text:self.chatTextField.text];
    }
}

+ (instancetype)chatToolView
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

/**清空发送框*/
- (void)clearText
{
    self.chatTextField.text = @"";
}

@end
