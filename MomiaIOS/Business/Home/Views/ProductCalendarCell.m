//
//  ProductCalendarCell.m
//  MomiaIOS
//
//  Created by Owen on 15/7/16.
//  Copyright (c) 2015年 Deng Jun. All rights reserved.
//

#import "ProductCalendarCell.h"

@interface ProductCalendarCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *schedualLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation ProductCalendarCell

-(void)setData:(ProductModel *)model
{
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:nil];
    [self.titleLabel setText:model.abstracts];
    [self.addressLabel setText:model.address];
    [self.schedualLabel setText:model.scheduler];
}

- (void)awakeFromNib {
    // Initialization code
    self.iconImageView.clipsToBounds = YES;
    self.iconImageView.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
