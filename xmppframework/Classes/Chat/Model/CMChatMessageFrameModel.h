//
//  CMChatMessageFrameModel.h
//  xmppframework
//
//  Created by 23 on 2016/12/21.
//  Copyright © 2016年 23. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CMChatMessage;
@interface CMChatMessageFrameModel : NSObject

@property(nonatomic,assign) CGRect timeLabelFrame;

@property(nonatomic,assign) CGRect iconViewFrame;

@property(nonatomic,assign) CGRect messageButtonFrame;

@property(nonatomic,assign) CGFloat cellHeight;


@property(nonatomic,strong) CMChatMessage *message;

@end
