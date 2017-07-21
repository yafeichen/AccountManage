//
//  ReviseViewController.m
//  Account
//
//  Created by 陈亚飞 on 2017/7/19.
//  Copyright © 2017年 陈亚飞. All rights reserved.
//

#import "ReviseViewController.h"

@interface ReviseViewController ()

@end

@implementation ReviseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改";
    self.view.backgroundColor = [UIColor whiteColor];
    [self layoutUI];
}

-(void)layoutUI
{
    for (int i=0; i<3; i++)
    {
        UILabel *titleLabel = [UILabel new];
        titleLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:titleLabel];
        titleLabel.frame = CGRectMake(20, 80+(20+20)*i, 80, 20);
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 80+(20+20)*i, 250, 30)];
        textField.font = [UIFont systemFontOfSize:15];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.tag = i+1;
        [self.view addSubview:textField];
        if (i==0)
        {
            titleLabel.text = @"关键词：";
            textField.text = self.key;
        }else if(i==1)
        {
            titleLabel.text = @"账号：";
            textField.text = self.account;
        }else
        {
            titleLabel.text = @"密码：";
            textField.text = self.password;
        }
    }
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:sureBtn];
    sureBtn.frame = CGRectMake(20, 220, self.view.frame.size.width-40, 30);
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureBtn setTitle:@"确定修改" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnCLick) forControlEvents:UIControlEventTouchUpInside];
}
-(void)sureBtnCLick
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:1];
    UITextField *textField2 = (UITextField *)[self.view viewWithTag:2];
    UITextField *textField3 = (UITextField *)[self.view viewWithTag:3];
    
    if (textField.text.length==0||textField2.text.length==0||textField3.text.length==0)
    {
        [self setAlertView];
        return;
    }
    self.reviseViewController_block(textField.text, textField2.text, textField3.text);
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setAlertView
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"你输入的信息不完全" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
