//
//  JGProgressHUDSuccessIndicatorView.m
//  JGProgressHUD
//
//  Created by Jonas Gessner on 19.08.14.
//  Copyright (c) 2014 Jonas Gessner. All rights reserved.
//

#import "JGProgressHUDGifIndicatorView.h"
#import "YLGIFImage.h"
#import "YLImageView.h"

@implementation JGProgressHUDGifIndicatorView

- (instancetype)initWithContentView:(UIView * __unused)contentView {    
    YLImageView* imageView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    //[self.view addSubview:imageView];
    imageView.image = [YLGIFImage imageNamed:@"preloader3.gif"];
    
    self = [super initWithContentView:imageView];
    return self;
}

- (instancetype)init {
    return [self initWithContentView:nil];
}

@end
