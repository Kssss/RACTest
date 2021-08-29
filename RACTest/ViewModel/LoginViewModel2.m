//
//  LoginViewModel2.m
//  RACTest
//
//  Created by 谭建中 on 29/8/2021.
//

#import "LoginViewModel2.h"
@interface LoginViewModel2 ()
@property (nonatomic, strong) RACCommand * loginCommand;

@end
@implementation LoginViewModel2
- (instancetype)init
{
    if (self = [super init]){
        [self setup];
    }
    return self;
}

- (void)setup{
    _loginBtnEnableSignal = [RACSignal combineLatest:@[RACObserve(self, pwd),RACObserve(self, userName)] reduce:^id (NSString *pwd,NSString *name){
        return @(pwd.length && name.length);
    }];
    
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"正在网络请求");
            [[AFHTTPSessionManager manager] GET:@"http://poetry.apiopen.top/sentences" parameters:input progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"网络请求完成");
                if([responseObject[@"code"] integerValue] == 200){
                    [subscriber sendNext:responseObject[@"result"]];
                }else{
                    [subscriber sendNext:nil];
                }
                [subscriber sendCompleted];
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 [subscriber sendNext:nil];
                 [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    _loginCommand.allowsConcurrentExecution = YES;
}
@end
