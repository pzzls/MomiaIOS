//
//  HomeSubjectCoursesCell.m
//  MomiaIOS
//
//  Created by Deng Jun on 16/3/21.
//  Copyright © 2016年 Deng Jun. All rights reserved.
//

#import "HomeSubjectCoursesCell.h"
#import "IndexModel.h"
#import "AvatarImageView.h"

@interface HomeSubjectCoursesCell()
@property (nonatomic, strong) NSArray<Course> *courses;
@end

@implementation HomeSubjectCoursesCell
@synthesize courses;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(IndexSubject *)model {
    self.titleLabel.text = model.coursesTitle;
    
    [self.coursesContainer removeAllSubviews];
    courses = model.courses;
    if (courses.count == 0) {
        return;
    }
    
    float width = SCREEN_WIDTH / courses.count;
    float height = 160;
    
    for (int i = 0; i < courses.count; i++) {
        Course *course = courses[i];
        
        float center = width * i + width / 2;
        float x = center - width / 2;
        
        UIView *courseView = [[UIView alloc]initWithFrame:CGRectMake(x, 0, width, height)];
        [self.coursesContainer addSubview:courseView];
        courseView.tag = i;
        UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onItemClicked:)];
        [courseView addGestureRecognizer:singleTap];
        
        AvatarImageView *icon = [[AvatarImageView alloc]init];
        [icon sd_setImageWithURL:[NSURL URLWithString:course.cover]];
        [self.coursesContainer addSubview:icon];
        
        // 圆形
        icon.layer.masksToBounds = YES;
        icon.layer.cornerRadius = 30;
        icon.layer.borderWidth = 1;
        icon.layer.borderColor = [[UIColor colorWithRed:85 green:85 blue:85 alpha:1] CGColor];
        
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(courseView);
            make.top.mas_equalTo(courseView);
            make.width.mas_equalTo(@60);
            make.height.mas_equalTo(@60);
        }];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.text = course.keyWord;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = UIColorFromRGB(0x333333);
        [courseView addSubview:nameLabel];
        
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(courseView);
            make.trailing.mas_equalTo(courseView);
            make.top.mas_equalTo(icon.mas_bottom).with.offset(10);
        }];
        
        UILabel *ageLabel = [[UILabel alloc]init];
        ageLabel.text = course.age;
        ageLabel.textAlignment = NSTextAlignmentCenter;
        ageLabel.font = [UIFont systemFontOfSize:12];
        ageLabel.textColor = MO_APP_TextColor_red;
        [courseView addSubview:ageLabel];
        
        [ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(courseView);
            make.trailing.mas_equalTo(courseView);
            make.top.mas_equalTo(nameLabel.mas_bottom).with.offset(10);
        }];
        
        UILabel *joinedLabel = [[UILabel alloc]init];
        joinedLabel.text = course.feature;
        joinedLabel.textAlignment = NSTextAlignmentCenter;
        joinedLabel.font = [UIFont systemFontOfSize:12];
        joinedLabel.textColor = UIColorFromRGB(0x999999);
        [courseView addSubview:joinedLabel];
        
        [joinedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(courseView);
            make.trailing.mas_equalTo(courseView);
            make.top.mas_equalTo(ageLabel.mas_bottom).with.offset(10);
        }];
        
    }
}

- (void)onItemClicked:(UITapGestureRecognizer *)tap {
    UIView *view = tap.view;
    if (courses) {
        Course *course = self.courses[view.tag];
        NSString *url = [NSString stringWithFormat:@"coursedetail?id=%@", course.ids];
        [[UIApplication sharedApplication]openURL:MOURL(url)];
    }
}

+ (CGFloat)heightWithTableView:(UITableView *)tableView withIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath data:(id)data {
    return 222;
}

@end