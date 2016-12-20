//
//  ContactViewController.m
//  xmppframework
//
//  Created by 23 on 2016/12/12.
//  Copyright © 2016年 23. All rights reserved.
//

#import "ContactViewController.h"
#import "CMXMPPManager.h"
#import "ChatViewController.h"

@interface ContactViewController () <XMPPRosterDelegate>
@property(nonatomic,strong) NSMutableArray *buddies;

@end

@implementation ContactViewController

#pragma mark - 懒加载
-(NSMutableArray *)buddies
{
    if (_buddies == nil) {
        _buddies = [NSMutableArray array];
    }
    return _buddies;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"联系人";
    
    //设置导航栏
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加好友" style:UIBarButtonItemStylePlain target:self action:@selector(addBuddy)];
    
    //添加代理
    [[CMXMPPManager shareManager].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBuddyRequest:) name:XMPPReceiveSubscribeRequestNotification object:nil];
    
}

- (void)dealloc
{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 通知
/**接收到添加好友请求的通知*/
- (void)receiveBuddyRequest:(NSNotification *)notice
{
    //接收到好友请求
    XMPPPresence *presence = notice.object;
    XMPPJID *jid = [presence from];
    
    //弹窗提示
    NSString *message = [NSString stringWithFormat:@"%@请求添加好友",jid.full];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友请求" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"同意并添加对方为好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[CMXMPPManager shareManager].xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[CMXMPPManager shareManager].xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:NO];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[CMXMPPManager shareManager].xmppRoster rejectPresenceSubscriptionRequestFrom:jid];
    }]];
    
    [self presentViewController:alert animated:YES completion:Nil];
}


#pragma mark - 事件监听
/**添加好友*/
- (void)addBuddy
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [ac addAction:[UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = ac.textFields.firstObject.text;
        [[CMXMPPManager shareManager] addBuddyWithName:name];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:ac animated:YES completion:nil];
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.buddies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"buddies";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    CMXMPPBuddy *buddy = self.buddies[indexPath.row];
    cell.textLabel.text = buddy.JID.user;
    return cell;
}

#pragma mark - UITableViewDelete
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除联系人
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //取出模型
        CMXMPPBuddy *buddy = self.buddies[indexPath.row];
        //删除数据
        [self.buddies removeObject:buddy];
        [[CMXMPPManager shareManager] deleteBuddyWithJID:buddy.JID];
        //刷新表格
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取出模型
    CMXMPPBuddy *buddy = self.buddies[indexPath.row];
    
    //跳转
    ChatViewController *chat = [[ChatViewController alloc]init];
    chat.buddy = buddy;
    [self.navigationController pushViewController:chat  animated:YES];
}


#pragma mark - XMPPRoster
/**开始检索好友列表*/
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    NSLog(@"开始检索好友列表");
}

/**检索到好友*/
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    /**
     <item jid="a1@127.0.0.1" name="a1" ask="subscribe" subscription="none">
     <group>Friends</group>
     </item>
     */
    NSLog(@"检索到一个好友  %@",item);
    //属性
    NSString *jid = [item attributeForName:@"jid"].stringValue;
    NSString *name = [item attributeForName:@"name"].stringValue;
    NSString *ask = [item attributeForName:@"ask"].stringValue;
    NSString *subscription = [item attributeForName:@"subscription"].stringValue;
    //分组
    NSString *group = @"";
    for (NSXMLElement *element in item.children) {
        group = [element attributeForName:@"group"].stringValue;
    }
    CMXMPPBuddy *buddy = [CMXMPPBuddy xmppBuddyWithJid:jid name:name ask:ask subscription:subscription group:group];
    
    //判断
    if (![subscription isEqualToString:@"both"]) {
        
        for (CMXMPPBuddy *item in self.buddies) {
            if ([item.JID isEqual:buddy.JID]) {
                [self.buddies removeObject:item];
            }
        }
        [self.tableView reloadData];
        return;
    }
    
    //判断
    for (CMXMPPBuddy *item in self.buddies) {
        if ([item.JID isEqual:buddy.JID]) {
            return;
        }
    }
    
    //添加到通讯录
    [self.buddies addObject:buddy];
    
    //刷新
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.buddies.count - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}

/**结束检索好友列表*/
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"结束检索好友列表");
    [self.tableView reloadData];
}



@end
