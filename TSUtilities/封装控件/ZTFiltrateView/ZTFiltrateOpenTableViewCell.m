//
//  ZTFiltrateOpenTableViewCell.m
//  ZTExchange
//
//  Created by suofei on 2018/3/23.
//  Copyright © 2018年 ZT. All rights reserved.
//

#import "ZTFiltrateOpenTableViewCell.h"

static const CGFloat kButtonHeight = 30;
#define kButtonWidth  (IPHONE5 ? 65 : 75)


@interface ZTFiltrateOpenTableViewCell()

@property (nonatomic, strong) NSMutableArray       *buttonArray;
@property (nonatomic, strong) ZTBillingActionType  *actionType;

@property (nonatomic, strong) UIView               *lineView;

@end

@implementation ZTFiltrateOpenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
        self.selectCoin = 0;
        self.selectType = -1;
        self.actionType = [[ZTBillingActionType alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFiltrateClick:) name:@"kResteFiltrateNotification" object:nil];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = kWhiteColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = kSeparateLineColor;
    [self.contentView addSubview:self.lineView];
}

- (void)configCellWithData:(NSArray *)data indexPath:(NSIndexPath *)indexPath {
    [self.buttonArray removeAllObjects];
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    if (indexPath.section == 1) {
        NSMutableArray *tempArr = [data mutableCopy];
        [tempArr enumerateObjectsUsingBlock:^(ZTNewCurrencyModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [[UIButton alloc] init];
            if (self.selectCoin == [obj.ID integerValue]) {
                [button setBackgroundImage:[UIColor zt_imageWithColor:kMainCopyBlueColor] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIColor zt_imageWithColor:kButtonHighlightedColor] forState:UIControlStateHighlighted];
                [button setTitleColor:kWhiteColor forState:UIControlStateNormal];
                [button setTitleColor:kWhiteColor forState:
                 UIControlStateHighlighted];
            }else {
                [button setBackgroundImage:[UIColor zt_imageWithColor:kWhiteColor] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIColor zt_imageWithColor:kButtonHighlightedColor] forState:UIControlStateHighlighted];
                [button setTitleColor:kMainCopyBlueColor forState:UIControlStateNormal];
                [button setTitleColor:kMainCopyBlueColor forState:
                 UIControlStateHighlighted];
            }
            [button setBackgroundImage:[UIColor zt_imageWithColor:kMainCopyBlueColor] forState:UIControlStateSelected];
            [button setTitleColor:kWhiteColor forState:UIControlStateSelected];
            [button zt_borderWithBorderColor:Color_Hex(0x6c8ac0) borderWidth:1 cornerRadius:2];
            [button setTitle:obj.name forState:UIControlStateNormal];
            button.tag = [obj.ID integerValue];
            button.titleLabel.font = ZTFontLight(13);
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            [button addTarget:self action:@selector(coinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
            button.frame = [self caculateButtonFrameWithCollom:3 idx:idx];
            
            [self.contentView addSubview:button];
            [self.buttonArray addObject:button];
        }];
    }else if (indexPath.section == 2) {
        NSMutableArray *tempArr = [data mutableCopy];
        [tempArr enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [[UIButton alloc] init];
            if (self.selectType == [obj integerValue]) {
                [button setBackgroundImage:[UIColor zt_imageWithColor:kMainCopyBlueColor] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIColor zt_imageWithColor:kButtonHighlightedColor] forState:UIControlStateHighlighted];
                [button setTitleColor:kWhiteColor forState:UIControlStateNormal];
                [button setTitleColor:kWhiteColor forState:
                 UIControlStateHighlighted];
            }else {
                [button setBackgroundImage:[UIColor zt_imageWithColor:kWhiteColor] forState:UIControlStateNormal];
                [button setBackgroundImage:[UIColor zt_imageWithColor:kButtonHighlightedColor] forState:UIControlStateHighlighted];
                [button setTitleColor:kMainCopyBlueColor forState:UIControlStateNormal];
                [button setTitleColor:kMainCopyBlueColor forState:
                 UIControlStateHighlighted];
            }
            [button setBackgroundImage:[UIColor zt_imageWithColor:kMainCopyBlueColor] forState:UIControlStateSelected];
            [button setTitleColor:kWhiteColor forState:UIControlStateSelected];
            [button zt_borderWithBorderColor:Color_Hex(0x6c8ac0) borderWidth:1 cornerRadius:2];
            [button setTitle:[self.actionType actionTypeNameWithType:[obj integerValue]] forState:UIControlStateNormal];
            button.tag = [obj integerValue];
            button.titleLabel.font = ZTFontLight(13);
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            [button addTarget:self action:@selector(typeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            button.frame = [self caculateButtonFrameWithCollom:3 idx:idx];
            
            [self.contentView addSubview:button];
            [self.buttonArray addObject:button];
        }];
    }
    NSInteger numberOfRow = ceil(self.buttonArray.count / 3.0);
    self.lineView.frame = CGRectMake(0, numberOfRow * 45 - 0.5, kMainScreenWidth, 0.5);
    [self.contentView addSubview:self.lineView];
}

- (CGRect)caculateButtonFrameWithCollom:(NSInteger)collom idx:(NSInteger)idx {
    CGFloat row = idx / collom; //行
    CGFloat col = idx % collom; //列
    CGFloat buttonX = 0;
    CGFloat buttonY = 0;
    
    buttonX = col * (kButtonWidth + 15) + 72;
    buttonY = row * (kButtonHeight + 15);
    if (row == 0) {
        buttonY = 0;
    }
    if (col == 0) {
        buttonX = 72;
    }
    return CGRectMake(buttonX, buttonY, kButtonWidth, kButtonHeight);
}

- (void)coinButtonClick:(UIButton *)sender {
    self.selectCoin = sender.tag;
    kBLOCK_SAFE_EXEC(self.selectCoinBlock, self.selectCoin);
}

- (void)typeButtonClick:(UIButton *)sender {
    self.selectType = sender.tag;
    kBLOCK_SAFE_EXEC(self.selectTypeBlock, self.selectType);
}

- (void)resetFiltrateClick:(NSNotification *)notification {
    self.selectCoin = 0;
    self.selectType = -1;
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray arrayWithCapacity:9];
    }
    return _buttonArray;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}

@end
