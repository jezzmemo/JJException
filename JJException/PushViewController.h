//
//  PushViewController.h
//  JJException
//
//  Created by Jezz on 2018/9/2.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KVOObjectDemo.h"

@interface PushViewController : UIViewController

@property(nonatomic,readwrite,weak)KVOObjectDemo* kvoObject;
@property(nonatomic,readwrite,weak)KVOObjectDemo* kvoObject2;

@end
