//
//  PlaymateSuggestHeadCell.m
//  MomiaIOS
//
//  Created by Deng Jun on 15/7/24.
//  Copyright (c) 2015年 Deng Jun. All rights reserved.
//

#import "FeedSuggestHeadCell.h"

@implementation FeedSuggestHeadCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(id)data {
    [self.avatarIv sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"IconAvatarDefault"]];
}

@end
