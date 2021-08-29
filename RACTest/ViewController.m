//
//  ViewController.m
//  RACTest
//
//  Created by 谭建中 on 28/8/2021.
//
#import "SecondViewController.h"
#import "ViewController.h"
#import <ReactiveObjC.h>
#import "RACReturnSignal.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (weak, nonatomic) IBOutlet UITextField *textFiled2;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (nonatomic, strong) RACSignal *signal;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RAC练习";
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self switchToLatest];
}
#pragma mark - RACCommand
- (void)commandTest1{
    //1、创建command命令
    RACCommand * requesePageListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        //3、接收到参数，执行网络请求
        NSLog(@"请求的参数=%@",input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"网络请求");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSLog(@"网络请求得到数据");
                    NSArray * array = @[@1,@2,@3,@4,@5];
                    NSLog(@"发送数据array = %@",array);
                    [subscriber sendNext:array];
//                    [subscriber sendCompleted];
                });
            });
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"释放信号");
            }];;
        }];
    }];
    //2、 执行命令，并携带参数 @{}
    RACSignal *signal = [requesePageListCommand execute:@{@"page":@1,@"Num":@10}];
    // RACReplaySubject 订阅信号，这个信号 先发信号后订阅的。不同于 RACSubject
    
    //4、订阅到消息
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@" 得到最终数据 = %@",x);
    } completed:^{
        NSLog(@"请求完成");
    }];
    
    //5、关闭订阅
    
}
- (void)commandTest2{   //创建命令
    RACCommand * command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"input = %@",input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [subscriber sendNext:@100];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    //executionSignals：信号源。 订阅信号
    [command.executionSignals subscribeNext:^(RACSignal *  _Nullable x) {
        [x subscribeNext:^(id  _Nullable x) {
            NSLog(@"收到的数据 = %@",x);
        }];
    }];
    //执行命令
    [command execute:@1];
}
- (void)commandTest3{
    //1、开始命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"input = %@",input);
        return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@[@1,@2,@3,@4,@5]];
            
            return [RACDisposable disposableWithBlock:^{
                    
            }];
        }];
    }];
    //2、监听命令是否完成
    [command.executing subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"收到x = %@",x);
        if ([x intValue] == 0) {
            NSLog(@"正在执行");
        }else{
            NSLog(@"执行完成");
        }
    }];
    //3、执行
    [command execute:@2];
}
- (void)commandTest4{
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"input = %@",input);
        return  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            if ([input intValue] == 0) {
                [subscriber sendNext:@[@10,@20,@30,@40,@50]];
            }else{
                [subscriber sendNext:@[@1,@2,@3,@4,@5]];
            }
            
            return [RACDisposable disposableWithBlock:^{
                    
            }];
        }];
    }];
    // switchToLatest获取最新发送的信号，只能用于信号中信号。
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
  
    [command execute:@0];
    [command execute:@1];
}
- (void)switchToLatest{
    RACSubject *subjectA = [RACSubject subject];
    RACSubject *subjectB = [RACSubject subject];
     
    //获取信号中的信号 subjectB，然后订阅
//    [subjectA subscribeNext:^(RACSignal *  _Nullable x) {
//        NSLog(@"%@",x);
//        [x subscribeNext:^(id  _Nullable x) {
//            NSLog(@"x = %@",x);
//        }];
//    }];
    //取代上面冗余
    [subjectA.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"收到---<%@>",x);
    }];
    

    //发送信号B
    [subjectA sendNext:subjectB];
    //信号B 发送 信号
    [subjectB sendNext:@"B send- 100"];
}
#pragma mark - RACMulticastConnection
- (void)racMulticastConnection{
    //较 直接使用 RACSignal可以减少多次发送信号block
    RACSignal * signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送信号");
        [subscriber sendNext:@"来之网络请求的数据Data"];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"释放了信号");
        }];;
    }];
    
    RACMulticastConnection * multecast = [signal publish];
    [multecast.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"A---- %@",x);
    }];
    
    [multecast.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"B---- %@",x);
    }];
    
    [multecast.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"C---- %@",x);
    }];
    [multecast.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"D---- %@",x);
    }];
    [multecast connect];

}
#pragma mark - RACSignal
/// 创建信号-----订阅信号-----发送信号------取消信号
- (void)racSignal{
    //1创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       //3发送信号
        NSLog(@"发送了信号");
        [subscriber sendNext:@"111111"];
//        [subscriber sendCompleted]; //这也可以取消订阅
        void(^block)(void) = ^(void) {
            NSLog(@"释放了信号");
        };
        return [RACDisposable disposableWithBlock:block];
    }];
    
    //2订阅消息
    RACDisposable *disposable = [signal subscribeNext:^(id  _Nullable x) {
        // 4、接收到信号
        NSLog(@"A收到了%@",x);
    }];
    RACDisposable *disposable2 = [signal subscribeNext:^(id  _Nullable x) {
        // 4、接收到信号
        NSLog(@"B收到了%@",x);
    }];
    //5、取消订阅
    [disposable dispose];
    [disposable2 dispose];
}
#pragma mark - 应用场景
- (void)racSequenceArray{
    // 使用场景---： 可以快速高效的遍历数组和字典。
    NSArray *array = @[@1,@2,@3,@4,@5,@6];
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    } completed:^{
        NSLog(@"ok---完毕");
    }];
    
}
- (void)racSequenceDic{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info.plist" ofType:nil];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack_(NSString *key,NSString * value) = x;
        NSLog(@"%@:%@",key,value);
    } completed:^{
        NSLog(@"-----ok---完毕");
    }];
    
}
- (void)pushVC{
    /*控制器之间传值，可以取代通知和代理的功能*/
    UIButton *btn = [[UIButton alloc] init];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"push" forState:UIControlStateNormal];
    btn.frame = CGRectMake(100, 100, 80, 30);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)clickBtn:(UIButton *)btn{
    SecondViewController *sevc = [[SecondViewController alloc] init];
    sevc.subject = [RACSubject subject];
    [sevc.subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"来之第二个控制器的消息%@",x);
    }];
    
    [self.navigationController pushViewController:sevc animated:YES];
}
#pragma mark - RAC宏
- (void)racTuple{
    //打包
    RACTuple *tuple = RACTuplePack(@1,@2,@3);
    NSLog(@"%@---%@---%@",tuple.first,tuple.second,tuple.third);
    //解包
    RACTupleUnpack_(NSNumber *num1,NSNumber *num2,NSNumber *num3) = tuple;
    NSLog(@"%@---%@---%@",num1,num2,num3);
}
- (void)weakify{
    @weakify(self)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       @strongify(self)
        NSLog(@"%@",self.view);
        [subscriber sendNext:@"aaaaaa"];
        return nil;
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
        
    _signal = signal;
}
- (void)rac{
    RAC(self.textFiled2,text) = self.textFiled.rac_textSignal;
}
- (void)racObserve{
    /**
     *  KVO
     *  RACObserve :快速的监听某个对象的某个属性改变
     *  返回的是一个信号,对象的某个属性改变的信号
     */
    [RACObserve(self.view, alpha) subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    self.view.alpha = 0.4;
}
#pragma mark - Bind
// 信号 A----> bindB 处理 ----->C
- (void)bind{
    RACSubject *subject = [RACSubject subject];
//    typedef RACSignal * _Nullable (^RACSignalBindBlock)(ValueType _Nullable value, BOOL *stop);
//     返回是要是一个信号，并且带两个参数：一个value，一个bool
    RACSignal *bindSignal = [subject bind:^RACSignalBindBlock _Nonnull {
        return ^RACSignal *(id value, BOOL *stop){
            // 一般在这个block中做事 ，发数据的时候会来到这个block。
            // 只要源信号（subject）发送数据，就会调用block
            // block作用：处理源信号内容
            // value:源信号发送的内容，
             NSLog(@"接受到源信号的内容：%@", value);
            //返回信号，不能为nil,如果非要返回空---则empty或 alloc init。
        return [RACReturnSignal return:value]; // 把返回的值包装成信号
        };
    }];
    
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"最终的数据 = %@",x);
    }];
    
    [subject sendNext:@"aaaaaa"];
    
}
#pragma mark - 组合
//信号串行队列。 (数据流  A ----------> C----->  B--------> C； B 依赖 A 完成)
- (void)concat{
    RACSignal * sigA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"发送上半部分的请求-----data");
            [subscriber sendNext:@"data"];
            [subscriber sendCompleted];
        });
        return nil;
    }];
    
    RACSignal * sigB =  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"发送下半部分的请求-----data2");
            [subscriber sendNext:@"data2"];
        });
        return nil;
    }];
    
    /// 创建一个then信号
    RACSignal * concatSignal = [sigA concat:sigB];
    
    [concatSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"最终的结果%@",x);
    }];
    
}
///完成一部分再完成另一个部分才能 处理then信号,忽略sigB完成之前的信号。  (数据流 向 A ---------->   B-------->  C；)
- (void)then{
    RACSignal * sigA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"发送上半部分的请求-----data");
            [subscriber sendNext:@"data"];
            [subscriber sendCompleted];
        });
        return nil;
    }];
    
    RACSignal * sigB =  [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"发送下半部分的请求-----data2");
            [subscriber sendNext:@"data2"];
        });
        return nil;
    }];
    
//    [sigA subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
//
//    [sigB subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
    /// 创建一个then信号
    RACSignal * thenSignal = [sigA then:^RACSignal * _Nonnull{
        return sigB;
    }];
    
    [thenSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"最终的结果%@",x);
    }];
    
}
///多个信号合成一个信号，无论哪个信号有next 都会触发调用  （A || B || C --> D）
- (void)merge{
    RACSubject *subjectA = [RACSubject subject];
    RACSubject *subjectB = [RACSubject subject];
    RACSubject *subjectC = [RACSubject subject];
    RACSignal * merge = [[subjectA merge:subjectB] merge:subjectC];
    [merge subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subjectA sendNext:@2];
    [subjectB sendNext:@"222"];
    [subjectC sendNext:@"c"];
}
///把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元祖，才会触发压缩流的next事件。（ A && B -> C）
- (void)zipWith{
    RACSubject *subjectA = [RACSubject subject];
    RACSubject *subjectB = [RACSubject subject];
    RACSignal *zipSignal = [subjectA zipWith:subjectB];
    [zipSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subjectA sendNext:@2];
    [subjectB sendNext:@3];
}
///信号组合在一起成为一个新的信号  （可以或可以与）
- (void)combineLatest{
    RACSignal * combinSignal = [RACSignal combineLatest:@[self.textFiled.rac_textSignal,self.textFiled2.rac_textSignal] reduce:^id (NSString * text1,NSString * text2){
        NSLog(@"%@---%@",text1,text2);
        return @(text1.length > 5 && text2.length > 5);
    }];
    
//    [combinSignal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"长度都大于5了-----%@",x);
//        self.submitBtn.enabled = [x boolValue];
//    }];
    
    RAC(self.submitBtn, enabled) = combinSignal;
}
#pragma  mark - 过滤
/// 给文本输入框增加过滤条件
- (void)filter{
    [[self.textFiled.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
            return value.length > 5;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"某个按钮被激活--%@",x);
    }];
//    [self.textFiled.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
//        NSLog(@"%@",x);
//    }];
}
///忽略值
- (void)ignore{
    RACSubject *subject = [RACSubject subject];
    
    [[subject ignore:@2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    
}
/// 接受信号直到信号完成或者某个信号发送了信号
- (void)takeUntil{
    RACSubject *subject = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject takeUntil:subject2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject2 sendNext:@"333"];
    [subject sendNext:@4];
  
}
/// takeLast最后几个信号
- (void)takeLast{
    RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendNext:@4];
    // 发送完成 要记得！
    [subject sendCompleted];
}
/// take 前几个信号
- (void)take {
    RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendNext:@4];
}
/// 接受值改变了的信号
- (void)distinctuntilChanged{
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
    
}
///跳过N个信号
- (void)skip{
    RACSubject *subject = [RACSubject subject];
    [[subject skip:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    [subject sendNext:@"3"];
    [subject sendNext:@"4"];
}
#pragma mark - 信号绑定 映射？
///信号绑定 3
- (void)testFlattenMap2{
    RACSubject *signalofSignals = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];

    RACSignal * bindSignal = [signalofSignals flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return value;
    }];
    
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [signalofSignals sendNext:subject2];
    [subject2 sendNext:@"abc"];
}
///信号绑定2
- (void)testFlattenMap{
    RACSubject *subject = [RACSubject subject];
    RACSignal * bindSignal = [subject flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        value = [NSString stringWithFormat:@"flattenMap: %@",value];
        return [RACReturnSignal return:value];
    }];
    
    [bindSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"abc"];
}
///信号绑定1
- (void)testMap{
    RACSubject * subject = [RACSubject subject];
    
    RACSignal *bindsingal = [subject map:^id _Nullable(id  _Nullable value) {
       
        return [NSString stringWithFormat:@"ws: %@",value];
    }];
    
    [bindsingal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    } completed:^{
        
    }];
    
//    [subject subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
    
    
    [subject sendNext:@"2323"];
}
@end
