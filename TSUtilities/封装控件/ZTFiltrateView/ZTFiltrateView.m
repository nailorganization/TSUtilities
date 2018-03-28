//
//  ZTFiltrateView.m
//  ZTExchange
//
//  Created by suofei on 2018/3/22.
//  Copyright © 2018年 ZT. All rights reserved.
//

#import "ZTFiltrateView.h"
#import "ZTFiltrateCloseTableViewCell.h"
#import "ZTFiltrateOpenTableViewCell.h"

static NSString *kZTFiltrateCellId = @"ztFiltrateCellId";
static NSString *kZTFiltrateOpenCellId = @"ztFiltrateOpenCellId";
static CGFloat   kZTCloseCellHeight = 62;

@interface ZTFiltrateView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ZTBaseTableView        *tableView;
@property (nonatomic, strong) UIButton               *resetButton;
@property (nonatomic, strong) UIButton               *confirmButton;
@property (nonatomic, strong) NSArray                *closeDataArray;

@property (nonatomic, strong) UIImageView            *imageView;
@property (nonatomic, assign) NSInteger              extendNumber;

@property (nonatomic, assign) ZTLedgerType           ledgerType;
@property (nonatomic, assign) NSInteger              selectedType;
@property (nonatomic, strong) ZTNewCurrencyModel     *selectedCurrencyModel;
@property (nonatomic, assign) NSInteger              selectedCoinId;
@property (nonatomic, strong) ZTBillingActionType    *actionType;

@property (nonatomic, strong) ZTFiltrateCloseModel   *timeModel;

@property (nonatomic, assign) CGFloat                coinHeight;
@property (nonatomic, assign) CGFloat                typeHeight;

@property (nonatomic, strong) NSMutableArray         *coinDataArray;
@property (nonatomic, strong) NSMutableArray         *typeDataArray;

@end

@implementation ZTFiltrateView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.extendNumber = 0;
        self.actionType = [[ZTBillingActionType alloc] init];
        self.ledgerType = ZTLedgerTypeLast7Days;
        self.selectedType = -1;
        self.selectedCoinId = 0;
        [self initView];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = Color_Alpha(kBlackColor, 0.5);
}

#pragma mark --public
- (void)showWithView:(UIView *)view data:(NSArray *)data {
    if (self.superview) {
        [self removeFromSuperview];
    }
    self.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    self.alpha = 0;
    self.coinHeight = 0;
    self.typeHeight = 0;
    [view addSubview:self];
    self.closeDataArray = data;
    [self addSubview:self.tableView];
    [self resetTableView];
    [UIView animateWithDuration:0.26f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:nil];
}

#pragma mark - action
- (void)resetClick:(UIButton *)sender {
    self.ledgerType = ZTLedgerTypeLast7Days;
    self.selectedType = -1;
    self.selectedCoinId = 0;
    [self.closeDataArray enumerateObjectsUsingBlock:^(ZTFiltrateCloseModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selectedIdx = 0;
        if (idx == 2 || idx == 1) {
            obj.buttonTitleArray = @[@"不限"];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kResteFiltrateNotification" object:nil];
    [self.tableView reloadData];
}

- (void)confirmClick:(UIButton *)sender {
    kBLOCK_SAFE_EXEC(self.confirmBlock, self.ledgerType, self.selectedType, self.selectedCoinId);
    [self dismiss];
}

#pragma mark--tableViewDatasource/tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.closeDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ZTFiltrateCloseModel *model = self.closeDataArray[section];
    if (model.isExtend) {
        return 2;
    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZTFiltrateCloseModel *model = self.closeDataArray[indexPath.section];
    if (indexPath.row == 0) {
        if (indexPath.section == 0) {
            self.timeModel = model;
        }
        ZTFiltrateCloseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZTFiltrateCellId];
        [cell setModel:model];
        kWeakSelf
        cell.clickBtnBlock = ^(UIButton *button) {
            model.selectedIdx = button.tag;
            [tableView reloadData];
            weakSelf.ledgerType = button.tag + 1;
        };
        return cell;
    }else {
        kWeakSelf
        ZTFiltrateOpenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZTFiltrateOpenCellId];
        cell.selectTypeBlock = ^(NSInteger index) {
            weakSelf.selectedType = index;
            model.buttonTitleArray = @[[self.actionType actionTypeNameWithType:self.selectedType]];
            [tableView reloadData];
        };
        cell.selectCoinBlock = ^(NSInteger index) {
            weakSelf.selectedCoinId = index;
            __block NSString *title = @"不限";
            [weakSelf.coinDataArray enumerateObjectsUsingBlock:^(ZTNewCurrencyModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.ID integerValue] == self.selectedCoinId) {
                    title = obj.name;
                }
            }];
            model.buttonTitleArray = @[title];
            [tableView reloadData];
        };
        
        if (indexPath.section == 1) {
            [cell configCellWithData:self.coinDataArray indexPath:indexPath];
        }else if (indexPath.section == 2) {
            [cell configCellWithData:self.typeDataArray indexPath:indexPath];
        }
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return kZTCloseCellHeight;
    }else {
        if (indexPath.section == 1) {
            return self.coinHeight;
        }else if (indexPath.section == 2) {
            return self.typeHeight;
        }else {
            return 0;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZTFiltrateCloseModel *model = self.closeDataArray[indexPath.section];
    if (indexPath.row == 0) {
        if (model.isArrow) {
            model.isExtend = !model.isExtend;
            if (indexPath.section == 1) {
                self.typeHeight = 0;
                self.coinHeight = [self caculateHeightWithAcount:self.coinDataArray.count];
            }else if (indexPath.section == 2) {
                self.coinHeight = 0;
                self.typeHeight = [self caculateHeightWithAcount:self.typeDataArray.count];
            }
            [self resetContainsWithModel:model];
            [self.closeDataArray enumerateObjectsUsingBlock:^(ZTFiltrateCloseModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (indexPath.section != idx) {
                    obj.isExtend = NO;
                }
            }];
//            NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
//            [tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
            [tableView reloadData];
        }
    }
}

#pragma mark --private
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.26f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self) {
            [self.tableView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

- (void)resetContainsWithModel:(ZTFiltrateCloseModel *)model {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kZTCloseCellHeight * 3 + 44 + _coinHeight + _typeHeight);
    }];
}

- (void)resetTableView {
    [self.closeDataArray enumerateObjectsUsingBlock:^(ZTFiltrateCloseModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 1 && obj.isExtend == YES) {
            self.coinHeight = [self caculateHeightWithAcount:self.coinDataArray.count];
        }else if (idx == 2 && obj.isExtend == YES) {
            self.typeHeight = [self caculateHeightWithAcount:self.typeDataArray.count];
        }
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.and.right.equalTo(self);
        make.height.mas_equalTo(kZTCloseCellHeight * 3 + 44 + _coinHeight + _typeHeight);
    }];
}

- (CGFloat)caculateHeightWithAcount:(NSInteger)acount {
    NSInteger rowNumber = ceil(acount / 3.0);
    return 45 * rowNumber;
}

#pragma mark- getter/setter
- (void)setCloseDataArray:(NSArray *)closeDataArray {
    _closeDataArray = closeDataArray;
    [self.tableView reloadData];
}

- (void)setCoinArray:(NSArray *)coinArray {
    _coinArray = coinArray;
    [self.coinDataArray removeAllObjects];
    [_coinArray enumerateObjectsUsingBlock:^(ZTNewCurrencyModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.coinDataArray addObject:obj];
        if (idx >= 10) {
            *stop = YES;
        }
    }];
    ZTNewCurrencyModel *model = [[ZTNewCurrencyModel alloc] init];
    model.name = @"不限";
    model.ID = @"0";
    [self.coinDataArray insertObject:model atIndex:0];
//    _coinHeight = [self caculateHeightWithAcount:self.coinDataArray.count];
}

- (void)setTypeArray:(NSArray *)typeArray {
    _typeArray = typeArray;
    [self.typeDataArray removeAllObjects];
    [_typeArray enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.typeDataArray addObject:obj];
        if (idx >= 10) {
            *stop = YES;
        }
    }];
    [self.typeDataArray insertObject:@(-1) atIndex:0];
//    _typeHeight = [self caculateHeightWithAcount:self.typeDataArray.count];
}

- (UIButton *)resetButton {
    if (!_resetButton) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetButton setBackgroundImage:[UIColor zt_imageWithColor:kWhiteColor] forState:UIControlStateNormal];
        [_resetButton setBackgroundImage:[UIColor zt_imageWithColor:kMainColor] forState:UIControlStateHighlighted];
        [_resetButton setTitle:@"重置" forState:UIControlStateNormal];
        _resetButton.titleLabel.font = ZTFontLight(14);
        [_resetButton setTitleColor:kGrayColor888888 forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(resetClick:) forControlEvents:UIControlEventTouchUpInside];
        [_resetButton zt_borderWithBorderColor:kSeparateLineColor borderWidth:0.5f];
    }
    return _resetButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setBackgroundImage:[UIColor zt_imageWithColor:kWhiteColor] forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:[UIColor zt_imageWithColor:kMainColor] forState:UIControlStateHighlighted];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = ZTFontLight(14);
        [_confirmButton setTitleColor:Color_Hex(0x6c8ac0) forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmClick:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton zt_borderWithBorderColor:kSeparateLineColor borderWidth:0.5];
    }
    return _confirmButton;
}

- (ZTBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[ZTBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = kZTCloseCellHeight;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 44)];
        [footerView addSubview:self.resetButton];
        [footerView addSubview:self.confirmButton];
        [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(footerView);
            make.left.equalTo(footerView);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(kMainScreenWidth / 2);
        }];
        
        [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.resetButton);
            make.right.equalTo(footerView);
            make.height.mas_equalTo(self.resetButton);
            make.width.mas_equalTo(self.resetButton);
        }];
        _tableView.tableFooterView = footerView;
        [_tableView registerClass:[ZTFiltrateCloseTableViewCell class] forCellReuseIdentifier:kZTFiltrateCellId];
        [_tableView registerClass:[ZTFiltrateOpenTableViewCell class] forCellReuseIdentifier:kZTFiltrateOpenCellId];
    }
    return _tableView;
}

- (NSMutableArray *)coinDataArray {
    if (!_coinDataArray) {
        _coinDataArray = [NSMutableArray array];
    }
    return _coinDataArray;
}

- (NSMutableArray *)typeDataArray {
    if (!_typeDataArray) {
        _typeDataArray = [NSMutableArray array];
    }
    return _typeDataArray;
}

@end
