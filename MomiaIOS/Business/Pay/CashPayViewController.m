//
//  CashPayViewController.m
//  MomiaIOS
//
//  Created by Owen on 15/6/10.
//  Copyright (c) 2015年 Deng Jun. All rights reserved.
//

#import "CashPayViewController.h"
#import "CashPayBottomCell.h"
#import "AppDelegate.h"
#import "PostOrderModel.h"
#import "NSString+MOURLEncode.h"
#import "CommonHeaderView.h"
#import "PayChannel.h"
#import "WechatPayModel.h"

static NSString * identifier = @"HeaderViewCashPayBottomHeader";
static NSString * cashPayBottomIdentifier = @"CellCashPayBottom";

@interface CashPayViewController ()

@property(nonatomic, strong) PostOrderModel *order;
@property(nonatomic, strong) NSMutableArray *payChannels;

@end

@implementation CashPayViewController

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super initWithParams:params]) {
        
        self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *pomJson = [[params objectForKey:@"pom"] URLDecodedString];
        NSData *jsonData = [pomJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
        self.order = [(PostOrderModel *)[PostOrderModel alloc]initWithDictionary:dic error:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"收银台";
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:identifier];
    [CashPayBottomCell registerCellWithTableView:self.tableView withIdentifier:cashPayBottomIdentifier];
    [CommonHeaderView registerCellWithTableView:self.tableView];
    
    self.payChannels = [NSMutableArray new];
    [self.payChannels addObject:[[PayChannel alloc]initWithType:1 title:@"微信支付" desc:@"微信钱包，银行卡支付" icon:@"pay_wx" select:YES]];
    [self.payChannels addObject:[[PayChannel alloc]initWithType:1 title:@"支付宝" desc:@"支付宝账号支付，银行卡支付" icon:@"pay_order" select:NO]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onPayClicked {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary * params = @{@"trade_type":@"NATIVE",
                              @"oid":[NSString stringWithFormat:@"%d", self.order.data.orderId],
                              @"pid":[NSString stringWithFormat:@"%d", self.order.data.productId],
                              @"sid":[NSString stringWithFormat:@"%d", self.order.data.skuId]};
    [[HttpService defaultService]POST:URL_HTTPS_APPEND_PATH(@"/payment/prepay/wechatpay")
                          parameters:params JSONModelClass:[WechatPayModel class]
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 
                                 //前往支付
                                 if ([responseObject isKindOfClass:[WechatPayModel class]]) {
                                     [self.delegate sendPay:((WechatPayModel *)responseObject).data];
                                 }
                             }
     
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                 [self showDialogWithTitle:nil message:error.message];
                             }];
}

- (UITableViewCellSeparatorStyle)tableViewCellSeparatorStyle {
    return UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark - datasource & delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        for (int i = 0; i < self.payChannels.count; i++) {
            PayChannel *channel = [self.payChannels objectAtIndex:i];
            if (i == indexPath.row) {
                channel.select = YES;
            } else {
                channel.select = NO;
            }
        }
        [tableView reloadData];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 2;
    } else {
        return self.payChannels.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   if(section == 0) return 10;
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        return 80;
    }
    return 0.1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * header;
    if(section == 1) {
        header = [CommonHeaderView cellWithTableView:self.tableView];
        ((CommonHeaderView *)header).data = @"选择支付方式";
        return header;
    }
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [UIView new];
    if (section == [self numberOfSectionsInTableView:tableView] - 1) {
        UIButton *button = [[UIButton alloc]init];
        button.height = 40;
        button.width = 280;
        button.left = (SCREEN_WIDTH - button.width) / 2;
        button.top = 30;
        [button setTitle:@"确认支付" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onPayClicked) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:@"cm_large_red_button_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"cm_large_button_disable"] forState:UIControlStateDisabled];
        
        [view addSubview:button];
    }
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if(section == 0) {
        return 44;
    } else {
        return 60;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    UITableViewCell * cell;
    if(section == 0) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.textColor = UIColorFromRGB(0x666666);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = UIColorFromRGB(0x333333);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        if (row == 0) {
            cell.textLabel.text = @"订单数量";
            if (self.order) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)self.order.data.count];
            }
        } else if (row == 1) {
            cell.textLabel.text = @"总价";
            if (self.order) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%.2f", self.order.data.totalFee];
            }
        }
        
    } else if(section == 1) {
        CashPayBottomCell * bottom = [CashPayBottomCell cellWithTableView:tableView forIndexPath:indexPath withIdentifier:cashPayBottomIdentifier];
        bottom.data = [self.payChannels objectAtIndex:row];
        cell = bottom;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
