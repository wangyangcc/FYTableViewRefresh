//
//  FYViewController.m
//  FYTableViewRefresh
//
//  Created by wang yangyang on 14-3-25.
//  Copyright (c) 2014年 wang yangyang. All rights reserved.
//

#import "FYViewController.h"
#import "FYHeaderRefresh.h"

@interface FYViewController () {

    FYHeaderRefresh *refreshHeader;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation FYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    refreshHeader = [[FYHeaderRefresh alloc] init];
    //refreshHeader.backgroundColor = [UIColor lightGrayColor];
    [refreshHeader addTarget:self action:@selector(headerRefreshing) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshHeader];
    //[refreshHeader beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method

- (void)headerRefreshing
{
    [refreshHeader performSelector:@selector(endRefreshing) withObject:nil afterDelay:3];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [NSString stringWithFormat:@"%d---cell",indexPath.row];
    return cell;
}

@end
