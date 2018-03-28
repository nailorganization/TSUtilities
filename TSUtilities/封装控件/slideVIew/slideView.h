//
//  slideView.h
//  ZTExchange
//
//  Created by suofei on 2018/3/28.
//  Copyright © 2018年 ZT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface slideView : UIView

@property (nonatomic, assign)CGFloat progress;
// 设置圆点半径。默认为4.0
- (void)resetRadius:(CGFloat)radius;
// 设置圆点个数。默认为5
- (void)resetCycleCounts:(NSInteger)counts;
// 设置滑动颜色
- (void)resetSlideColor:(UIColor *)color;
// 监听滑动进度
- (void)addProgressAction:(ZTProgressBlock)progressAction;

@end
