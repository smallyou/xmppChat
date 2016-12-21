//
//  CMChatMessageCell.m
//  xmppframework
//
//  Created by 23 on 2016/12/21.
//  Copyright © 2016年 23. All rights reserved.
//

#import "CMChatMessageCell.h"
#import "CMChatMessage.h"
#import "CMChatMessageFrameModel.h"

@interface CMChatMessageCell()

/**头像*/
@property(nonatomic,weak) UIImageView *iconImageView;
/**时间*/
@property(nonatomic,weak) UILabel *timeLabel;
/**消息内容*/
@property(nonatomic,weak) UIButton *messageButton;

/**模型frame*/
@property(nonatomic,weak) CMChatMessageFrameModel  *frameModel;

@end

@implementation CMChatMessageCell
{
    CGFloat _timeFontSize;
    CGFloat _messageFontSize;
    CGFloat _margin;
}

- (CMChatMessageFrameModel *)frameModel
{
    if (_frameModel == nil) {
        _frameModel = [[CMChatMessageFrameModel alloc]init];
    }
    return _frameModel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //初始化
        _timeFontSize = 12.0;
        _messageFontSize = 14.0;
        _margin = 10;
        
        //控件初始化
        UIImageView *iconImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:iconImageView];
        self.iconImageView = iconImageView;
        
        UILabel *timeLabel = [[UILabel alloc]init];
        timeLabel.font = [UIFont systemFontOfSize:_timeFontSize];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        messageButton.titleLabel.font = [UIFont systemFontOfSize:_messageFontSize];
        messageButton.titleLabel.numberOfLines = 0; //自动换行
        [messageButton setTitleEdgeInsets:UIEdgeInsetsMake(_margin, _margin, _margin, _margin)];
        [self.contentView addSubview:messageButton];
        self.messageButton = messageButton;
        
        
        
    }
    return self;
}


- (void)setMessage:(CMChatMessage *)message
{
    _message = message;
    
    self.frameModel.message = message;
    
    [self.messageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.iconImageView.image = [UIImage imageNamed:@"head_portrait_default_avatar_big"];
    self.timeLabel.text = message.time;
    
    //赋值操作
    if (message.messageType == CMChatMessageTypeText) {
        //文本消息
        [self.messageButton setTitle:message.body forState:UIControlStateNormal];
        if (message.fromToType == CMChatMessageFromToTypeYours) {
            [self.messageButton setBackgroundImage:[UIImage imageNamed:@"ic_left_chat_content_bg"] forState:UIControlStateNormal];
        }else{
            [self.messageButton setBackgroundImage:[UIImage imageNamed:@"ic_right_chat_content_bg"] forState:UIControlStateNormal];
        }
        
    }else if(message.messageType == CMChatMessageTypeImage){
        //图片消息
        
    }
    else if(message.messageType == CMChatMessageTypeVoice){
        //语音消息
        
    }else if(message.messageType == CMChatMessageTypeVideo){
        //视频消息
        
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CMChatMessageFrameModel *framModel = [[CMChatMessageFrameModel alloc]init];
    framModel.message = self.message;
    
    self.timeLabel.frame = framModel.timeLabelFrame;
    self.iconImageView.frame = framModel.iconViewFrame;
    self.messageButton.frame = framModel.messageButtonFrame;
}


@end
