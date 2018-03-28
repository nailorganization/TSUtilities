//
//  ZTFiltrateView.h
//  ZTExchange
//
//  Created by suofei on 2018/3/22.
//  Copyright © 2018年 ZT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTFiltrateCloseModel.h"

typedef NS_ENUM(NSUInteger, ZTLedgerType) {
    ZTLedgerTypeLast7Days = 1,
    ZTLedgerTypeHistory = 2,
};

typedef void(^ZTFiltrateViewConfirmBlock)(ZTLedgerType selectedLedgerType, NSInteger selectedActionType, NSInteger selectedCoinId);

@interface ZTFiltrateView : UIView

@property (nonatomic, strong) NSArray *coinArray;
@property (nonatomic, strong) NSArray *typeArray;
@property (nonatomic, copy) ZTFiltrateViewConfirmBlock confirmBlock;

- (void)showWithView:(UIView *)view data:(NSArray *)data;
- (void)dismiss;

@end
