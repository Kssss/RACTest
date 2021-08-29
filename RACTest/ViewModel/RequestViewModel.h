//
//  RequestViewModel.h
//  RACTest
//
//  Created by 谭建中 on 29/8/2021.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>
#import "AFNetworking.h"
NS_ASSUME_NONNULL_BEGIN

@interface RequestViewModel : NSObject
@property (nonatomic, strong,readonly) RACCommand * requestCommand;

@end

NS_ASSUME_NONNULL_END
