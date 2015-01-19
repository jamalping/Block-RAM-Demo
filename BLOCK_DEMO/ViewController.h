//
//  ViewController.h
//  BLOCK_DEMO
//
//  Created by jamalping on 15-1-19.
//  Copyright (c) 2015年 jamalping. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^Myblock)(void);

@interface ViewController : UIViewController

@property (nonatomic,copy)Myblock myBlock;

@end

