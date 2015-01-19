//
//  ViewController.m
//  BLOCK_DEMO
//
//  Created by jamalping on 15-1-19.
//  Copyright (c) 2015年 jamalping. All rights reserved.
//


#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)dealloc
{
    NSLog(@"no retain cycle");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /* 
     * NSGlobalBlock：类似函数，位于text段；
     * NSStackBlock：位于栈内存，函数返回后Block将无效；
     * NSMallocBlock：位于堆内存。
     */
//    1、NSGlobalBlock如下，我们可以通过是否引用外部变量识别，未引用外部变量即为NSGlobalBlock，可以当做函数使用。
    float (^sum)(float,float) = ^(float a,float b){
        return a+b;
    };
    
//    float aa = ^(1,2);
    NSLog(@"sum is %@",sum);
    
//    2、NSStackBlock如下：
    NSArray *testAry = @[@1,@2];
    void(^ TestBlock)(void) = ^{
        NSLog(@"testAry %@",testAry);
    };
    NSLog(@"block is %@",TestBlock);
    //上面这句在非arc中打印是 NSStackBlock, 但是在arc中就是NSMallocBlock
    //即在arc中默认会将block从栈复制到堆上，而在非arc中，则需要手动copy.
    
    /*
     Block对外部变量的存取管理
     */
//    1、局部变量（在block中只读，block定义时copy变量的值）
//    局部自动变量，在Block中只读。Block定义时copy变量的值，在Block中作为常量使用，所以即使变量的值在Block外改变，也不影响他在Block中的值。
    int base = 101;
    long (^add)(float,float) = ^long(float a, float b){
        return base+a+b;
    };
    base = 0; // 改变base的值
    printf("局部变量test%lu",add(1,2)); // 输出104
    NSLog(@"%@",add);
    
//    2、STATIC修饰符的全局变量
//    因为全局变量或静态变量在内存中的地址是固定的，Block在读取该变量值的时候是直接从其所在内存读出，获取到的是最新值，而不是在定义时copy的常量.
    static int base1 = 100;
    long (^add1)(int, int) = ^ long (int a, int b) {
        base1++;
        return base1 + a + b;
    };
    
    base1 = 3;
    printf("%ld\n",add1(1,2));
    NSLog(@"%@",add1);
    // 这里输出是4，而不是104, 因为base被设置为了0
    printf("%d\n", base1);
    // 这里输出1， 因为sum中将base++了
    
//    3、__BLOCK修饰的变量 （等同全局变量活静态变量）
//    Block变量，被__block修饰的变量称作Block变量。 基本类型的Block变量等效于全局变量、或静态变量。
//    注：BLOCK被另一个BLOCK使用时，另一个BLOCK被COPY到堆上时，被使用的BLOCK也会被COPY。但作为参数的BLOCK是不会发生COPY的
    
    /*OBJC对象的测试*/
//    由于ARC中没有reetain，retainCount的概念，只有强引用，弱引用的概念，当一个变量没有__Strong的指针指向它时，他就会被系统释放。
    // global全局变量
    // 没被修饰的变量被block捕获时是获取的变量的值
    UILabel *label = [[UILabel alloc] init];
    void (^TestBlock1)(void) = ^{
        NSLog(@"global OBJC %@",label);
    };
    label = nil;
    TestBlock1();
    NSLog(@"global test %@",TestBlock1);
    
    // __block 修饰的变量被block捕获时是获取的变量的指针（引用指针）
//    __block NSString *_globalStr = @"1";
    __block UILabel *label1 = [[UILabel alloc] init];
    void (^TestBlock2)(void) = ^{
        NSLog(@"_global OBJC%@",label1);
    };
    label1 = nil;
    TestBlock2();
    NSLog(@"_global test %@",TestBlock2);
    
    
    // __weak修饰的被block捕获时是拷贝了copy了一次指针，
    UILabel *ss = [[UILabel alloc] init];
    __weak UILabel *label2 = ss;
    printf("weak address: %p\n", &label2);  //weak address: 0xbfffd9c4
    printf("weak str address: %p\n", label2); //weak str address: 0x684c
    
    void (^TestBlock3)(void) = ^{
        
        printf("weak address: %p\n", &label2); //weak address: 0x7144324
        printf("weak str address: %p\n", label2); //weak str address: 0x684c
        
        NSLog(@"string is : %@", label2); //string is :1
    };
    label2 = nil;
    TestBlock3();
    
    /*
     循环引用 retain cycle
     */
//    这里讲的是block的循环引用问题，因为block在拷贝到堆上的时候，会retain其引用的外部变量，那么如果block中如果引用了他的宿主对象，那很有可能引起循环引用
    // 会循环引用
    self.myBlock = ^{
        [self doSomething];
    };
    
    //会循环引用
    __block ViewController *weakSelf = self;
    self.myBlock = ^{
        [weakSelf doSomething];
    };
    
    //不会循环引用
    __weak ViewController *weakSelf1 = self;
    self.myBlock = ^{
        [weakSelf1 doSomething];
    };
    
    //不会循环引用
    __unsafe_unretained ViewController *weakSelf2 = self;
    self.myBlock = ^{
        [weakSelf2 doSomething];
    };
    
    NSLog(@"myblock is %@", self.myBlock);
//    经过上面的测试发现，在加了__weak和__unsafe_unretained的变量引入后，TestCycleRetain方法可以正常执行dealloc方法，而不转换和用__block转换的变量都会引起循环引用。
}

- (void)doSomething {
    NSLog(@"do Something");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
