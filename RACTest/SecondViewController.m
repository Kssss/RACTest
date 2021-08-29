//
//  SecondViewController.m
//  RACTest
//
//  Created by 谭建中 on 29/8/2021.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property(nonatomic, strong)UIButton *button;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
 }

- (void)buildUI {
    
    self.button.frame = CGRectMake(50, 100, 50, 30);
    self.view.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:self.button];
}

#pragma mark---lazy loading
- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        [_button setBackgroundColor:[UIColor grayColor]];
        [_button setTitle:@"pop" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
- (void)btnOnClick:(UIButton *)btn
{
    [self.subject sendNext:@"btnOnClick"];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
