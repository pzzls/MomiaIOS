//
//  HomeViewController.m
//  MomiaIOS
//
//  Created by Owen on 15/6/11.
//  Copyright (c) 2015年 Deng Jun. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeModel.h"
#import "HomeCarouselCell.h"
#import "HomeCell.h"

static NSString * homeIdentifier = @"CellHome";
static NSString * homeCarouselIdentifier = @"CellHomeCarousel";

@interface HomeViewController ()
@property (strong,nonatomic) HomeModel * model;

@property(nonatomic,strong) NSString * titleStr;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"哆啦";
    
    self.titleStr = @"上海";
    
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"TitleView" owner:self options:nil];
    UIView * titleView = array[0];
    __weak UILabel * label = (UILabel *)[titleView viewWithTag:2001];
    [label setText:self.titleStr];
    
    titleView.size = [titleView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTitleClick:)];
    [titleView addGestureRecognizer:tapRecognizer];
    
    UIBarButtonItem *cityItem = [[UIBarButtonItem alloc] initWithCustomView:titleView];
    if (isCurrentDeviceSystemVersionLater(7.0)) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, cityItem];
        
    } else {
        self.navigationItem.leftBarButtonItem = cityItem;
    }

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_search"] style:UIBarButtonItemStylePlain target:self action:@selector(onSearchClick)];
    
    
    [HomeCarouselCell registerCellWithTableView:self.tableView withIdentifier:homeCarouselIdentifier];
    [HomeCell registerCellWithTableView:self.tableView withIdentifier:homeIdentifier];
    
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.backgroundView.backgroundColor = UIColorFromRGB(0xf1f1f1);
    
    // 设置下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    
    self.tableView.width = SCREEN_WIDTH;
    
    [self requestData];
}

- (void)onCityChanged:(City *)newCity {
    [self requestData];
}

#pragma mark - webData Request

- (void)requestData {
    if (self.model == nil) {
        [self.view showLoadingBee];
    }
    
    NSDictionary * dic = @{@"pageindex":@0};
    [[HttpService defaultService] GET:URL_APPEND_PATH(@"/home") parameters:dic cacheType:CacheTypeDisable JSONModelClass:[HomeModel class] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (self.model == nil) {
            [self.view removeLoadingBee];
        }
        
        self.model = responseObject;
        
        [self.tableView reloadData];
        [self.tableView.header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (BOOL)isNavDarkStyle {
    return true;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * header = [UIView new];
    header.backgroundColor = MO_APP_VCBackgroundColor;
    return header;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.model) {
        return 1 + self.model.data.products.count;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) {
        if(self.model.data.banners.count > 0) {
            return 1;
        } else return 0;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if(section == 0) return [HomeCarouselCell heightWithTableView:tableView];
    
    return [HomeCell heightWithTableView:tableView withIdentifier:homeIdentifier forIndexPath:indexPath data:self.model.data.products[section - 1]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    UITableViewCell * cell;

    if(section == 0) {
        HomeCarouselCell * carousel = [HomeCarouselCell cellWithTableView:tableView forIndexPath:indexPath withIdentifier:homeCarouselIdentifier];
        carousel.data = self.model.data.banners;
        carousel.scrollClick = ^void(NSInteger index) {

        };
        cell = carousel;
        
    } else {
        HomeCell * home = [HomeCell cellWithTableView:tableView forIndexPath:indexPath withIdentifier:homeIdentifier];
        home.data = self.model.data.products[section - 1];
        
        cell = home;
    }
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if(section > 0) {
        ProductModel *product;
        product = self.model.data.products[indexPath.section - 1];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"duola://productdetail?id=%ld", product.pID]];
        
        [[UIApplication sharedApplication] openURL:url];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)onSearchClick
{
   

}

-(void)onTitleClick:(UITapGestureRecognizer *)recognizer
{
    [[CityManager shareManager]chooseCity:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
