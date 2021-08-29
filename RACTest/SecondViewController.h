//
//  SecondViewController.h
//  RACTest
//
//  Created by 谭建中 on 29/8/2021.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC.h>
NS_ASSUME_NONNULL_BEGIN

@interface SecondViewController : UIViewController
@property(nonatomic, strong) RACSubject *subject;

@end

NS_ASSUME_NONNULL_END
