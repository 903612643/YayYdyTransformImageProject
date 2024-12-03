//
//  DeviceLinkRootVC.m
//  YdyTransformImageProject
//
//  Created by LaserPecker-iOS on 2024/11/29.
//

#import "DeviceLinkRootVC.h"
#import "CocoaAsyncSocketHelper.h"
#import "readBufferTableCell.h"

@interface DeviceLinkRootVC ()<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *sendBufferTextView;
@property (weak, nonatomic) IBOutlet UITextField *linkDeviceTextF;
@property (weak, nonatomic) IBOutlet UILabel *sendBufferTipLab;
@property (weak, nonatomic) IBOutlet UITextField *portTextF;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn;

@end

@implementation DeviceLinkRootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dataArr = [[NSMutableArray alloc] init];
    
    // 添加点击手势来关闭键盘
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        [self.view addGestureRecognizer:tapGesture];
    
    _linkDeviceTextF.delegate = self;
    _portTextF.delegate = self;
    self.sendBufferTextView.delegate = self;
    self.sendBufferTipLab.text = @"1.发送包：aabb080003000000000003\n2.拼包发送（斜线分割）：aabb08000300/0000000003";
    
   // [_tableView registerClass:[readTableCell class] forCellReuseIdentifier:@"readTableCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"readBufferTableCell" bundle:nil] forCellReuseIdentifier:@"readBufferTableCell"];
    if(@available(iOS 15.0,*))
    {
        _tableView.sectionHeaderTopPadding=0;
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.estimatedRowHeight = 40; // 预估高度
    self.tableView.rowHeight = UITableViewAutomaticDimension; // 自动计算高度
    
    
    if ([[CocoaAsyncSocketHelper sharedInstance].tcpSocket isConnected]) {
        [self.linkBtn setTitle:@"断开连接" forState:UIControlStateNormal];
        self.linkBtn.selected = YES;
    }
    
    __weak __typeof(self)weakSelf = self;
    [CocoaAsyncSocketHelper sharedInstance].resultDatablock = ^(NSArray * _Nonnull dataArr) {
        weakSelf.dataArr = [[NSMutableArray alloc] initWithArray:dataArr];
        [weakSelf.tableView reloadData];
    };
    self.dataArr = [CocoaAsyncSocketHelper sharedInstance].dataArr;
}

- (void)dismissKeyboard {
    [self.sendBufferTextView resignFirstResponder]; // 收起键盘
    [self.linkDeviceTextF resignFirstResponder];
    [self.portTextF resignFirstResponder];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)linkDeviceAction:(UIButton *)sender {
    [CocoaAsyncSocketHelper sharedInstance].linkResultlock = ^{
        [sender setTitle:@"断开连接" forState:UIControlStateNormal];
        sender.selected = YES;
    };
    [CocoaAsyncSocketHelper sharedInstance].dissLinkResultlock = ^{
        [sender setTitle:@"连接" forState:UIControlStateNormal];
        sender.selected = NO;
    };
    if (sender.selected == NO) {
        [[CocoaAsyncSocketHelper sharedInstance] connectWiFiWithIpAddress:self.linkDeviceTextF.text port:[self.portTextF.text intValue]];
    }else{
        [[CocoaAsyncSocketHelper sharedInstance].tcpSocket disconnect];
    }
}

- (IBAction)sendTestDataAction:(UIButton *)sender {
    
    [[CocoaAsyncSocketHelper sharedInstance] sendBuffer];
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.sendBufferTipLab.hidden = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    readBufferTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"readBufferTableCell" forIndexPath:indexPath];
    cell.readLab.text = self.dataArr[indexPath.row][@"data"];
    cell.tipLab.text = self.dataArr[indexPath.row][@"title"];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end

