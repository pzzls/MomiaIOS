//
//  ActivityDetailViewController.m
//  MomiaIOS
//
//  Created by Owen on 15/6/16.
//  Copyright (c) 2015年 Deng Jun. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "ProductDetailCarouselCell.h"
#import "ProductDetailTagsCell.h"
#import "ProductDetailEnrollCell.h"
#import "ProductDetailBasicInfoCell.h"
#import "ProductDetailContentCell.h"
#import "ProductDetailModel.h"
#import "CommonHeaderView.h"
#import "ThirdShareHelper.h"
#import "SGActionView.h"
#import "MJRefresh.h"

static NSString * productDetailCarouselIdentifier = @"CellProductDetailCarousel";
static NSString * productDetailEnrollIdentifier = @"CellProductDetailEnroll";
static NSString * productDetailBasicInfoIdentifier = @"CellProductDetailBasicInfo";
static NSString * productDetailContentIdentifier = @"CellProductDetailContent";
static NSString * productDetailTagsIdentifier = @"CellProductDetailTags";

typedef enum
{
    CellStyleContent,
    CellStyleImage,
    CellStyleLink
} CellStyle;

@interface ProductDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *signUpBtn;

@property(nonatomic,strong) ProductDetailModel * model;
@property(nonatomic,strong) NSString * productId;

@property(nonatomic,strong) NSMutableDictionary * contentCellDictionary;
@property(nonatomic,strong) NSMutableDictionary * contentCellHeightCacheDic;

@end

@implementation ProductDetailViewController


-(instancetype)initWithParams:(NSDictionary *)params
{
    self = [super initWithParams:params];
    if(self) {
        self.productId =  [params objectForKey:@"id"];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"活动详情";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TitleFav"] style:UIBarButtonItemStylePlain target:self action:@selector(onFavClick)];
    
    [ProductDetailCarouselCell registerCellWithTableView:self.tableView withIdentifier:productDetailCarouselIdentifier];
    [ProductDetailEnrollCell registerCellWithTableView:self.tableView withIdentifier:productDetailEnrollIdentifier];
    [ProductDetailBasicInfoCell registerCellWithTableView:self.tableView withIdentifier:productDetailBasicInfoIdentifier];
    [ProductDetailTagsCell registerCellWithTableView:self.tableView withIdentifier:productDetailTagsIdentifier];
    [CommonHeaderView registerCellWithTableView:self.tableView];
    
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.backgroundView.backgroundColor = UIColorFromRGB(0xf1f1f1);
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    
    self.tableView.header = header;
    
    self.tableView.width = SCREEN_WIDTH;
    
    [self requestData:NO];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(-1, 0, 0, 0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onFavClick {
    if (self.model == nil) {
        return;
    }
    
    if ([self.model.data.favored boolValue]) {
        NSDictionary * dic = @{@"id":self.productId};
        [[HttpService defaultService] POST:URL_APPEND_PATH(@"/product/unfavor") parameters:dic JSONModelClass:[BaseModel class] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.model.data.favored = [NSNumber numberWithBool:NO];
            [self changeFavStatus];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
    } else {
        NSDictionary * dic = @{@"id":self.productId};
        [[HttpService defaultService] POST:URL_APPEND_PATH(@"/product/favor") parameters:dic JSONModelClass:[BaseModel class] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.model.data.favored = [NSNumber numberWithBool:YES];
            [self changeFavStatus];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

#pragma mark - webData Request

- (void)requestData:(BOOL)refresh {
    if (self.model == nil) {
        [self.view showLoadingBee];
    }
    
    CacheType cacheType = refresh ? CacheTypeDisable : CacheTypeDisable;
    
    NSDictionary * dic = @{@"id":self.productId};
    [[HttpService defaultService] GET:URL_APPEND_PATH(@"/product") parameters:dic cacheType:cacheType JSONModelClass:[ProductDetailModel class] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (self.model == nil) {
            [self.view removeLoadingBee];
        }
        
        self.model = responseObject;
        
        if (self.model.data.soldOut || ![self.model.data.opened boolValue]) {
            [self.signUpBtn setBackgroundColor:UIColorFromRGB(0x999999)];
            if (self.model.data.soldOut) {
                // 已卖完
                [self.signUpBtn setTitle:@"报名人数已满" forState:UIControlStateNormal];
            } else {
                // 已结束
                [self.signUpBtn setTitle:@"报名已结束" forState:UIControlStateNormal];
            }
            
        } else {
            [self.signUpBtn setBackgroundColor:UIColorFromRGB(0xff5d33)];
        }
        
        // 收藏
        [self changeFavStatus];
        
        [self.tableView reloadData];
        [self.tableView.header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.view removeLoadingBee];
        [self showDialogWithTitle:nil message:error.message];
        [self.tableView.header endRefreshing];
    }];
}

- (void)refreshData {
    [self requestData:YES];
}

- (void)changeFavStatus {
    if ([self.model.data.favored boolValue]) {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"TitleFaved"];
    } else {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"TitleFav"];
    }
}

-(NSMutableDictionary *)contentCellDictionary
{
    if(!_contentCellDictionary) {
        _contentCellDictionary = [[NSMutableDictionary alloc] init];
    }
    return _contentCellDictionary;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   return 0.1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2 && self.model.data.customers.avatars.count == 0) {
        return 0.1;
    }
    return 10.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.model)
        return 3 + self.model.data.content.count;
    return 0;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        if (self.model.data.tags.count > 0) return 2;
        return 1;
    } else if(section == 1) {
        return 3;

    } else if(section == 2) {
        if(self.model.data.customers.avatars.count > 0)
            return 1;
        else return 0;
    } else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0) {
        if(row == 0)
            height = [ProductDetailCarouselCell heightWithTableView:tableView withIdentifier:productDetailCarouselIdentifier forIndexPath:indexPath data:self.model.data];
        else height = 43;
    } else if(section == 1) {
        height = 43;
    } else if(section == 2) {
        height = [ProductDetailEnrollCell heightWithTableView:tableView withIdentifier:productDetailEnrollIdentifier forIndexPath:indexPath data:self.model.data.customers];
    } else {
        ProductContentModel *model = self.model.data.content[section - 3];
        NSNumber *cacheHeight;
        if (self.contentCellHeightCacheDic) {
            cacheHeight = [self.contentCellHeightCacheDic objectForKey:[NSNumber numberWithInteger:model.hash]];
        }
        if (cacheHeight) {
            height = [cacheHeight floatValue];
            
        } else {
            height = [ProductDetailContentCell heightWithTableView:tableView contentModel:self.model.data.content[section - 3]];
            if (self.contentCellHeightCacheDic == nil) {
                self.contentCellHeightCacheDic = [NSMutableDictionary new];
            }
            [self.contentCellHeightCacheDic setObject:[NSNumber numberWithFloat:height] forKey:[NSNumber numberWithInteger:model.hash]];
        }
    }
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0) {
        if(row == 0) {
            ProductDetailCarouselCell * carousel = [ProductDetailCarouselCell cellWithTableView:tableView forIndexPath:indexPath withIdentifier:productDetailCarouselIdentifier];
            carousel.data = self.model.data;
            cell = carousel;
        } else {
            ProductDetailTagsCell * tags = [ProductDetailTagsCell cellWithTableView:self.tableView forIndexPath:indexPath withIdentifier:productDetailTagsIdentifier];
            [tags setData:self.model.data];
            cell = tags;
        }
    } else if(section == 1) {
        ProductDetailBasicInfoCell * basicInfo = [ProductDetailBasicInfoCell cellWithTableView:tableView forIndexPath:indexPath withIdentifier:productDetailBasicInfoIdentifier];
        [basicInfo setData:self.model.data withIndex:row];
        cell = basicInfo;
      
    } else if(section == 2) {
        ProductDetailEnrollCell * enroll = [ProductDetailEnrollCell cellWithTableView:tableView forIndexPath:indexPath withIdentifier:productDetailEnrollIdentifier];
        enroll.data = self.model.data.customers;
        cell = enroll;
    } else {
        ProductContentModel * model = self.model.data.content[section - 3];
        ProductDetailContentCell * content = [self.contentCellDictionary objectForKey:indexPath];
        if(!content) {
            content = [[ProductDetailContentCell alloc] initWithTableView:tableView contentModel:model];
            [self.contentCellDictionary setObject:content forKey:indexPath];
        }
        content.linkBlock = ^(UIView * linkView) {
            UIColor * originColor = linkView.backgroundColor;

            NSLog(@"content:%ld body:%ld", (long)indexPath.section, (long)linkView.tag);

            [UIView animateWithDuration:0.3 animations:^{
                linkView.backgroundColor = UIColor.lightGrayColor;
            } completion:^(BOOL finished) {
                linkView.backgroundColor = originColor;
            }];
        };
        cell = content;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if(section == 2) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"duola://productplayfellow?id=%@", self.productId]];
        [[UIApplication sharedApplication] openURL:url];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (IBAction)dateFriend:(id)sender {
    ThirdShareHelper *helper = [ThirdShareHelper new];
    [SGActionView showGridMenuWithTitle:@"约伴"
                             itemTitles:@[ @"微信好友", @"微信朋友圈"]
                                 images:@[ [UIImage imageNamed:@"IconShareWechat"],
                                           [UIImage imageNamed:@"IconShareWechatTimeline"]]
                         selectedHandle:^(NSInteger index) {
                             if (index == 1) {
                                 [helper shareToWechat:self.model.data.url thumbUrl:self.model.data.thumb title:self.model.data.title desc:self.model.data.abstracts scene:1];
                             } else if (index == 2) {
                                 [helper shareToWechat:self.model.data.url thumbUrl:self.model.data.thumb title:self.model.data.title desc:self.model.data.abstracts scene:2];
                             }
                         }];
}

- (IBAction)signUp:(id)sender {
    
    if(self.model) {
        if(!self.model.data.soldOut) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"duola://fillorder?id=%@", self.productId]];
            [[UIApplication sharedApplication] openURL:url];
        }
    }

}

@end
