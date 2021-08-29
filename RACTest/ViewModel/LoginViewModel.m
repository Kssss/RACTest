//
//  LoginViewModel.m
//  RACTest
//
//  Created by 谭建中 on 29/8/2021.
//

#import "LoginViewModel.h"
@interface LoginViewModel ()
@property (nonatomic, strong) RACCommand * loginCommand;

@end
@implementation LoginViewModel
 
- (instancetype)init
{
    if (self = [super init]){
        [self setup];
    }
    return self;
}

- (void)setup{
 
    
    _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary *  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [[AFHTTPSessionManager manager] GET:@"http://poetry.apiopen.top/sentences" parameters:input progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
                if([responseObject[@"code"] integerValue] == 200){
                    [subscriber sendNext:responseObject[@"result"]];
                }else{
                    [subscriber sendError:[NSError new]];
                }
                [subscriber sendCompleted];
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 [subscriber sendError:error];
                 [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    _loginCommand.allowsConcurrentExecution = YES;
}
@end
