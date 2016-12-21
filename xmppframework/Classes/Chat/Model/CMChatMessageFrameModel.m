//
//  CMChatMessageFrameModel.m
//  xmppframework
//
//  Created by 23 on 2016/12/21.
//  Copyright © 2016年 23. All rights reserved.
//

#import "CMChatMessageFrameModel.h"
#import "CMChatMessage.h"

@implementation CMChatMessageFrameModel
{
    CGFloat _timeFontSize;
    CGFloat _messageFontSize;
    CGFloat _margin;
}

-(instancetype)init
{
    if (self = [super init]) {
        //初始化
        _timeFontSize = 12.0;
        _messageFontSize = 14.0;
        _margin = 10;

    }
    return self;
}

- (void)setMessage:(CMChatMessage *)message
{
    _message = message;
    
    CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
    
    CGSize size = [self.message.timeStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:_timeFontSize]}];
    CGFloat timeW = size.width + 5;
    CGFloat timeH = size.height + 3;
    CGFloat timeX = 0.5 * (cellW - timeW);
    CGFloat timeY = 0;
    self.timeLabelFrame = CGRectMake(timeX, timeY, timeW, timeH);
    
    CGFloat iconW = 44;
    CGFloat iconH = 44;
    CGFloat iconY = CGRectGetMaxY(self.timeLabelFrame) + 8;
    CGFloat iconX = _margin;
    if (self.message.fromToType == CMChatMessageFromToTypeMe) {
        iconX = cellW - _margin - iconW;
    }else{
        iconX = _margin;
    }
    self.iconViewFrame = CGRectMake(iconX, iconY, iconW, iconH);
    
    
    if (self.message.messageType == CMChatMessageTypeText) {
        //文本消息
        CGFloat maxW = cellW - 2 * (iconW + _margin + 10);
        CGRect rect = [self.message.body boundingRectWithSize:CGSizeMake(maxW, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:_messageFontSize]} context:nil];
        CGFloat messageW = rect.size.width + _margin * 2;
        CGFloat messageH = rect.size.height + _margin * 2;
        CGFloat messageY = iconY;
        CGFloat messageX = 0;
        if (self.message.fromToType == CMChatMessageFromToTypeMe) {
            messageX = cellW - iconW - 2 - _margin  - messageW;
        }else{
            messageX = CGRectGetMaxX(self.iconViewFrame) + 2 + _margin;
        }
        self.messageButtonFrame = CGRectMake(messageX, messageY, messageW, messageH);
        
        self.cellHeight = CGRectGetMaxY(self.messageButtonFrame) + 2 * _margin;
    }
}

@end
