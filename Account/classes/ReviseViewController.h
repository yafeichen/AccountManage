//
//  ReviseViewController.h
//  Account
//
//  Created by 陈亚飞 on 2017/7/19.
//  Copyright © 2017年 陈亚飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReviseViewControllerBlcok)(NSString *key, NSString *account2, NSString *password2);

@interface ReviseViewController : UIViewController

@property (nonatomic, copy) NSString                  *key;
@property (nonatomic, copy) NSString                  *account;
@property (nonatomic, copy) NSString                  *password;
@property (nonatomic, copy) ReviseViewControllerBlcok reviseViewController_block;

@end
