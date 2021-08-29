//
//  RequestViewModel.m
//  RACTest
//
//  Created by 谭建中 on 29/8/2021.
//

#import "RequestViewModel.h"

@interface RequestViewModel()
@property (nonatomic, strong) RACCommand * requestCommand;
@end

@implementation RequestViewModel
- (instancetype)init
{
    if (self = [super init]){
        [self setup];
    }
    return self;
}

- (void)setup
{
    _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [[AFHTTPSessionManager manager] GET:@"http://poetry.apiopen.top/sentences" parameters:@{} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
                if([responseObject[@"code"] integerValue] == 200){
                    [subscriber sendNext:responseObject[@"result"]];
                }else{
                    [subscriber sendError:[NSError new]];
                }
 
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 [subscriber sendError:error];
            }];
 
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"释放了");
            }];;
        }];
        
    }];
    //允许多次执行
    _requestCommand.allowsConcurrentExecution = YES;
}

@end
