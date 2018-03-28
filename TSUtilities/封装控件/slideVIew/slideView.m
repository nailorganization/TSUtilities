//
//  slideView.m
//  ZTExchange
//
//  Created by suofei on 2018/3/28.
//  Copyright © 2018年 ZT. All rights reserved.
//

#import "slideView.h"

#define kCenterY (CGRectGetHeight(self.frame)/2)

typedef NS_ENUM(NSInteger, ZTTouchDrawType) {
    ZTTouchDrawMove_Type, // 移动
    ZTTouchDrawClick_Type // 点击
};
typedef void (^ZTNewProgressBlcok) (id obj, BOOL isSetProgress);

@interface ZTSlideView: UIView
@property (nonnull, strong)CAShapeLayer *shapeLayer;        // 背景层
@property (nonnull, strong)CAShapeLayer *touchShapeLayer;   // 着色层
@property (nonnull, strong)CAShapeLayer *noCenterShapeLayer;// 空心圆
@property (nonnull, strong)UIBezierPath *path;
@property (nonnull, strong)UIBezierPath *touchPath;
@property (nonnull, strong)UIBezierPath *noCenterPath;
@property (nonatomic, assign)CGFloat     fRadious;
@property (nonatomic, assign)NSInteger   nCycleCount;       // 圆点数
@property (nonatomic, assign)CGFloat     fDistance;         // 两点间距
@property (nonatomic, strong)UIColor    *slideColor;        // 滑动颜色

@property (nonatomic, copy)NSString     *progress;

@property (nonatomic, copy)ZTNewProgressBlcok objBlock;
@property (nonatomic, assign)BOOL        isInit;
@property (nonatomic, assign)BOOL        isMoving;
@property (nonatomic, assign)BOOL        isSetProgress;
@property (nonatomic, assign)BOOL        isActiveGesture;
@property (nonatomic, strong)NSMutableArray *pointsArray;
@end

@implementation ZTSlideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initView];
    }
    return self;
}
- (void)initView
{
    _shapeLayer = [CAShapeLayer new];
    _touchShapeLayer = [CAShapeLayer new];
    _noCenterShapeLayer = [CAShapeLayer new];
    _path = [UIBezierPath bezierPath];
    _touchPath = [UIBezierPath bezierPath];
    _noCenterPath = [UIBezierPath bezierPath];
    _fRadious = 4.0;
    _nCycleCount = 5;
    _slideColor = Color_Hex(0x272c56);
    
    _pointsArray = [NSMutableArray arrayWithCapacity:5];
    
    
    //    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSlideView:)];
    //    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(spanSlideView:)];
    //    [self addGestureRecognizer:tapGes];
    //    [self addGestureRecognizer:panGes];
}

- (void)layoutSubviews {
    if (_isInit) { return;}
    [_pointsArray removeAllObjects];
    _fDistance = (CGRectGetWidth(self.frame) - (_nCycleCount*2.0*_fRadious)) / (_nCycleCount-1);
    
    // 画线
    [self drawLineStartPoint:CGPointMake(_fRadious*2, kCenterY) movePoints:@[@(CGPointMake(CGRectGetWidth(self.frame), kCenterY))] bezierPath:_path];
    // 画圆
    CGPoint centerPoint = CGPointMake(_fRadious, kCenterY);// 起始圆点
    for (int i = 0; i < _nCycleCount; i++) {
        if (i == 0) {
            //            [self drawCycleCenterPoint:centerPoint bezierPath:_path];
            [self drawCycleCenterPoint:centerPoint radius:_fRadious+0.5 bezierPath:_noCenterPath];
        }else {
            [self drawCycleCenterPoint:centerPoint bezierPath:_path];
        }
        [_pointsArray addObject:@(centerPoint.x)];
        centerPoint = CGPointMake(centerPoint.x + _fDistance + _fRadious*2 , centerPoint.y);
    }
    
    _shapeLayer.path = _path.CGPath;
    _shapeLayer.lineWidth = 2;
    _shapeLayer.strokeColor = Color_Hex(0xe5e9ec).CGColor;
    _shapeLayer.fillColor = Color_Hex(0xe5e9ec).CGColor;
    [self.layer addSublayer:_shapeLayer];
    
    // 画空心圆
    [self drawNoCenterCycle];
    
    //    _isSetProgress = NO;
    //    if (_progress) {
    //        _isSetProgress = YES;
    //        [self setProgressDrawWithProgress:[_progress floatValue]];
    //    }
}
#pragma mark -
#pragma mark methods
// drawNoCenterCycle
- (void)drawNoCenterCycle
{
    _noCenterShapeLayer.fillColor = [UIColor whiteColor].CGColor;
    _noCenterShapeLayer.lineWidth = 1.f;
    _noCenterShapeLayer.strokeColor = _slideColor.CGColor;
    _noCenterShapeLayer.path = _noCenterPath.CGPath;
    [self.layer addSublayer:_noCenterShapeLayer];
}
- (void)updateDrawNoCenterCycle
{
    //    if (!_progress || [_progress isEqual:@"0.00"]) {
    [self drawNoCenterCycle];
    //    }
}

// drawlinePath
- (void)drawLineStartPoint:(CGPoint)startPoint movePoints:(NSArray *)movePoints bezierPath:(UIBezierPath *)path
{
    [path moveToPoint:startPoint];
    for (NSValue *pointValue in movePoints) {
        CGPoint movePoint = [pointValue CGPointValue];
        [path addLineToPoint:movePoint];
    }
}
// drawCyclePath
- (void)drawCycleCenterPoint:(CGPoint)centerPoint bezierPath:(UIBezierPath *)path
{
    [self drawCycleCenterPoint:centerPoint radius:_fRadious bezierPath:path];
}
- (void)drawCycleCenterPoint:(CGPoint)centerPoint radius:(CGFloat)radius bezierPath:(UIBezierPath *)path
{
    [path addArcWithCenter:centerPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
}

// touchDrawing
- (void)touchDrawingCurrentPoint:(CGPoint)currentPoint touchType:(ZTTouchDrawType)touchType
{
    CGFloat currentX = currentPoint.x;
    //    CGFloat currentY = currentPoint.y;
    if (currentX < 0 || currentX > CGRectGetWidth(self.frame)) { return;}
    //    if (currentY <= 0 || currentY >= CGRectGetHeight(self.frame)) { return;}
    
    if (touchType == ZTTouchDrawMove_Type) {
        [self moveDrawWithCurrentPoint:currentPoint];
        [self adjustMovingProgressWithCurrentPoint:currentPoint];
        
    }else if (touchType == ZTTouchDrawClick_Type) {
        NSInteger nIndex = [self clickDrawWithCurrentPoint:currentPoint];
        if (nIndex < 0) { return;}
        [self adjustClickProgressWithIndex:nIndex];
    }
    
    _touchShapeLayer.path = _touchPath.CGPath;
    _touchShapeLayer.lineWidth = 2;
    _touchShapeLayer.fillColor = _slideColor.CGColor;
    _touchShapeLayer.strokeColor = _slideColor.CGColor;
    [self.layer addSublayer:_touchShapeLayer];
    
    if (_objBlock) {
        _objBlock(_progress, _isSetProgress);
    }
    _isSetProgress = NO;
}
// moveDrawingPath
- (void)moveDrawWithCurrentPoint:(CGPoint)currentPoint
{
    CGFloat currentX = currentPoint.x;
    [_touchPath removeAllPoints];
    
    for (NSNumber *number in _pointsArray) {
        CGFloat centerX = [number floatValue];
        if (currentX >= 0 && currentX < _fRadious*2) {// 处于第一个圆点内
            [self drawNoCenterCycle];
        }else if (currentX > (centerX - _fRadious)) {//画圆
            CGPoint centerPoint = CGPointMake(centerX, kCenterY);
            [self drawCycleCenterPoint:centerPoint bezierPath:_touchPath];
        }
    }
    currentX = currentX >= _fRadious*2? currentX : _fRadious*2;
    [self drawLineStartPoint:CGPointMake(_fRadious*2, kCenterY) movePoints:@[@(CGPointMake(currentX, kCenterY))] bezierPath:_touchPath];
}
// clickDrawingPath
- (NSInteger)clickDrawWithCurrentPoint:(CGPoint)currentPoint
{
    __block NSInteger nIndex = -1;// 位于某个圆点
    [_pointsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *number = obj;
        CGFloat centerX = [number floatValue];
        CGFloat newRadius = _fRadious + 10;
        CGRect rect = {{centerX - newRadius, kCenterY - newRadius}, {newRadius*2, newRadius*2}};
        if (CGRectContainsPoint(rect, currentPoint)) {
            nIndex = idx;
            *stop = YES;
        }
    }];
    
    if (nIndex == -1) { return nIndex;}
    
    [_touchPath removeAllPoints];
    for (int i = 0; i <= nIndex; i++) {
        if (nIndex == 0) {// 点击第一个绘空心圆
            [self drawNoCenterCycle];
        }else {
            NSNumber *number = _pointsArray[i];
            CGFloat centerX = [number floatValue];
            CGPoint centerPoint = CGPointMake(centerX, kCenterY);
            [self drawCycleCenterPoint:centerPoint bezierPath:_touchPath];
        }
    }
    if (nIndex > 0) {// 点击非第一个点画线
        NSNumber *number = _pointsArray[nIndex];
        CGFloat x = [number floatValue];
        [self drawLineStartPoint:CGPointMake(_fRadious*2, kCenterY) movePoints:@[@(CGPointMake(x, kCenterY))] bezierPath:_touchPath];
    }
    
    return nIndex;
}
// movingProgress
- (void)adjustMovingProgressWithCurrentPoint:(CGPoint)currentPoint
{
    CGFloat currentX = currentPoint.x;
    __block CGFloat realDistance = 0.0;// 去除圆点占用水平方向距离后的移动距离
    [_pointsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *number = obj;
        CGFloat centerX = [number floatValue];
        CGRect rect = {{centerX - _fRadious, 0}, {_fRadious*2, CGRectGetHeight(self.frame)}};
        if (CGRectContainsPoint(rect, currentPoint)) {// 位于某个圆点
            if (idx > 0) {
                realDistance = idx * _fDistance;
            }
        }else if(currentX > (centerX + _fRadious)) {// 处于圆点右侧
            realDistance = currentX - (idx + 1)*_fRadious*2;
        }else if (currentX < (centerX - _fRadious)) {
            *stop = YES;
        }
    }];
    
    CGFloat divisor = CGRectGetWidth(self.frame) - _nCycleCount*2*_fRadious;
    CGFloat rate = realDistance / divisor;
    rate = rate > 1.0 ? 1.0 : rate;
    // 进行四舍五入
    NSString *helpRate = [NSString stringWithFormat:@"%0.2f",rate];
    self.progress = [NSString stringWithFormat:@"%d%%", (int)([helpRate floatValue] * 100)];
}
// clickProgress
// index: 点击的索引圆点
- (void)adjustClickProgressWithIndex:(NSInteger)index
{
    CGFloat divisor = _nCycleCount - 1.0;// 除数
    CGFloat rate = index / divisor;
    self.progress = [NSString stringWithFormat:@"%d%%", (int)(rate * 100)];
}
// setterProgressDraw
- (void)setProgressDrawWithProgress:(CGFloat)progress
{
    if (_isActiveGesture) { return;}
    _isSetProgress = YES;
    _isInit = YES;
    CGFloat currentX = 0;
    CGFloat rateW = CGRectGetWidth(self.frame) - _fRadious*(_nCycleCount*2);
    
    int nHelp = [[NSString stringWithFormat:@"%0.2f", progress*100] intValue];
    int value = 100 / (_nCycleCount - 1); // 每份
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:10];
    
    // 抽象逻辑
    for (int i = 0; i < _nCycleCount; i++) {
        int pointValue = value * i;
        [tempArray addObject:@(pointValue)];
    }
    
    int index = 2;
    for (int j = 0; j < tempArray.count - 1; j++) {
        int preValue = [tempArray[j] intValue];
        int sufValue = [tempArray[j+1] intValue];
        if (nHelp > preValue && nHelp < sufValue) {
            currentX = _fRadious*index + nHelp*rateW/100.0;
            break;
        }else if (nHelp == sufValue) {
            index += 1;
            currentX = _fRadious*index + nHelp*rateW/100.0;
            break;
        }
        index += 2;
    }
    
    // 具体逻辑
    //    if (nHelp > 0 && nHelp < 25) {
    //        currentX = _fRadious*2 + progress*rateW;
    //    }else if (nHelp == 25) {
    //        currentX = _fRadious*3 + progress*rateW;
    //    }else if (nHelp > 25 && nHelp < 50) {
    //        currentX = _fRadious*4 + progress*rateW;
    //    }else if (nHelp == 50) {
    //        currentX = _fRadious*5 + progress*rateW;
    //    }else if (nHelp > 50 && nHelp < 75) {
    //        currentX = _fRadious*6 + progress*rateW;
    //    }else if (nHelp == 75) {
    //        currentX = _fRadious*7 + progress*rateW;
    //    }else if (nHelp > 75 && nHelp < 100) {
    //        currentX = _fRadious*8 + progress*rateW;
    //    }else if (nHelp == 100) {
    //        currentX = _fRadious*9 + progress*rateW;
    //    }
    
    CGPoint touchPoint = CGPointMake(currentX, kCenterY);
    [self touchDrawingCurrentPoint:touchPoint touchType:ZTTouchDrawMove_Type];
}
#pragma mark -
#pragma mark touch event
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
//    _isInit = YES;
//}
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [super touchesMoved:touches withEvent:event];
//    _isMoving = YES;
//    UITouch *touch = [touches anyObject];
//    CGPoint currentPoint = [touch locationInView:self];
//    [self touchDrawingCurrentPoint:currentPoint touchType:ZTTouchDrawMove_Type];
//}
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    if (_isMoving) {
//        _isMoving = NO;
//        return;
//    }
//    UITouch *touch = [touches anyObject];
//    CGPoint currentPoint = [touch locationInView:self];
//     [self touchDrawingCurrentPoint:currentPoint touchType:ZTTouchDrawClick_Type];
//}
#pragma mark -
#pragma mark gesture
- (void)spanSlideView:(UIGestureRecognizer *)gesture
{
    _isActiveGesture = YES;
    _isInit = YES;
    _isMoving = YES;
    CGPoint currentPoint = [gesture locationInView:self];
    [self touchDrawingCurrentPoint:currentPoint touchType:ZTTouchDrawMove_Type];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        _isActiveGesture = NO;
    }
}
- (void)tapSlideView:(UIGestureRecognizer *)gesture
{
    _isActiveGesture = YES;
    if (gesture.state == UIGestureRecognizerStateEnded) {
        _isInit = YES;
        if (_isMoving) {
            _isMoving = NO;
            return;
        }
        CGPoint currentPoint = [gesture locationInView:self];
        [self touchDrawingCurrentPoint:currentPoint touchType:ZTTouchDrawClick_Type];
        _isActiveGesture = NO;
    }
    
}

@end

@interface slideView()

@property (nonnull, strong)ZTSlideView *slideView;
@property (nonnull, strong)UILabel     *valueLable;
@property (nonatomic, copy)ZTProgressBlock progressBlock;

@end

@implementation slideView

@synthesize progress = _progress;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
    [self initConstraints];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initView];
        [self initConstraints];
    }
    return self;
}

- (void)initView
{
    _slideView = [ZTSlideView new];
    _valueLable = [UILabel new];
    
    _valueLable.text = @"0%";
    _valueLable.font = ZTFontMedium(10);
    _valueLable.textColor = kGrayColor333333;
    _valueLable.textAlignment = NSTextAlignmentCenter;
    
    @weakify(self)
    _slideView.objBlock = ^(id obj, BOOL isSetProgress) {
        NSString *value = (NSString *)obj;
        self_weak_.valueLable.text = value;
        if (isSetProgress) { return;}
        CGFloat fProgress = [value floatValue] / 100.0;
        NSString *progressStr = [NSString stringWithFormat:@"%0.2f",fProgress];
        if (self_weak_.progressBlock) {
            self_weak_.progressBlock([progressStr floatValue]);
        }
    };
}
- (void)initConstraints
{
    [self addSubview:_slideView];
    [self addSubview:_valueLable];
    
    [_slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(_valueLable.mas_left);
    }];
    [_valueLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.mas_equalTo(50);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:_slideView action:@selector(tapSlideView:)];
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:_slideView action:@selector(spanSlideView:)];
    [self addGestureRecognizer:tapGes];
    [self addGestureRecognizer:panGes];
}

#pragma mark -
#pragma mark public
- (void)resetRadius:(CGFloat)radius
{
    _slideView.fRadious = radius;
    [_slideView setNeedsLayout];
}
- (void)resetCycleCounts:(NSInteger)counts
{
    _slideView.nCycleCount = counts;
    [_slideView setNeedsLayout];
}
- (void)addProgressAction:(ZTProgressBlock)progressAction
{
    _progressBlock = progressAction;
}
- (void)resetSlideColor:(UIColor *)color
{
    _slideView.slideColor = color;
    [_slideView updateDrawNoCenterCycle];
}

#pragma mark -
#pragma mark getter and setter
- (CGFloat)progress
{
    return [_slideView.progress floatValue];
}
- (void)setProgress:(CGFloat)progress {
    progress = progress < 0 ? 0: progress;
    progress = progress > 1 ? 1: progress;
    // 进行四舍五入
    NSString *tempProgress = [NSString stringWithFormat:@"%0.2f", progress];
    _slideView.progress = tempProgress;
    _progress = [tempProgress floatValue];
    [_slideView setProgressDrawWithProgress:_progress];
}


@end
