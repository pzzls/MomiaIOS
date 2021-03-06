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
#import "WXApi.h"
#import "AlipayOrderModel.h"
#import "AlipayOrder.h"
#import "PayTool.h"
#import "Coupon.h"
#import "CouponListViewController.h"
#import "CouponPriceModel.h"
#import "StringUtils.h"
#import "PayResultViewController.h"

static NSString * identifier = @"HeaderViewCashPayBottomHeader";
static NSString * cashPayBottomIdentifier = @"CellCashPayBottom";

@interface CashPayViewController ()

@property(nonatomic, strong) PostOrderModel *order;
@property(nonatomic, strong) NSMutableArray *payChannels;

@property(nonatomic, strong) Coupon *coupon;
@property(nonatomic, strong) CouponPriceModel *couponPrice;

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
    [CashPayBottomCell registerCellFromNibWithTableView:self.tableView withIdentifier:cashPayBottomIdentifier];
    [CommonHeaderView registerCellFromNibWithTableView:self.tableView];
    
    self.payChannels = [NSMutableArray new];
    [self.payChannels addObject:[[PayChannel alloc]initWithType:1 title:@"微信支付" desc:@"推荐已安装微信的用户使用" icon:@"IconWechat" select:YES]];
    [self.payChannels addObject:[[PayChannel alloc]initWithType:2 title:@"支付宝" desc:@"推荐支付宝用户使用" icon:@"IconAlipay" select:NO]];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestCouponPrice {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary * params = @{@"oid":[NSString stringWithFormat:@"%ld", (long)self.order.data.orderId],
                              @"coupon":[NSString stringWithFormat:@"%@", self.coupon.ids]};
    [[HttpService defaultService]GET:URL_APPEND_PATH(@"/subject/order/coupon")
                          parameters:params cacheType:CacheTypeDisable JSONModelClass:[CouponPriceModel class]
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  
                                  self.couponPrice = (CouponPriceModel*)responseObject;
                                  [self.tableView reloadData];
                              }
     
                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  [MBProgressHUD hideHUDForView:self.view animated:YES];
                                  [self showDialogWithTitle:nil message:error.message];
                                  self.coupon = nil;
                              }];
}

- (void)onPayClicked {
    // 0元购
    if (self.order.data.totalFee == 0.0f || (self.couponPrice && self.couponPrice.data == 0.0f)) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setValue:[NSString stringWithFormat:@"%ld", (long)self.order.data.orderId] forKey:@"oid"];
        [dic setValue:self.coupon.ids forKey:@"coupon"];
        [dic setValue:@"1" forKey:@"free"];
        PayResultViewController *payResult = [[PayResultViewController alloc]initWithParams:dic];
        [self.navigationController pushViewController:payResult animated:YES];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSInteger type = 0;
    for (int i = 0; i < self.payChannels.count; i++) {
        PayChannel *channel = [self.payChannels objectAtIndex:i];
        if (channel.select) {
            type = channel.type;
            break;
        }
    }
    
    if (type == 1) {
        NSMutableDictionary * params = [[NSMutableDictionary alloc]initWithDictionary:@{@"type":@"APP",
                                                                                        @"oid":[NSString stringWithFormat:@"%ld", (long)self.order.data.orderId]}];
        if (self.coupon) {
            [params setValue:[NSString stringWithFormat:@"%@", self.coupon.ids] forKey:@"coupon"];
        }
        [[HttpService defaultService]POST:URL_HTTPS_APPEND_PATH(@"/payment/prepay/weixin")
                               parameters:params JSONModelClass:[WechatPayModel class]
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                      
                                      //前往支付
                                      if ([responseObject isKindOfClass:[WechatPayModel class]]) {
                                          [self.delegate sendPay:((WechatPayModel *)responseObject).data];
                                          [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPayResp:) name:@"payResp" object:nil];
                                      }
                                  }
         
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                      [self showDialogWithTitle:nil message:error.message];
                                  }];
        
    } else if (type == 2) {
        NSMutableDictionary * params = [[NSMutableDictionary alloc]initWithDictionary:@{@"type":@"APP",
                                                                                        @"oid":[NSString stringWithFormat:@"%ld", (long)self.order.data.orderId]}];
        if (self.coupon) {
            [params setValue:[NSString stringWithFormat:@"%@", self.coupon.ids] forKey:@"coupon"];
        }
        [[HttpService defaultService]POST:URL_HTTPS_APPEND_PATH(@"/payment/prepay/alipay")
                               parameters:params JSONModelClass:[AlipayOrderModel class]
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                      
                                      //前往支付
                                      if ([responseObject isKindOfClass:[AlipayOrderModel class]]) {
                                          PayTool *payTool = [PayTool new];
                                          [payTool startAlipay:((AlipayOrderModel *)responseObject).data payResult:^(BOOL success){
                                              if (success) {
                                                  NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                                                  [dic setValue:[NSString stringWithFormat:@"%ld", (long)self.order.data.orderId] forKey:@"oid"];
                                                  PayResultViewController *payResult = [[PayResultViewController alloc]initWithParams:dic];
                                                  [self.navigationController pushViewController:payResult animated:YES];
                                                  
                                                  NSDictionary *attributes = @{@"channel":@"alipay"};
                                                  [MobClick event:@"Pay_Submit" attributes:attributes];
                                                  
                                              } else {
                                                  [self showDialogWithTitle:nil message:@"支付失败，请重新尝试或选择其他方式支付"];
                                              }
                                          }] ;
                                      }
                                  }
         
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                      [self showDialogWithTitle:nil message:error.message];
                                  }];
        
    }
    
}

- (UITableViewCellSeparatorStyle)tableViewCellSeparatorStyle {
    return UITableViewCellSeparatorStyleSingleLine;
}

-(void)onPayResp:(NSNotification*)notify {
    BaseResp *resp = notify.object;
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        
    } else if([resp isKindOfClass:[PayResp class]]) {
        if (resp.errCode == WXSuccess) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[NSString stringWithFormat:@"%ld", (long)self.order.data.orderId] forKey:@"oid"];
            PayResultViewController *payResult = [[PayResultViewController alloc]initWithParams:dic];
            [self.navigationController pushViewController:payResult animated:YES];
            
            NSDictionary *attributes = @{@"channel":@"wechatpay"};
            [MobClick event:@"Pay_Submit" attributes:attributes];
            
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            // Configure for text only and offset down
            hud.mode = MBProgressHUDModeText;
            hud.labelText = resp.errStr;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1];
        }
    }
}

#pragma mark - datasource & delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            CouponListViewController *couponListViewController = [[CouponListViewController alloc]initWithParams:@{@"select":@YES, @"oid":[NSString stringWithFormat:@"%ld", (long)self.order.data.orderId], @"status":@"1"}];
            couponListViewController.selectCouponBlock = ^(Coupon *coupon){
                self.coupon = coupon;
                [self requestCouponPrice];
            };
            [self.navigationController pushViewController:couponListViewController animated:YES];
            
            [MobClick event:@"Pay_Coupon"];
        }
        
    } else if (indexPath.section == 2) {
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        return 2;
    } else if(section == 1) {
        return 2;
    } else {
        return self.payChannels.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   if(section <= 1) return 10;
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
    if(section == 2) {
        CommonHeaderView * header = [CommonHeaderView cellWithTableView:self.tableView];
        header.data = @"选择支付方式";
        header.cmLeadingConstraint.constant = 15;
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
        [button setBackgroundImage:[UIImage imageNamed:@"BgRedLargeButtonNormal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"BgLargeButtonDisable"] forState:UIControlStateDisabled];
        
        [view addSubview:button];
    }
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if(section <= 1) {
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
    if(section == 0 || section == 1) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.textColor = UIColorFromRGB(0x666666);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = UIColorFromRGB(0x333333);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        if (section == 0) {
            if (row == 0) {
                cell.textLabel.text = @"订单数量";
                if (self.order) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", (int)self.order.data.count];
                }
            } else if (row == 1) {
                cell.textLabel.text = @"总价";
                if (self.order) {
                    cell.detailTextLabel.text = [StringUtils stringForPrice:self.order.data.totalFee];
                }
            }
        } else if (section == 1) {
            if (row == 0) {
                cell.textLabel.text = @"红包";
                if (self.order) {
                    cell.detailTextLabel.textColor = MO_APP_ThemeColor;
                    if (self.coupon) {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"减￥%@", self.coupon.discount];
                        
                    } else {
                        cell.detailTextLabel.text = @"使用红包";
                    }
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            } else if (row == 1) {
                cell.textLabel.text = @"还需支付";
                if (self.couponPrice) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%@", [StringUtils stringForPrice:self.couponPrice.data]];
                    
                } else if (self.order) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"￥%@", [StringUtils stringForPrice:self.order.data.totalFee]];
                }
            }
        }
        
    } else if(section == 2) {
        CashPayBottomCell * bottom = [CashPayBottomCell cellWithTableView:tableView forIndexPath:indexPath withIdentifier:cashPayBottomIdentifier];
        bottom.data = [self.payChannels objectAtIndex:row];
        cell = bottom;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
