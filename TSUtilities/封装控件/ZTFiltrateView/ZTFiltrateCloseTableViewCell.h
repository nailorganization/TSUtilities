//
//  ZTFiltrateCloseTableViewCell.h
//  ZTExchange
//
//  Created by suofei on 2018/3/22.
//  Copyright © 2018年 ZT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTFiltrateCloseModel.h"

@interface ZTFiltrateCloseTableViewCell : UITableViewCell

@property (nonatomic, copy) ZTButtonBlock clickBtnBlock;

- (void)setModel:(ZTFiltrateCloseModel *)model;

@end
