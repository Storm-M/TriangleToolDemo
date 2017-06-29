//
//  TriangleToolView.m
//  testWKWebView
//
//  Created by jianglihui on 2017/3/24.
//  Copyright © 2017年 jianglihui. All rights reserved.
//

#import "ToolTriangleToolView.h"
#import "UIViewExt.h"

typedef enum {
    eLocationUnknow = 0,
    eLocationRotate,        //旋转
    eLocationScale,         //拉伸
    eLocationMove,          //移动自身
}eLocationType;

@interface ToolTriangleToolView ()

@property (nonatomic, weak)   UIView *mainView;
@property (nonatomic, strong)   UIImageView *rotateView;
@property (nonatomic, strong)   UIImageView *scaleView;
@property (nonatomic, strong)   UIButton *closeButton;

@property (assign, nonatomic)   CGPoint startPoint;
@property (assign, nonatomic)   eLocationType locationType;
@property (nonatomic, assign)   CGPoint anchorPoint;
@property (nonatomic, assign)   CGAffineTransform startTransform;
@property (nonatomic, assign)   CGFloat rotate;
@property (nonatomic, assign)   CGRect  originFrame;
@property (nonatomic, assign)   BOOL isResetRotate;

//@property (nonatomic, assign)   CGRect  currentFrame;

@property (nonatomic, assign)   CGFloat preMoveSize;


@property (assign)  CGRect initFrame;


@end


@implementation ToolTriangleToolView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineDic = [NSMutableDictionary dictionary];
        
        self.mainView = self;
        
        self.initFrame = frame;
    }
    return self;
}

- (void)setAngle:(int)angle {
    _angle = angle;
    
    if (_angle == 45) {
        self.isOscelesTrianle = YES;
    }
    [self addSubview:self.rotateView];
    [self addSubview:self.scaleView];
    [self addSubview:self.closeButton];
}

- (void)sendMessage:(NSString *)eventName withData:(NSDictionary *)eventData {
    //[self.presenter.processor sendMessage:eventName withData:eventData];
}

- (void)closeWindow:(id)sender {

    self.superview.hidden = YES;
    
    self.transform = CGAffineTransformIdentity;
    self.frame = self.initFrame;
    
    if (self.isOscelesTrianle) {
        [self sendMessage:@"RulerClose" withData:self.infoDir];
    }
}



- (void)drawRect:(CGRect)rect {
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    if (self.angle == 45) { //45度为直角三角形，30度为等腰三角形，目前以30度为例子
        width = height = MIN(width, height);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1);  //线宽
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetRGBStrokeColor(context, 255.0 / 255.0, 0 / 255.0, 0 / 255.0, 1.0);  //线的颜色-黑色
    CGContextBeginPath(context);

    //绘制三条边
    CGContextMoveToPoint(context, 0, 0);  //起点坐标
    CGContextAddLineToPoint(context, rect.size.width, 0);
    CGContextMoveToPoint(context, 0, 0);  //起点坐标
    CGContextAddLineToPoint(context, 0, rect.size.height);   //终点坐标
    CGContextMoveToPoint(context, 0, rect.size.height);  //起点坐标
    CGContextAddLineToPoint(context, rect.size.width, 0);
    
    
    CGFloat step = 5;
    int beginIndex = step;
    //先画横向。一厘米一共要画10格，最后一格最长，中间那格是第二长，其他的短。
    for (int i = 0; i < (int)((rect.size.width+step*2)/(step*10)-1); i++) { //i为cm单位
        for (int j = 0; j < 9; j++) {
            int horiHeigt = step*2; //horiHeigt为画的长度，ipad里面1mm越等于20像素。换算成分辨率就是10
            if (i == 0 && j == 0) { //j为mm单位，当为第一小格的时候特殊处理。此时只画一半
                horiHeigt = step;
            }
            else if (j == 4) { //当为5毫米的时候 要画1.5倍长度
                horiHeigt = step*2*1.5;
            }
            CGContextMoveToPoint(context, beginIndex+j*step, 0);  //起点坐标
            CGContextAddLineToPoint(context, beginIndex+j*step, horiHeigt);   //终点坐标
        }
        
        //当画1cm最后一格的时候，2倍长度
        CGContextMoveToPoint(context, beginIndex+(step*9), 0);  //起点坐标
        CGContextAddLineToPoint(context, beginIndex+(step*9), step*4);   //终点坐标
        
        beginIndex += (step*10);
        //画cm的数字。当宽度不够的时候，不绘制最后一格的文字。否则会超出斜边
        if (i == (int)((rect.size.width+step*2)/(step*10)-1) - 1) {
              if (!(step*4+2+20 > (self.bounds.size.height-(beginIndex-3)*[self getAngleScale]))) {
                   [[@(i+1) stringValue] drawAtPoint:CGPointMake(beginIndex-8, step*4+2) withAttributes:nil];
              }
        }
        else {
            [[@(i+1) stringValue] drawAtPoint:CGPointMake(beginIndex-8, step*4+2) withAttributes:nil];
        }
    }
    
    //画纵向
    beginIndex = step;
    for (int i = 0; i < (int)((rect.size.height+step*2)/(step*10)-1); i++) {
        for (int j = 0; j < 9; j++) {
            int horiHeigt = step*2;
            if (i == 0 && j == 0) {
                horiHeigt = step;
            }
            else if (j == 4) {
                horiHeigt = step*2*1.5;
            }
            
            CGContextMoveToPoint(context, 0, beginIndex+j*step);  //起点坐标
            CGContextAddLineToPoint(context, horiHeigt, beginIndex+j*step);   //终点坐标
        }
        
        CGContextMoveToPoint(context, 0, beginIndex+(step*9));  //起点坐标
        CGContextAddLineToPoint(context, step*4, beginIndex+(step*9));   //终点坐标
        
        beginIndex+= (step*10);
        
        // [[@(i+1) stringValue] drawAtPoint:CGPointMake(6, beginIndex-3) withAttributes:nil];
    }
    //最后画纵向的cm数字。旋转90度改成270度
    CGContextRotateCTM(context, -M_PI_2);
    CGContextTranslateCTM(context,-rect.size.width,0);
    
    beginIndex = 0;
    for (int i = 0; i < (int)((rect.size.height+step*2)/(step*10)-1); i++) {
        
        beginIndex += (step*10);
        [[@(i+1) stringValue] drawAtPoint:CGPointMake((rect.size.width-beginIndex-4), step*4+2) withAttributes:nil];
    }

    CGContextStrokePath(context);

}



- (CGPoint)getRotateViewCenter:(UIView *)view {
    return CGPointMake(view.frame.origin.x, view.frame.origin.y);
}

- (void)setCurrentAnchorPoint:(CGRect)frame {
    self.anchorPoint = CGPointMake(frame.origin.x, frame.origin.y);
}

- (CGPoint)getCurrentAnchorPoint:(CGRect)frame {
    return CGPointMake(0, 0); //这边为左上角，即拉伸后左上角坐标是不变的.
}


- (BOOL)isLineType:(CGFloat)value {
    if (value >= -10 && value <= 20) {
        return YES;
    }
    return NO;
}

//触摸开始
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = touches.anyObject;
    CGPoint startPoint = [touch locationInView:self.superview]; //在父坐标系里的坐标
    self.startPoint = startPoint;
    
    self.startTransform = self.transform; //触摸开始前的变换矩阵信息记录，后期旋转等需要在此基础上叠加
    self.rotate = [self getRotateDegreeWithTransform:self.transform];
    self.isResetRotate = YES;
    self.originFrame = CGRectZero;
    
    CGPoint locationPoint = [touch locationInView:self.mainView];
    if (CGRectContainsPoint(self.rotateView.frame, locationPoint)) {                //旋转
        self.locationType = eLocationRotate;
    }
    else if (CGRectContainsPoint(self.scaleView.frame, locationPoint)) {            //拉伸
        self.locationType = eLocationScale;
    }
    else if (CGRectContainsPoint(self.mainView.bounds, locationPoint)){             //移动自身
        self.locationType = eLocationMove;
    }
    else {
        self.locationType = eLocationUnknow;        //其他情况，不处理
    }
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.superview];
    switch (self.locationType) {
        case eLocationRotate:
            [self rotateAction:point sendNow:NO];
            break;
        case eLocationScale:
            [self scaleAction:point sendNow:NO];
            break;
        case eLocationMove:
            [self moveAction:point];
            break;
        default:
            break;
    }
}


//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UITouch* touch = touches.anyObject;
//    CGPoint startPoint = [touch locationInView:self.superview]; //在父坐标系里的坐标
//    self.startPoint = startPoint;
//    
//    
//    self.startTransform = self.transform;
//    self.rotate = [self getRotateDegreeWithTransform:self.transform];
//    self.isResetRotate = YES;
//    self.originFrame = CGRectZero;
//    
//    CGPoint locationPoint = [touch locationInView:self.mainView];
//    if (CGRectContainsPoint(self.rotateView.frame, locationPoint)) {                //旋转
//        self.locationType = eLocationRotate;
//    }
//    else if (CGRectContainsPoint(self.scaleView.frame, locationPoint)) {    //拉伸
//        self.locationType = eLocationScale;
//    }
//    else if (CGRectContainsPoint(self.mainView.bounds, locationPoint)){           //中间
//        self.locationType = eLocationMove;
//    }
//    else {
//        self.locationType = eLocationUnknow;
//    }
//}
//
//
//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UITouch* touch = touches.anyObject;
//    CGPoint point = [touch locationInView:self.superview];
//    switch (self.locationType) {
//        case eLocationRotate:
//            [self rotateAction:point sendNow:NO];
//            break;
//        case eLocationScale:
//            [self scaleAction:point sendNow:NO];
//            break;
//        case eLocationMove:
//            [self moveAction:point];
//            break;
//        default:
//            break;
//    }
//}


- (CGFloat)getAngleScale {
    return tan(_angle/180.0*M_PI);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint locationPoint = point;
    if (!CGRectContainsPoint(self.bounds, point)) {  //点击位置不在自身区域，不处理
        return nil;
    }
    if (locationPoint.y > (self.bounds.size.height-locationPoint.x*[self getAngleScale])) {//点击位置不在三角板显示区域，例如三条边右下角区域，就不处理
        return nil;
    }
    UIView *view = [super hitTest:point withEvent:event]; //判断子view是否处理，例如点击了关闭按钮就由关闭按钮处理。
    return view;
}





-(void)moveAction:(CGPoint)point{
    CGFloat width = point.x-self.startPoint.x;
    CGFloat height = point.y-self.startPoint.y;
    [self moveToNewLocationDeltaX:width DeltaY:height DeltaWidth:0 DeltaHeight:0];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.superview];
    

    switch (self.locationType) {
       case eLocationRotate:
            [self rotateAction:point sendNow:YES];
            break;
        case eLocationScale:
            [self scaleAction:point sendNow:YES];
            break;
        case eLocationMove:
            [self moveAction:point];
            break;
        default:
            break;
    }
    self.locationType = eLocationUnknow;

}

-(CGFloat)widthChanged:(CGPoint)point
{
    return (point.x - self.startPoint.x);
}

-(CGFloat)heightChanged:(CGPoint)point
{
    CGFloat rotate = [self getRotateDegreeWithTransform:self.startTransform];
    return ((point.x - self.startPoint.x) * sin(-rotate) + (point.y - self.startPoint.y) * cos(-rotate));
}

-(void)moveToNewLocationDeltaX:(CGFloat)deltaX DeltaY:(CGFloat)deltaY DeltaWidth:(CGFloat)deltaWidth DeltaHeight:(CGFloat)deltaHeight{
//    CGFloat rotate = [self getRotateDegreeWithTransform:self.startTransform]; //获取当前的旋转角度
//    self.mainView.transform = CGAffineTransformRotate(self.mainView.transform, -rotate); //取消旋转
    if ([NSStringFromCGRect(self.originFrame) isEqualToString:NSStringFromCGRect(CGRectZero)] ) {
        self.originFrame = self.mainView.frame;
    }
//    [self.mainView.layer setAnchorPoint:[self getCurrentAnchorPoint:self.mainView.frame]];
    self.mainView.frame = CGRectMake(self.originFrame.origin.x + deltaX, self.originFrame.origin.y + deltaY,
                                     self.originFrame.size.width + deltaWidth, self.originFrame.size.height + deltaHeight); //设置新的大小。
   // self.mainView.transform = CGAffineTransformRotate(self.mainView.transform, rotate); //恢复旋转角度
   // [self.mainView setNeedsDisplay];
}


static float CalculateLineAngle( CGPoint p1, CGPoint p2 )
{
    float xDis,yDis;
    xDis = p2.x - p1.x;
    yDis = p2.y - p1.y;
    float angle = atan2(yDis, xDis);
    angle = angle / M_PI *180;
    return angle;
}

- (CGFloat)getRotateDegreeWithTransform:(CGAffineTransform)transform {
    CGFloat rotate = atan2(transform.b, transform.a);
    return rotate;
}

-(void)rotateAction:(CGPoint)point sendNow:(BOOL)isSend {
    CGPoint startCenter = CGPointMake(self.mainView.center.x, self.mainView.center.y);
    int degree1 = CalculateLineAngle(startCenter, self.startPoint);
    int degree2 = CalculateLineAngle(startCenter, point);
    CGFloat degree = -(degree1-degree2);
    
    if (self.isResetRotate) {
        CGPoint center = [self getRotateViewCenter:self.mainView];
        CGFloat rotate1 = [self getRotateDegreeWithTransform:self.startTransform];
        if (rotate1 != 0) {
            self.mainView.transform = CGAffineTransformRotate(self.mainView.transform, -rotate1);
            degree *= rotate1;
        }
        if (self.mainView.layer.anchorPoint.x != 0 || self.mainView.layer.anchorPoint.y != 0) {
            [self.mainView.layer setAnchorPoint:CGPointMake(0, 0)];
            self.mainView.center = center;
        }
        self.isResetRotate = NO;
    }
    self.mainView.transform = CGAffineTransformRotate(self.startTransform, degree*M_PI/180.0);
    self.anchorPoint = CGPointZero;
}

//-(void)scaleAction:(CGPoint)point sendNow:(BOOL)isSend {
//    CGFloat scale = point.x/self.startPoint.x;
//    CGAffineTransform newTransform =
//    CGAffineTransformScale(self.startTransform, scale, 1);
//    [self.mainView setTransform:newTransform];
//}

-(void)scaleAction:(CGPoint)point sendNow:(BOOL)isSend {
    CGFloat moveSize = [self widthChanged:point];
    
    if (self.preMoveSize != moveSize) {
        if (self.width+moveSize < 250) { //最小宽度为400，防止太小
            moveSize = 250-self.width;
        }
        if (moveSize != 0) {
            self.preMoveSize = moveSize;
            [self moveToNewLocationDeltaX:0 DeltaY:0 DeltaWidth:moveSize DeltaHeight:moveSize*[self getAngleScale]];
        }
    }

}


-(UIView*)rotateView{
    if (!_rotateView) {
        _rotateView = [[UIImageView alloc] initWithFrame:CGRectMake(45, self.height-140, 45, 45)];
        _rotateView.image = [UIImage imageNamed:@"rotate"];
        _rotateView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return _rotateView;
}

-(UIView*)scaleView{
    if (!_scaleView) {
        _scaleView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-140/tan(self.angle/180.0*M_PI), 40, 45, 45)];
        _scaleView.image = [UIImage imageNamed:@"extend"];
        _scaleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _scaleView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self
                         action:@selector(closeWindow:)
               forControlEvents:UIControlEventTouchUpInside];
        _closeButton.frame = CGRectMake(45, 40, 45, 45);
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _closeButton;
}


@end
