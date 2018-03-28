//
//  ZTFiltrateCloseTableViewCell.m
//  ZTExchange
//
//  Created by suofei on 2018/3/22.
//  Copyright © 2018年 ZT. All rights reserved.
//

#import "ZTFiltrateCloseTableViewCell.h"

static CGFloat kButtonWidth = 75;

@interface ZTFiltrateCloseTableViewCell()

@property (nonatomic, strong) ZTFiltrateCloseModel *model;
@property (nonatomic, strong) NSMutableArray       *buttonArray;
@property (nonatomic, strong) UILabel              *titleLabel;
@property (nonatomic, strong) UIImageView          *arrowImageView;
@property (nonatomic, strong) UIImage              *image;
@property (nonatomic, strong) UIView               *lineView;

@end

@implementation ZTFiltrateCloseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 21, 30, 15)];
    self.titleLabel.font = ZTFontLight(14);
    self.titleLabel.textColor = kBlackColor;
    [self.contentView addSubview:self.titleLabel];
    
    self.image = [UIImage imageNamed:@"filtrateArrow"];
    self.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMainScreenWidth - self.image.size.width - 30, (self.zt_height - self.image.size.height) / 2, self.image.size.width, self.image.size.height)];
    [self.contentView addSubview:self.arrowImageView];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = kSeparateLineColor;
    [self.contentView addSubview:self.lineView];
}

- (void)setModel:(ZTFiltrateCloseModel *)model {
    
    [self.buttonArray removeAllObjects];
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    if (!model.isExtend) {
        self.lineView.frame = CGRectMake(0, 61.5, kMainScreenWidth, 0.5);
        [self.contentView addSubview:self.lineView];
    }
    
    self.titleLabel.text = model.title;
    [self.contentView addSubview:self.titleLabel];
    
    if (model.isArrow) {
        if (model.isExtend) {
            self.image = [UIImage imageNamed:@"filtrateDown"];
            self.arrowImageView.image = self.image;
        }else {
            self.image = [UIImage imageNamed:@"filtrateArrow"];
            self.arrowImageView.image = self.image;
        }
    }else {
        self.arrowImageView.hidden = YES;
    }
    [self.contentView addSubview:self.arrowImageView];
    
    kWeakSelf
    [model.buttonTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *buttonTitle = obj;
         UIButton *button = [[UIButton alloc] init];
        if (model.selectedIdx == idx) {
            [button setTitleColor:Color_Hex(0xffffff) forState:UIControlStateNormal];
            [button setTitleColor:Color_Hex(0xffffff) forState:
             UIControlStateHighlighted];
            [button setBackgroundImage:[UIColor zt_imageWithColor:kMainCopyBlueColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIColor zt_imageWithColor:kButtonHighlightedColor] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[UIColor zt_imageWithColor:kMainCopyBlueColor] forState:UIControlStateDisabled];
        }else {
            button.backgroundColor = kWhiteColor;
            [button setTitleColor:kMainCopyBlueColor forState:UIControlStateNormal];
            [button setTitleColor:kMainCopyBlueColor forState:
             UIControlStateHighlighted];
            [button setBackgroundImage:[UIColor zt_imageWithColor:kWhiteColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIColor zt_imageWithColor:kButtonHighlightedColor] forState:UIControlStateHighlighted];
        }
        button.frame = CGRectMake(CGRectGetMaxX(weakSelf.titleLabel.frame) + idx * kButtonWidth + (idx + 1) * 12, 15, kButtonWidth, 30);
        [button zt_borderWithBorderColor:Color_Hex(0x6c8ac0) borderWidth:1 cornerRadius:2];
        button.tag = idx;
        button.userInteractionEnabled = model.isCanSelected == YES ? : NO;
        button.titleLabel.font = ZTFontLight(13);
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [weakSelf.contentView addSubview:button];
        [weakSelf.buttonArray addObject:button];
    }];
}

- (void)buttonClick:(UIButton *)sender {
    kBLOCK_SAFE_EXEC(self.clickBtnBlock, sender);
}

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
