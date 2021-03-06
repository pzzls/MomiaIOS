//
//  CourseTagsCell.m
//  MomiaIOS
//
//  Created by Deng Jun on 15/10/10.
//  Copyright © 2015年 Deng Jun. All rights reserved.
//

#import "CourseTagsCell.h"
#import "Subject.h"
#import "Course.h"

@implementation CourseTagsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(id)model {
    self.contentView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    BOOL isSubject = [model isKindOfClass:[Subject class]];
    
    for (UIView * view in self.contentView.subviews) {
        if([view isKindOfClass:[UIImageView class]] || [view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    UIView * lastView;
    int tagCount;
    if (!isSubject && ((Course *)model).insurance && [((Course *)model).insurance boolValue]) {
        tagCount = 2;
    } else {
        tagCount = 1;
    }
    for (int i = 0; i < tagCount; i++) {
        UIImageView * imgView = [[UIImageView alloc] init];
        [self.contentView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            if(i == 0) make.leading.equalTo(self.contentView).with.offset(10);
            else make.leading.equalTo(lastView.mas_trailing).with.offset(10);
            make.width.equalTo(@10);
            make.height.equalTo(@10);
        }];
        [imgView setImage:[UIImage imageNamed:@"IconProductTag"]];
        
        UILabel * label = [[UILabel alloc] init];
        [self.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.leading.equalTo(imgView.mas_trailing).with.offset(5);
        }];
        
        if (i == 0) {
            label.text = [NSString stringWithFormat:@"适合%@", isSubject ? ((Subject *)model).age : ((Course *)model).age];
        } else if (i == 1) {
            label.text = @"送保险";
        }
        
        label.textColor = UIColorFromRGB(0x9999999);
        label.font = [UIFont systemFontOfSize:12.0f];
        
        lastView = label;
    }
    
    NSNumber *joined = isSubject ? ((Subject *)model).joined : ((Course *)model).joined;
    if (joined == nil || [joined intValue] == 0) {
        return;
    }
    
    // joined
    UIImageView * imgView = [[UIImageView alloc] init];
    [self.contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(@10);
        make.height.equalTo(@10);
        make.left.equalTo(lastView.mas_right).with.offset(10);
    }];
    [imgView setImage:[UIImage imageNamed:@"IconProductTag"]];
    
    UILabel * label = [[UILabel alloc] init];
    [self.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(imgView.mas_right).with.offset(5);
    }];
    label.text = [NSString stringWithFormat:@"%@人参加", joined];
    label.textColor = UIColorFromRGB(0x999999);
    label.font = [UIFont systemFontOfSize:12.0f];
}

+ (CGFloat)heightWithTableView:(UITableView *)tableView withIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath data:(id)data {
    return 36;
}

@end
