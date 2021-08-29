//
//  LoginViewModel2.h
//  RACTest
//
//  Created by 谭建中 on 29/8/2021.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>
#import "AFNetworking.h"
NS_ASSUME_NONNULL_BEGIN
/*
 VM 处理业务逻辑，最好不要包含视图
 M <-----> V <----> VM
 每一个控制器，对应一个 vm
 M和V的处理是在控制器
 业务逻辑处理在VM
 控制器是中枢
*/
@interface LoginViewModel2 : NSObject
@property (nonatomic, copy) NSString * pwd;
@property (nonatomic, copy) NSString * userName;
///按钮点击的信号
@property (nonatomic, strong) RACSignal * loginBtnEnableSignal;
///执行登录的命令
@property (nonatomic, strong,readonly) RACCommand * loginCommand;

@end

NS_ASSUME_NONNULL_END
