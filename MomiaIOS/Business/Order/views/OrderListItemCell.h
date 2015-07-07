//
//  OrderListItemCell.h
//  MomiaIOS
//
//  Created by Deng Jun on 15/7/5.
//  Copyright (c) 2015年 Deng Jun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface OrderListItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconTv;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;

- (void)setData:(Order *)order;

@end
