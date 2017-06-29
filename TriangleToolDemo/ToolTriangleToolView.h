//
//  TriangleToolView.h
//  testWKWebView
//
//  Created by jianglihui on 2017/3/24.
//  Copyright © 2017年 jianglihui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToolTriangleToolView;

@protocol ToolTriangleDelegate <NSObject>

- (void)setDisplay:(ToolTriangleToolView *)view;

@end

@interface ToolTriangleToolView : UIView

@property (nonatomic, strong)   NSMutableDictionary *lineDic;
@property (nonatomic, assign)  int angle;
@property (assign)    BOOL isOscelesTrianle;

@property (weak)    id<ToolTriangleDelegate> delegate;

@property (strong)  NSDictionary *infoDir;

- (CGFloat)getAngleScale;

@end
