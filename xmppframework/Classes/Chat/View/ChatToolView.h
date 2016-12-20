//
//  ChatToolView.h
//  xmppframework
//
//  Created by 23 on 2016/12/19.
//  Copyright © 2016年 23. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatToolView;


@protocol ChatToolViewDelegate <NSObject>

- (void)chatToolView:(ChatToolView *)toolView didSendBtnClicked:(UIButton *)button text:(NSString *)text;

@end

@interface ChatToolView : UIView

@property(nonatomic,weak) id<ChatToolViewDelegate> delegate;

+ (instancetype)chatToolView;
@end
