//
//  OrderDetailTopCell.h
//  MomiaIOS
//
//  Created by Owen on 15/7/7.
//  Copyright (c) 2015年 Deng Jun. All rights reserved.
//

#import "MOTableCell.h"
#import "OrderDetailModel.h"

@interface OrderDetailTopCell : MOTableCell<MOTableCellDataProtocol>

-(void)setData:(OrderDetailDataModel *)model;

@end
