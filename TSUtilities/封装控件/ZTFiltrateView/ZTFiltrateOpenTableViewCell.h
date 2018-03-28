//
//  ZTFiltrateOpenTableViewCell.h
//  ZTExchange
//
//  Created by suofei on 2018/3/23.
//  Copyright © 2018年 ZT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTCurrencyModel.h"
#import "ZTBillingActionType.h"

@interface ZTFiltrateOpenTableViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger selectCoin;
@property (nonatomic, assign) NSInteger selectType;

@property (nonatomic, copy) ZTIndexBlock selectCoinBlock;
@property (nonatomic, copy) ZTIndexBlock selectTypeBlock;

- (void)configCellWithData:(NSArray *)data indexPath:(NSIndexPath *)indexPath;

@end
