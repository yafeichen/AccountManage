//
//  ViewController.m
//  Account
//
//  Created by 陈亚飞 on 2017/6/22.
//  Copyright © 2017年 陈亚飞. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
#import "Define.h"
#import <iflyMSC/iflyMSC.h>
#import "ISRDataHelper.h"
#import "ReviseViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,IFlySpeechRecognizerDelegate>

@property (nonatomic, strong) UITableView               *accountTabelView;
@property (nonatomic, strong) NSMutableArray            *classArr;
@property (nonatomic, strong) NSMutableArray            *chooseStatusArr;
@property (nonatomic, strong) NSMutableDictionary       *plistDic;
@property (nonatomic, strong) NSArray                   *plistAllKeysArr;
@property (nonatomic, copy)   NSString                  *currentStr;
@property (nonatomic, copy)   NSString                  *answerStr;
@property (nonatomic, copy)   NSString                  *questionStr;
@property (nonatomic, strong) IFlySpeechRecognizer      *iFlySpeechRecognizer;
@property (nonatomic, strong) NSMutableString           *curResult;//the results of current session
@property (nonatomic, strong) UILabel                   *resultLabel;

@end

@implementation ViewController


/**
 初始化tableview
 
 @return 返回tableview
 */
-(UITableView *)accountTabelView
{
    if (!_accountTabelView)
    {
        _accountTabelView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        [self.view addSubview:_accountTabelView];
        _accountTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _accountTabelView;
}

/**
 初始化承载账号类型的数组 （常用，私密）
 
 @return 返回数组
 */
-(NSMutableArray *)classArr
{
    if (!_classArr)
    {
        _classArr = [[NSMutableArray alloc] initWithObjects:@"常用",@"私密", nil];
    }
    return _classArr;
}

/**
 初始化承载选在状态的数组
 
 @return 返回数组
 */
-(NSMutableArray *)chooseStatusArr
{
    if (!_chooseStatusArr)
    {
        _chooseStatusArr = [NSMutableArray new];
    }
    return _chooseStatusArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"账号管理";
    UIBarButtonItem *addBarBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBtnClick)];
    self.navigationItem.rightBarButtonItem = addBarBtnItem;
    
    for (int i=0; i<self.classArr.count; i++)
    {
        NSString *chooes = @"0";
        [self.chooseStatusArr addObject:chooes];
    }
    self.accountTabelView.delegate = self;
    self.accountTabelView.dataSource = self;
    [self getAccountData];
    
    UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.titleLabel.font = SetTextFont(15);
    [voiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [voiceBtn setTitle:@"语音输入" forState:UIControlStateNormal];
    [self.view addSubview:voiceBtn];
    MASONRY_B_L_R_H(voiceBtn, self.view, self.view, self.view, 20, 0, 0, 30);
    [voiceBtn addTarget:self action:@selector(voiceBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    _resultLabel = [UILabel new];
    _resultLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_resultLabel];
    MASONRY_B_L_R_H(_resultLabel, voiceBtn.mas_top, self.view, self.view, 10, 0, 0, 17);
}


/**
 语音输入按钮绑定的方法
 */
-(void)voiceBtnClick
{
    //创建语音识别对象
    _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    _iFlySpeechRecognizer.delegate = self;
    //设置识别参数
    //设置为听写模式
    [_iFlySpeechRecognizer setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
    //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
    [_iFlySpeechRecognizer setParameter:@"iat.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    //启动识别服务
    [_iFlySpeechRecognizer startListening];
//    [_iFlySpeechRecognizer ];

}


/**
 获取本地存储的账号数据
 */
-(void)getAccountData
{
    NSString *fileName = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.plist"];
    self.plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:fileName];
    if (self.plistDic.count==0)
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Account" ofType:@"plist"];
        self.plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    }
    self.plistAllKeysArr = [self.plistDic allKeys];
}

/**
 将账号数据写入本地
 */
-(void)dataWriteToDocuments
{
    NSString *fileName = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/data.plist"];
    [self.plistDic writeToFile:fileName atomically:YES];
    [self getAccountData];
    [self.accountTabelView reloadData];
}

/**
 添加账号按钮的执行时间
 */
-(void)addBtnClick
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"添加分组" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setAlertView:@"添加分组"];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 创建添加账号密码的alert
 
 @param add alert类型
 */
-(void)setAlertView:(NSString *)add
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:add style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *accountDic = [NSMutableDictionary new];
        [accountDic setObject:[[alertController.textFields objectAtIndex:2] text]forKey:[[alertController.textFields objectAtIndex:1] text]];
        NSMutableDictionary *dic = [self.plistDic objectForKey:_currentStr];
        [dic setObject:accountDic forKey:[[alertController.textFields objectAtIndex:0] text]];
        [self.plistDic setObject:dic forKey:_currentStr];
        [self dataWriteToDocuments];
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"为该账号添加标题";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"账号";
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"密码";
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
    /**
     设置显示账号密码的alert
     
     @return
     */
}
-(void)setShowAccountAndSecritAlert:(NSString *)account secritStr:(NSString *)secrit accountTitle:(NSString *)title
{
    UIAlertController *accountAlert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [accountAlert addAction:[UIAlertAction actionWithTitle:@"账号密码在此" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [accountAlert addAction:[UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ReviseViewController *reviseVC = [[ReviseViewController alloc] init];
        reviseVC.key = title;
        reviseVC.account = account;
        reviseVC.password = secrit;
        reviseVC.reviseViewController_block = ^(NSString *key, NSString *account2, NSString *password2) {
            NSLog(@"%@",self.plistDic);
            [[self.plistDic objectForKey:_currentStr] removeObjectForKey:title];
            NSMutableDictionary *accountDic = [NSMutableDictionary new];
            [accountDic setObject:password2 forKey:account2];
            NSMutableDictionary *dic = [self.plistDic objectForKey:_currentStr];
            [dic setObject:accountDic forKey:key];
            [self.plistDic setObject:dic forKey:_currentStr];
            [self dataWriteToDocuments];
        };
        [self.navigationController pushViewController:reviseVC animated:YES];
    }]];
    [accountAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [NSString stringWithFormat:@"账号为：%@",account];
        textField.userInteractionEnabled = NO;
    }];
    [accountAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [NSString stringWithFormat:@"密码为：%@",secrit];
        textField.userInteractionEnabled = NO;
    }];
    [self presentViewController:accountAlert animated:YES completion:nil];
}
-(void)setQuestionAlert
{
    UIAlertController *questionAlert = [UIAlertController alertControllerWithTitle:@"添加密保问题" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [questionAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.answerStr = [[[questionAlert textFields] objectAtIndex:1] text];
        self.questionStr = [[[questionAlert textFields] objectAtIndex:0] text];
        BOOL  right = self.answerStr.length>0&&self.questionStr.length>0?YES:NO;
        if (right)
        {
            [UserDefaults setObject:self.answerStr forKey:@"answer"];
            [UserDefaults setObject:self.questionStr forKey:@"question"];
            [UserDefaults synchronize];
        }else
        {
            kHUDNormal(@"您输入的问题不全，请重新输入");
        }
        
    }]];
    [questionAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if ([[UserDefaults objectForKey:@"question"] length]>0)
        {
            textField.placeholder = [UserDefaults objectForKey:@"question"];
        }else
        {
            textField.placeholder = @"请输入问题";
        }
        
    }];
    [questionAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入答案";
    }];
    [self presentViewController:questionAlert animated:YES completion:nil];
}
/**
 展开或闭合分组按钮的方法
 
 @param sender 按钮
 */
-(void)sectionBtnClick:(UIButton *)sender
{
    if (sender.tag==2)
    {
        [self setQuestionAlert];
    }
    NSArray *childClassArr = [[self.plistDic objectForKey:[self.classArr objectAtIndex:sender.tag-1]] allKeys];
    if ([childClassArr count]==0)
    {
        kHUDNormal(@"你还没有在此添加账号密码");
        return;
    }
    NSString *chooes = [self.chooseStatusArr objectAtIndex:sender.tag-1];
    _currentStr = [self.plistAllKeysArr objectAtIndex:sender.tag-1];
    if (chooes.intValue==0)
    {
        chooes = @"1";
    }else
    {
        chooes = @"0";
    }
    [self.chooseStatusArr removeObjectAtIndex:sender.tag-1];
    [self.chooseStatusArr insertObject:chooes atIndex:sender.tag-1];
    [self.accountTabelView reloadData];
}

/**
 添加账号按钮方法
 
 @param sender 按钮
 */
-(void)addAccountBtnClick:(UIButton *)sender
{
    _currentStr = [self.plistAllKeysArr objectAtIndex:sender.tag-100];
    [self setAlertView:@"添加账号"];
}

#pragma mark
#pragma mark tableviewDelegate
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [UIView new];
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"    %@",[self.classArr objectAtIndex:section]];
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).with.offset(0);
        make.right.equalTo(headerView).with.offset(0);
        make.bottom.equalTo(headerView).with.offset(0);
        make.left.equalTo(headerView).with.offset(0);
    }];
    UIButton *btn = [UIButton new];
    btn.tag = section+1;
    btn.selected = NO;
    [headerView addSubview:btn];
    [btn addTarget:self action:@selector(sectionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).with.offset(0);
        make.right.equalTo(headerView).with.offset(-50);
        make.bottom.equalTo(headerView).with.offset(0);
        make.left.equalTo(headerView).with.offset(0);
    }];
    UIButton *addAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addAccountBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    addAccountBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [addAccountBtn setTitle:@"添加账号" forState:UIControlStateNormal];
    addAccountBtn.tag = 100+section;
    [addAccountBtn addTarget:self action:@selector(addAccountBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:addAccountBtn];
    [addAccountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).with.offset(0);
        make.right.equalTo(headerView).with.offset(0);
        make.bottom.equalTo(headerView).with.offset(0);
        make.left.equalTo(btn.mas_right).with.offset(0);
    }];
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor grayColor];
    [headerView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).with.offset(0);
        make.right.equalTo(headerView).with.offset(0);
        make.bottom.equalTo(headerView).with.offset(0);
        make.height.mas_offset(1);
    }];
    return headerView;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.classArr.count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.classArr objectAtIndex:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.chooseStatusArr objectAtIndex:section] intValue]==0)
    {
        return 0;
    }else
    {
        return [[self.plistDic objectForKey:[self.classArr objectAtIndex:section]] count];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"accountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureMethod:)];
        longPressGesture.minimumPressDuration = 2;
        [cell addGestureRecognizer:longPressGesture];
    }
    cell.textLabel.text = [[[self.plistDic objectForKey:[self.classArr objectAtIndex:indexPath.section]] allKeys] objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *childClassArr = [[self.plistDic objectForKey:[self.classArr objectAtIndex:indexPath.section]] allKeys];
    NSString *account = [[[[self.plistDic objectForKey:[self.classArr objectAtIndex:indexPath.section]] objectForKey:[childClassArr objectAtIndex:indexPath.row]] allKeys] firstObject];
    NSString *secrit = [[[self.plistDic objectForKey:[self.classArr objectAtIndex:indexPath.section]] objectForKey:[childClassArr objectAtIndex:indexPath.row]] objectForKey:account];
    NSString *title = [[[self.plistDic objectForKey:[self.classArr objectAtIndex:indexPath.section]] allKeys] objectAtIndex:indexPath.row];
    [self setShowAccountAndSecritAlert:account secritStr:secrit accountTitle:title];
    
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)longPressGestureMethod:(UILongPressGestureRecognizer *)longPre
{
    if (longPre.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [longPre locationInView:self.accountTabelView];
        NSIndexPath *indexPath = [self.accountTabelView indexPathForRowAtPoint:point];
        NSLog(@"%ld,%ld",indexPath.row,indexPath.section);
    }
}
#pragma mark
#pragma mark 讯飞delegate
-(void)onResults:(NSArray *)results isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSDictionary *dic = results[0];
    NSLog(@"%@",dic);
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
        NSString * resultFromJson =  [ISRDataHelper stringFromABNFJson:result];
        [resultString appendString:resultFromJson];
    }
    _resultLabel.text = resultString;
    NSLog(@"%@",resultString);
    if (isLast) {
        NSLog(@"result is:%@",self.curResult);
        _resultLabel.text = self.curResult;
    }
    [self.curResult appendString:resultString];
    NSLog(@"%@",self.curResult);
}
- (void)onError: (IFlySpeechError *) error
{
    NSLog(@"%@",error);
}

-(void) onEndOfSpeech
{
    NSLog(@"dfsdf");
}

-(void)onBeginOfSpeech
{
    NSLog(@"开始说话");
}

-(void)onVolumeChanged:(int)volume
{
    NSLog(@"音量为%d",volume);
}

-(void)onCancel
{
    NSLog(@"取消");
}

@end
