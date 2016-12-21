//
//  ChatViewController.m
//  xmppframework
//
//  Created by 23 on 2016/12/19.
//  Copyright © 2016年 23. All rights reserved.
//

#import "ChatViewController.h"
#import "CMXMPPBuddy.h"
#import "ChatToolView.h"
#import "CMChatMessage.h"
#import "CMChatMessageCell.h"
#import "CMChatMessageFrameModel.h"

@interface ChatViewController () <UITableViewDelegate,UITableViewDataSource,ChatToolViewDelegate>
@property(nonatomic,weak) UITableView *tableView;
@property(nonatomic,weak) ChatToolView *toolView;
/**聊天记录*/
@property(nonatomic,strong) NSMutableArray<CMChatMessage *> *messages;

@end

@implementation ChatViewController

#pragma mark - 懒加载
- (NSMutableArray *)messages
{
    if (_messages == nil) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置子控件
    [self setupChild];
    
    //设置UI
    [self setupUI];
    
    //接受通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage:) name:XMPPReceiveMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];

}

-(void)dealloc
{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 设置UI
/**设置子控件*/
- (void)setupChild
{
    //tableView
    UITableView *tableView = [[UITableView alloc]init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //toolView
    ChatToolView *toolView = [ChatToolView chatToolView];
    toolView.delegate = self;
    toolView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:toolView];
    self.toolView = toolView;
    
}

/**设置frame*/
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    self.toolView.frame = CGRectMake(0, screenH - 55, screenW, 55);
    self.tableView.frame = CGRectMake(0, 0, screenW, screenH - 55);
    
}

/**设置UI*/
- (void)setupUI
{
    self.title = self.buddy.JID.full;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"chat";
    CMChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell =  [[CMChatMessageCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    // 取出模型
    CMChatMessage *message = self.messages[indexPath.row];
    
    // 赋值
    cell.message = message;
    
    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMChatMessageFrameModel *frameModel = [[CMChatMessageFrameModel alloc]init];
    frameModel.message  = self.messages[indexPath.row];
    return frameModel.cellHeight;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


#pragma mark - 通知
/**键盘尺寸改变时的通知*/
- (void)keyboardFrameChanged:(NSNotification *)notice
{
    //UIKeyboardAnimationDurationUserInfoKey
    CGFloat timeInterval = [notice.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]; //时间
    CGFloat offsetY = [notice.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y - [notice.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y;
    [UIView animateWithDuration:timeInterval animations:^{
        CGRect toolViewFrame = self.toolView.frame;
        toolViewFrame.origin.y += offsetY;
        self.toolView.frame = toolViewFrame;
        
        CGRect tableViewFrame = self.tableView.frame;
        tableViewFrame.size.height += offsetY;
        self.tableView.frame = tableViewFrame;
    }];
    
    //滚动表格到最低
    if (self.messages.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

/**收到消息时的通知*/
- (void)receiveMessage:(NSNotification *)notice
{
    //接收到的信息
    XMPPMessage *xmppMessage = (XMPPMessage *)notice.object;
    
    //解析消息
    CMChatMessage *message = [[CMChatMessage alloc]init];
    message.messageType = [xmppMessage attributeIntValueForName:xmpp_message_type]; //取出消息类型
    message.fromToType = CMChatMessageFromToTypeYours;
    message.from = xmppMessage.from;
    message.fromStr = xmppMessage.fromStr;
    message.to = xmppMessage.to;
    message.toStr = xmppMessage.toStr;
    message.body = xmppMessage.body;
    NSDate *now = [NSDate new];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm:ss";
    message.time = [formatter stringFromDate:now];
    
    //更新模型与表格
    [self.messages addObject:message];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}


#pragma mark - ChatToolViewDelegate
//点击发送按钮
- (void)chatToolView:(ChatToolView *)toolView didSendBtnClicked:(UIButton *)button text:(NSString *)text
{
    //构造消息
    CMChatMessage *message = [[CMChatMessage alloc]init];
    message.messageType = CMChatMessageTypeText; //文本消息
    message.fromToType = CMChatMessageFromToTypeMe;
    message.from = [CMXMPPManager shareManager].xmppStream.myJID;
    message.fromStr = message.from.full;
    message.to = self.buddy.JID;
    message.body = text;
    NSDate *now = [NSDate new];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm:ss";
    message.time = [formatter stringFromDate:now];
    
    //更新模型表格
    [self.messages addObject:message];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    //清空发送框文本
    [toolView clearText];
    
    //发送文本信息
    [[CMXMPPManager shareManager] sendTextMessageTo:self.buddy.JID message:text];
}



@end
