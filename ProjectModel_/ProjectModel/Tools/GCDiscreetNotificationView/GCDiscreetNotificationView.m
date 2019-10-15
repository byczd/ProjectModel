//
//  GCDiscreetNotificationView.m
//  Mtl mobile
//
//  Created by Guillaume Campagna on 09-12-27.
//  Copyright 2009 LittleKiwi. All rights reserved.
//

#import "GCDiscreetNotificationView.h"

const CGFloat GCDiscreetNotificationViewBorderSize = 25;
const CGFloat GCDiscreetNotificationViewPadding = 5;

#define  GCDiscreetNotificationViewHeight (Screen_H == 812 ?40:30)

NSString* const GCShowAnimation = @"show";
NSString* const GCHideAnimation = @"hide";
NSString* const GCChangeProprety = @"changeProprety";

NSString* const GCDiscreetNotificationViewTextKey = @"text";
NSString* const GCDiscreetNotificationViewActivityKey = @"activity";

@interface GCDiscreetNotificationView (){
    BOOL isWindowContentView;//contentview为临时创建在keyWindow上的view，则在hide时需将self.view removefromsuper
}

@property (nonatomic, readonly) CGPoint showingCenter;
@property (nonatomic, readonly) CGPoint hidingCenter;

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, retain) NSDictionary* animationDict;

- (void) show:(BOOL)animated name:(NSString *)name;
- (void) hide:(BOOL)animated name:(NSString *)name;
- (void) showOrHide:(BOOL) hide animated:(BOOL) animated name:(NSString*) name;
- (void) animationDidStop:(NSString *)animationID finished:(BOOL) finished context:(void *) context;

- (void) placeOnGrid;
- (void) changePropretyAnimatedWithKeys:(NSArray*) keys values:(NSArray*) values;

@end

@implementation GCDiscreetNotificationView

@synthesize activityIndicator, presentationMode, label;
@synthesize animating, animationDict;
@synthesize point;

#pragma mark -
#pragma mark Init and dealloc

- (id) initWithText:(NSString *)text inView:(UIView *)aView {
    return [self initWithText:text showActivity:NO inView:aView];
}

- (id)initWithText:(NSString*) text showActivity:(BOOL) activity inView:(UIView*) aView {
    return [self initWithText:text showActivity:activity inPresentationMode:GCDiscreetNotificationViewPresentationModeTop inView:aView];
}

- (id) initWithText:(NSString *)text showActivity:(BOOL)activity 
 inPresentationMode:(GCDiscreetNotificationViewPresentationMode)aPresentationMode inView:(UIView *)aView {
    if ((self = [super initWithFrame:CGRectZero])) {
        if (!aView) {
            //添加全屏背景，可以设置透明度及毛玻璃效果
            UIView *windowView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
            windowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
            [[UIApplication sharedApplication].keyWindow addSubview:windowView];
            self.view=windowView;
            isWindowContentView=YES;
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapBackView)];
            [windowView addGestureRecognizer:tap];
        }
        else{
            isWindowContentView=NO;
            self.view = aView;
        }
        //增加判断aView=nil时创建到当前keyWindow上
        self.textLabel = text;
        self.showActivity = activity;
        self.presentationMode = aPresentationMode;
        
        self.center = self.hidingCenter;
        [self setNeedsLayout];
        
        self.userInteractionEnabled = NO;
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.animating = NO;
    }
    return self;
}

- (id) initWithBotomText:(NSString *)text andColor:(UIColor *)txtColor showActivity:(BOOL)activity inView:(UIView *)aView{
    //activity表示是否显示 菊花加载动画
    if ((self = [self initWithText:text showActivity:activity inPresentationMode:GCDiscreetNotificationViewPresentationModeBottom inView:aView])) {
        self.label.textColor=txtColor;
    }
    return self;
}

- (id) initWithTopText:(NSString *)text andColor:(UIColor *)txtColor showActivity:(BOOL)activity inView:(UIView *)aView{
    if ((self = [self initWithText:text showActivity:activity inPresentationMode:GCDiscreetNotificationViewPresentationModeTop inView:aView])) {
        self.label.textColor=txtColor;
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAnimated) object:nil];
    if (self.view) {
        [self.view removeFromSuperview];
    }
    self.view = nil;
    
    label = nil;
    activityIndicator = nil;
}

-(void)onTapBackView{
    [self hideAnimated];
}

#pragma mark -
#pragma mark Drawing and layout

- (void) layoutSubviews {
    BOOL withActivity = self.activityIndicator != nil;
    CGFloat iActivityWidth=withActivity?GCDiscreetNotificationViewPadding:0;
    CGFloat baseWidth = (2 * GCDiscreetNotificationViewBorderSize) + iActivityWidth;
    CGFloat ibaseHeight=GCDiscreetNotificationViewHeight;
    if (self.presentationMode == GCDiscreetNotificationViewPresentationModeTop || !isWindowContentView) {
        ibaseHeight=30;
    }
    
    CGFloat maxLabelWidth = self.view.frame.size.width - self.activityIndicator.frame.size.width * withActivity - baseWidth;
    CGSize maxLabelSize = CGSizeMake(maxLabelWidth, ibaseHeight);
//    CGFloat textSizeWidth = (self.textLabel != nil) ? [self.textLabel sizeWithFont:self.label.font constrainedToSize:maxLabelSize lineBreakMode:NSLineBreakByTruncatingTail].width : 0; //UILineBreakModeTailTruncation
//    NSLog(@"textSizeWidth-1=%f",textSizeWidth);
//    //sizeWithFont7.0之后不能用了，7.0以后改用以下:
    NSDictionary *attribute = @{NSFontAttributeName:self.label.font};
    CGSize size = [self.textLabel boundingRectWithSize:maxLabelSize options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    CGFloat textSizeWidth=size.width;
//    NSLog(@"textSizeWidth-2=%f",textSizeWidth);
    
    CGFloat activityIndicatorWidth = (self.activityIndicator != nil) ? self.activityIndicator.frame.size.width : 0;
    
    
    CGRect bounds = CGRectMake(0, 0, baseWidth + textSizeWidth + activityIndicatorWidth, ibaseHeight);
    if (!CGRectEqualToRect(self.bounds, bounds)) { //The bounds have changed...
        self.bounds = bounds;
        [self setNeedsDisplay];
    }
    
    CGFloat iLabelH=ibaseHeight;
    if (KD_IsiPhoneX && isWindowContentView && self.presentationMode == GCDiscreetNotificationViewPresentationModeBottom){
        iLabelH=iLabelH-10;//k使iphonex下底部全局tips,label上缩以避开底部条
    };
    if (self.activityIndicator == nil)
        self.label.frame = CGRectMake(GCDiscreetNotificationViewBorderSize, 0, textSizeWidth, iLabelH);
    else {
        self.activityIndicator.frame = CGRectMake(GCDiscreetNotificationViewBorderSize, GCDiscreetNotificationViewPadding, self.activityIndicator.frame.size.width, self.activityIndicator.frame.size.height);
        self.label.frame = CGRectMake(GCDiscreetNotificationViewBorderSize + GCDiscreetNotificationViewPadding + self.activityIndicator.frame.size.width, 0, textSizeWidth, iLabelH);
    }
    
    [self placeOnGrid];
}


- (void) drawRect:(CGRect)rect {
    CGRect myFrame = self.bounds;
    
    CGFloat maxY = 0;
    CGFloat minY = 0;
    
    if (self.presentationMode == GCDiscreetNotificationViewPresentationModeTop) {
        maxY =  CGRectGetMinY(myFrame) - 1;
        minY = CGRectGetMaxY(myFrame);
    }
    else if (self.presentationMode == GCDiscreetNotificationViewPresentationModeBottom) {
        maxY =  CGRectGetMaxY(myFrame) + 1;
        minY = CGRectGetMinY(myFrame);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        return;
    }
    CGFloat firstX=CGRectGetMinX(myFrame);
    CGFloat lastX=CGRectGetMaxX(myFrame);
//    if (KD_IsiPhoneX) {
//        firstX-=20;
//        lastX+=20;
//    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, firstX, maxY);
    CGPathAddCurveToPoint(path, NULL, CGRectGetMinX(myFrame) + GCDiscreetNotificationViewBorderSize, maxY, CGRectGetMinX(myFrame), minY, CGRectGetMinX(myFrame) + GCDiscreetNotificationViewBorderSize, minY);
    CGPathAddLineToPoint(path, NULL, CGRectGetMaxX(myFrame) - GCDiscreetNotificationViewBorderSize, minY);
    CGPathAddCurveToPoint(path, NULL, CGRectGetMaxX(myFrame), minY, CGRectGetMaxX(myFrame) - GCDiscreetNotificationViewBorderSize, maxY, lastX, maxY);
    CGPathCloseSubpath(path);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.8].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGPathRelease(path);
}

#pragma mark -
#pragma mark Show/Hide 

- (void)showAnimated {
    [self show:YES];
}

- (void)hideAnimated {
    [self hide:YES];
    if (isWindowContentView) {
        [self.view removeFromSuperview];
    }
    self.view=nil;//增加此句才能在隐藏时释放，不然会有内存泄漏!!
}

- (void) hideAnimatedAfter:(NSTimeInterval) timeInterval {
   [self performSelector:@selector(hideAnimated) withObject:nil afterDelay:timeInterval]; 
}

- (void)showAndDismissAutomaticallyAnimated {
    [self showAndDismissAfter:1.0];
}

- (void)showAndDismissAfter:(NSTimeInterval)timeInterval {
    [self showAnimated];
    [self hideAnimatedAfter:timeInterval];
}

- (void) show:(BOOL)animated {
    [self show:animated name:GCShowAnimation];
}

- (void) hide:(BOOL)animated {
    [self hide:animated name:GCHideAnimation];
}

- (void) show:(BOOL)animated name:(NSString*) name {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAnimated) object:nil];

    [self showOrHide:NO animated:animated name:name];
}

- (void) hide:(BOOL)animated name:(NSString*) name {
    [self showOrHide:YES animated:animated name:name];
}

- (void) showOrHide:(BOOL)hide animated:(BOOL)animated name:(NSString *)name {
    if ((hide && self.isShowing) || (!hide && !self.isShowing)) {
        if (animated) {
            self.animating = YES;
            [UIView beginAnimations:name context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        }
        
        if (hide) self.center = self.hidingCenter;
        else {
            [self.activityIndicator startAnimating];
            self.center = self.showingCenter;
        }
        
        [self placeOnGrid];
        
        if (animated) [UIView commitAnimations]; 

        self.label.hidden = hide;
    }
}

#pragma mark -
#pragma mark Animations

- (void) animationDidStop:(NSString *)animationID finished:(BOOL) finished context:(void *) context {
    if (animationID == GCHideAnimation) [self.activityIndicator stopAnimating];
    else if (animationID == GCChangeProprety) {
        NSString* showName = GCShowAnimation;
        
        for (NSString* key in [self.animationDict allKeys]) {
            if (key == GCDiscreetNotificationViewActivityKey) {
                self.showActivity = [[self.animationDict objectForKey:key] boolValue];
            }
            else if (key == GCDiscreetNotificationViewTextKey) {
                self.textLabel = [self.animationDict objectForKey:key];
            }
        }
        
        self.animationDict = nil;
        
        [self show:YES name:showName];
    }    
    else if (animationID == GCShowAnimation) {
        if (self.animationDict != nil) [self hide:YES name:GCChangeProprety];
    }
    
    self.animating = NO;
}


#pragma mark -
#pragma mark Getter and setters

- (NSString *) textLabel {
    return self.label.text;
}

- (void) setTextLabel:(NSString *) aText {
    self.label.text = aText;
    [self setNeedsLayout];
}

- (UILabel *)label {
    if (label == nil) {
        label = [[UILabel alloc] init];
        
        label.font = [UIFont boldSystemFontOfSize:15.0];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(0, 1);
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.backgroundColor = [UIColor clearColor];
        
        [self addSubview:label];
    }
    return label;
}

- (BOOL) showActivity {
    return (self.activityIndicator != nil);
}

- (void) setShowActivity:(BOOL) activity {
    if (activity != self.showActivity) {
        if (activity) {
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [self addSubview:activityIndicator];
        }
        else {
            [activityIndicator removeFromSuperview];
            
            activityIndicator = nil;
        }
        
        [self setNeedsLayout];
    }
}

- (void) setView:(UIView *) aView {
    if (self.view != aView) {
        [self removeFromSuperview];
        if(aView)//应该增加一个有效判断，当设置为nil时，无需addsubview:self
            [aView addSubview:self];//将自已填加到指定的aView上
        [self setNeedsLayout];
    }
}

- (UIView *)view {
    return self.superview;
}

- (void) setPresentationMode:(GCDiscreetNotificationViewPresentationMode) newPresentationMode {
    if (presentationMode != newPresentationMode) {        
        BOOL showing = self.isShowing;
        
        presentationMode = newPresentationMode;
        if (presentationMode == GCDiscreetNotificationViewPresentationModeTop) {
            self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
        else if (presentationMode == GCDiscreetNotificationViewPresentationModeBottom) {
            self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        }
        
        self.center = showing ? self.showingCenter : self.hidingCenter;
        
        [self setNeedsDisplay];
        [self placeOnGrid];
    }
}

- (BOOL) isShowing {
    return (self.center.y == self.showingCenter.y);
}

- (CGPoint) showingCenter {
    CGFloat y = 0;
    if (self.presentationMode == GCDiscreetNotificationViewPresentationModeTop) y = 15;
    else if (self.presentationMode == GCDiscreetNotificationViewPresentationModeBottom) y = self.view.frame.size.height - 15;
    return CGPointMake(self.view.frame.size.width / 2, y);
}

- (CGPoint) hidingCenter {
    CGFloat y = 0;
    if (self.presentationMode == GCDiscreetNotificationViewPresentationModeTop) y = - 15;
    else if (self.presentationMode == GCDiscreetNotificationViewPresentationModeBottom) y = 15 + self.view.frame.size.height;
    return CGPointMake(self.view.frame.size.width / 2, y);
}

#pragma mark -
#pragma mark Animated Setters

- (void) setTextLabel:(NSString *)aText animated:(BOOL)animated {
    if (animated && (self.showing || self.animating)) {
        [self changePropretyAnimatedWithKeys:[NSArray arrayWithObject:GCDiscreetNotificationViewTextKey]
                                      values:[NSArray arrayWithObject:aText]];
    }
    else self.textLabel = aText;
}

- (void) setShowActivity:(BOOL)activity animated:(BOOL)animated {
    if (animated && (self.showing || self.animating)) {
        [self changePropretyAnimatedWithKeys:[NSArray arrayWithObject:GCDiscreetNotificationViewActivityKey]
                                      values:[NSArray arrayWithObject:[NSNumber numberWithBool:activity]]];
    }
    else self.showActivity = activity;
}

- (void) setTextLabel:(NSString *)aText andSetShowActivity:(BOOL)activity animated:(BOOL)animated {
    if (animated && (self.showing || self.animating)) {
        [self changePropretyAnimatedWithKeys:[NSArray arrayWithObjects:GCDiscreetNotificationViewTextKey, GCDiscreetNotificationViewActivityKey, nil]
                                      values:[NSArray arrayWithObjects:aText, [NSNumber numberWithBool:activity], nil]];
    }
    else {
        self.textLabel = aText;
        self.showActivity = activity;
    }
}

#pragma mark -
#pragma mark Helper Methods

- (void) placeOnGrid {
    CGRect frame = self.frame;
    
    frame.origin.x = roundf(frame.origin.x);
    frame.origin.y = roundf(frame.origin.y);

//    if (self.point.x == 0) {
//        frame.origin.x += self.point.x;
//        frame.origin.y += self.point.y;
//    }
    
    self.frame = frame;

}

- (void) changePropretyAnimatedWithKeys:(NSArray*) keys values:(NSArray*) values {
    NSDictionary* newDict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    if (self.animationDict == nil) {
        self.animationDict = newDict;
    }
    else {
        NSMutableDictionary* mutableAnimationDict = [self.animationDict mutableCopy];
        [mutableAnimationDict addEntriesFromDictionary:newDict];
        self.animationDict = mutableAnimationDict;
    }
    
    if (!self.animating) [self hide:YES name:GCChangeProprety];
}

#pragma mark - UIView subclass

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) self.animationDict = nil;
}

@end
