//
//  OrderDetailController.m
//  MomiaIOS
//
//  Created by Deng Jun on 15/11/25.
//  Copyright © 2015年 Deng Jun. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderDetailModel.h"
#import "PostOrderModel.h"
#import "OrderListItemCell.h"
#import "CourseSectionTitleCell.h"
#import "ApplyRefundViewController.h"
#import "RefundDetailViewController.h"
#import "OrderListItemFooterCell.h"

static NSString *identifierCourseSectionTitleCell = @"CourseSectionTitleCell";

@interface OrderDetailViewController ()

@property (nonatomic, strong) NSString *oid;
@property (nonatomic, strong) OrderDetailModel *model;

@end

@implementation OrderDetailViewController

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super initWithParams:params]) {
        self.oid = [params objectForKey:@"oid"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"订单详情";
    
    [CourseSectionTitleCell registerCellFromNibWithTableView:self.tableView withIdentifier:identifierCourseSectionTitleCell];
    
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)requestData {
    if (self.model == nil) {
        [self.view showLoadingBee];
    }
    
    NSDictionary * paramDic = @{@"oid":self.oid};
    NSString *orderDetailURL = URL_APPEND_PATH(@"/subject/order/detail");
    [[HttpService defaultService]GET:orderDetailURL
                          parameters:paramDic
                           cacheType:CacheTypeDisable
                      JSONModelClass:[OrderDetailModel class]
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                     [self.view removeLoadingBee];
                                                     self.model = responseObject;
                                                     [self.tableView reloadData];
                                                 }
                         
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     [self.view removeLoadingBee];
                                                     [self showDialogWithTitle:nil message:error.message];
                                                 }];
}

- (UIEdgeInsets)separatorInsetForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return UIEdgeInsetsMake(0,SCREEN_WIDTH,0,0);
    }
    return UIEdgeInsetsMake(0,10,0,0);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([self.model.data.courseId intValue] > 0) {
            [self openURL:[NSString stringWithFormat:@"coursedetail?id=%@", self.model.data.courseId]];
            
        } else {
            [self openURL:[NSString stringWithFormat:@"subjectdetail?id=%@", self.model.data.subjectId]];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.model) {
        if (self.model.data.groupInfo == nil) {
            return 2;
        }
        return 3;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (self.model.data.couponDesc.length > 0) {
        return 6;
    } else {
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            
            static NSString *CellOrderListItem = @"CellOrderListItemFooter";
            cell = [tableView dequeueReusableCellWithIdentifier:CellOrderListItem];
            if (cell == nil) {
                NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"OrderListItemCell" owner:self options:nil];
                OrderListItemFooterCell *itemCell = [arr objectAtIndex:1];
                [itemCell setData:self.model.data];
                cell = itemCell;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        static NSString *Cell_Order_List_Item = @"CellOrderListItem";
        cell = [tableView dequeueReusableCellWithIdentifier:Cell_Order_List_Item];
        if (cell == nil) {
            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"OrderListItemCell" owner:self options:nil];
            OrderListItemCell *itemCell = [arr objectAtIndex:0];
            cell = itemCell;
        }
        [(OrderListItemCell *)cell setData:self.model.data];
        
    } else if(indexPath.section == 1 && self.model.data.groupInfo != nil){
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDefault"];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = UIColorFromRGB(0x333333);
            cell.textLabel.text = @"拼团详情";
            
        } else {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDefault"];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.textLabel.textColor = MO_APP_TextColor_gray;
            NSString *text;
            if (indexPath.row == 1) {
                text = [NSString stringWithFormat:@"订单号：%@", self.model.data.ids];
            } else if (indexPath.row == 2) {
                text = [NSString stringWithFormat:@"数量：%@", self.model.data.count];
            } else if (indexPath.row == 3) {
                text = [NSString stringWithFormat:@"总价：%@", self.model.data.totalFee];
            } else if (indexPath.row == 4 && self.model.data.couponDesc.length > 0) {
                text = [NSString stringWithFormat:@"使用抵扣：%@", self.model.data.couponDesc];
            } else {
                text = [NSString stringWithFormat:@"下单时间：%@", self.model.data.addTime];
            }
            cell.textLabel.text = text;
        }
        
    } else if(indexPath.section == 2 && self.model.data.groupInfo != nil) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDefault"];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = UIColorFromRGB(0x333333);
            cell.textLabel.text = @"订单详情";
            
        } else {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDefault"];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.textLabel.textColor = MO_APP_TextColor_gray;
            NSString *text;
            if (indexPath.row == 1) {
                text = [NSString stringWithFormat:@"订单号：%@", self.model.data.ids];
            } else if (indexPath.row == 2) {
                text = [NSString stringWithFormat:@"数量：%@", self.model.data.count];
            } else if (indexPath.row == 3) {
                text = [NSString stringWithFormat:@"总价：%@", self.model.data.totalFee];
            } else if (indexPath.row == 4 && self.model.data.couponDesc.length > 0) {
                text = [NSString stringWithFormat:@"使用抵扣：%@", self.model.data.couponDesc];
            } else {
                text = [NSString stringWithFormat:@"下单时间：%@", self.model.data.addTime];
            }
            cell.textLabel.text = text;
        }
    } else if(indexPath.section == 1 && self.model.data.groupInfo == nil) {
        if (indexPath.row == 0) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDefault"];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = UIColorFromRGB(0x333333);
            cell.textLabel.text = @"订单详情";
            
        } else {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDefault"];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.textLabel.textColor = MO_APP_TextColor_gray;
            NSString *text;
            if (indexPath.row == 1) {
                text = [NSString stringWithFormat:@"订单号：%@", self.model.data.ids];
            } else if (indexPath.row == 2) {
                text = [NSString stringWithFormat:@"数量：%@", self.model.data.count];
            } else if (indexPath.row == 3) {
                text = [NSString stringWithFormat:@"总价：%@", self.model.data.totalFee];
            } else if (indexPath.row == 4 && self.model.data.couponDesc.length > 0) {
                text = [NSString stringWithFormat:@"使用抵扣：%@", self.model.data.couponDesc];
            } else {
                text = [NSString stringWithFormat:@"下单时间：%@", self.model.data.addTime];
            }
            cell.textLabel.text = text;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 88;
    } else {
        if (indexPath.row == 0) {
            return [CourseSectionTitleCell heightWithTableView:tableView withIdentifier:identifierCourseSectionTitleCell forIndexPath:indexPath data:nil];
        } else {
            return 40;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.f;
}

- (void)onActionBtnClicked {
    Order *order = self.model.data;
    if ([order.status intValue] == 2) {
        PostOrderModel *po = [PostOrderModel new];
        
        PostOrderData *data = [PostOrderData new];
        data.orderId = [order.ids integerValue];
        data.count = [order.count integerValue];
        data.totalFee = [order.totalFee floatValue];
        
        po.data = data;
        po.errNo = 0;
        po.errMsg = @"";
        po.timestamp = 0;
        
        [self openURL:[NSString stringWithFormat:@"cashpay?pom=%@",
                       [[po toJSONString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
    }
}

@end
