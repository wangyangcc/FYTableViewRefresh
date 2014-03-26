//
//  FYHeaderRefresh.m
//  FYTableViewRefresh
//
//  Created by wang yangyang on 14-3-25.
//  Copyright (c) 2014年 wang yangyang. All rights reserved.
//

#import "FYHeaderRefresh.h"

typedef enum {
    FYHeaderRefreshStateHidden = 11,
    FYHeaderRefreshStatePulling,
    FYHeaderRefreshStateReady,
    FYHeaderRefreshStateRefreshing
} FYHeaderRefreshState;

@interface FYHeaderRefresh ()
{
    UILabel *textLabel;
    UIActivityIndicatorView *spinner;
    CAShapeLayer *circleLayer;
    UIColor *defaultTintColor;
    CGFloat originalTopContentInset;
    CGFloat decelerationStartOffset;
}

@property (nonatomic) FYHeaderRefreshState refreshControlState;

@end

@implementation FYHeaderRefresh

- (id)init
{

    if (self = [super init])
    {
        [self commonInit];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
        
        if ([aDecoder containsValueForKey:@"UITintColor"])
        {
            self.tintColor = (UIColor *)[aDecoder decodeObjectForKey:@"UITintColor"];
            defaultTintColor = self.tintColor;
        }
        
        if ([aDecoder containsValueForKey:@"UIAttributedTitle"])
            self.attributedTitle = [aDecoder decodeObjectForKey:@"UIAttributedTitle"];
        
    }
    return self;
}

- (void) commonInit
{
    self.frame = CGRectMake(0, 0, 320, 60);
    [self populateSubviews];
    [self setRefreshControlState:FYHeaderRefreshStateHidden];
    defaultTintColor = [UIColor colorWithWhite:0.5 alpha:1];
}

- (void)populateSubviews {
  
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.frame = CGRectMake(0, -13, 25.0f, 25.0f);
    circle.contentsGravity = kCAGravityCenter;
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:circle.position
                                                              radius:CGRectGetMidX(circle.bounds)
                                                          startAngle:0
                                                            endAngle:(360) / 180.0 * M_PI
                                                           clockwise:NO];
    circle.path = circlePath.CGPath;
    
    circle.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    circle.fillColor = [UIColor whiteColor].CGColor;
    circle.strokeColor = [UIColor colorWithRed:0.79 green:0.12 blue:0.15 alpha:1.0].CGColor;
    circle.lineWidth =2.0f;
    circle.strokeEnd = 0.0f;
    [[self layer] addSublayer:circle];
    circleLayer = circle;
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textLabel.text = @"开始刷新咯";
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    textLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    textLabel.textColor = [UIColor blackColor];//[UIColor colorWithWhite:0.5 alpha:1];
    [self addSubview:textLabel];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = (CGPoint){
        .x = CGRectGetMidX(self.bounds),
        .y = CGRectGetMidY(self.bounds)
    };
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleTopMargin |
                                UIViewAutoresizingFlexibleBottomMargin);
    [self addSubview:spinner];
}

- (void)beginRefreshing {
    _refreshing = YES;
    [self setRefreshControlState:FYHeaderRefreshStateRefreshing];
}

- (void)endRefreshing {
    _refreshing = NO;
    [self setRefreshControlState:FYHeaderRefreshStateHidden];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSString *text = @"jijijijij";//self.attributedTitle.string;
    CGPoint center =(CGPoint){
        .x = CGRectGetMidX(self.bounds),
        .y = CGRectGetMidY(self.bounds)
    };
    
    if (text.length > 0) {
        CGPoint newArrowCenter = (CGPoint){.x = center.x, .y = center.y - 10};
        //arrow.center = spinner.center = newArrowCenter;
        textLabel.frame = (CGRect){
            .origin.x = 0,
            .origin.y = CGRectGetMaxY(self.bounds) - 27,
            .size.width = CGRectGetWidth(self.bounds),
            .size.height = 20
        };
    }
    else {
        //arrow.center = spinner.center = center;
        textLabel.frame = CGRectZero;
    }
}

- (void)setRefreshControlState:(FYHeaderRefreshState)refreshControlStateS {
    
    _refreshControlState = refreshControlStateS;
    switch (refreshControlStateS) {
        case FYHeaderRefreshStateHidden:
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 0.0;
            }];
            break;
        }
            
        case FYHeaderRefreshStatePulling:
        case FYHeaderRefreshStateReady:
            self.alpha = 1.0;
            circleLayer.opacity = 1.0;
            textLabel.alpha = 1.0;
            break;
            
        case FYHeaderRefreshStateRefreshing:
            self.alpha = 1.0;
            [UIView animateWithDuration: 0.2
                             animations:^{
                                 circleLayer.opacity = 0.0;
                                 textLabel.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [spinner startAnimating];
                             }];
            break;
    };
    
    
    
    UIEdgeInsets contentInset = UIEdgeInsetsMake(originalTopContentInset, 0, 0, 0);
    if (refreshControlStateS == FYHeaderRefreshStateRefreshing) {
        contentInset = UIEdgeInsetsMake(self.frame.size.height + originalTopContentInset, 0, 0, 0);
    }
    else {
        [spinner stopAnimating];
    }
    
    
    UIScrollView *scrollView = nil;
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView *)self.superview;
    }
    NSLog(@"-----insets---%@",NSStringFromUIEdgeInsets(contentInset));
    if(!UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, contentInset)) {
        [UIView animateWithDuration:0.2 animations:^{
            scrollView.contentInset = contentInset;
        }];
    }
    
}

static void *contentOffsetObservingKey = &contentOffsetObservingKey;

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:contentOffsetObservingKey];
}

- (void)didMoveToSuperview {
    UIView *superview = self.superview;
    
    // Reposition ourself in the scrollview
    if ([superview isKindOfClass:[UIScrollView class]]) {
        [self repositionAboveContent];
        
        [superview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld context:contentOffsetObservingKey];
        
        originalTopContentInset = [(UIScrollView *)superview contentInset].top;
    }
    [self.superview sendSubviewToBack:self];
}

- (void)repositionAboveContent {
    CGRect scrollBounds = self.superview.bounds;
    CGFloat height = self.bounds.size.height;
    CGRect newFrame = (CGRect){
        .origin.x = 0,
        .origin.y = [(UIScrollView *)self.superview contentOffset].y,
        .size.width = scrollBounds.size.width,
        .size.height = height
    };
    self.frame = newFrame;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != contentOffsetObservingKey) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    if ([self.superview isKindOfClass:[UIScrollView class]] == NO) {
        return;
    }
    UIScrollView *scrollview = (UIScrollView *)self.superview;
    CGFloat pullHeight = -scrollview.contentOffset.y - originalTopContentInset;
    CGFloat triggerHeight = self.bounds.size.height;
    CGFloat previousPullHeight = -[change[NSKeyValueChangeOldKey] CGPointValue].y;
    
    // Update the progress arrow
    CGFloat progress = pullHeight / triggerHeight;
    CGFloat deadZone = 0.3;
    if (progress > deadZone) {
        CGFloat arrowProgress = ((progress - deadZone) / (1 - deadZone));
        circleLayer.strokeEnd = arrowProgress;
    }
    else {
        circleLayer.strokeEnd = 0.0;
    }
    
    
    // Track when deceleration starts
    if (scrollview.isDecelerating == NO) {
        decelerationStartOffset = 0;
    }
    else if (scrollview.isDecelerating && decelerationStartOffset == 0) {
        decelerationStartOffset = scrollview.contentOffset.y;
    }
    
    
    // Transition to the next state
    if (self.refreshControlState == FYHeaderRefreshStateRefreshing) {
        // Adjust inset to make sure potential header view is shown correctly if user pulls down scroll view while in refreshing state
        CGFloat offset = MAX(scrollview.contentOffset.y * -1, 0);
		offset = MIN(offset, self.bounds.size.height);
		scrollview.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
    }
    else if (decelerationStartOffset > 0) {
        // Deceleration started before reaching the header 'rubber band' area; hide the refresh control
        self.refreshControlState = FYHeaderRefreshStateHidden;
    }
    else if (pullHeight >= triggerHeight || (pullHeight > 0 && previousPullHeight >= triggerHeight)) {
        
        if (scrollview.isDragging) {
            // Just waiting for them to let go, then we'll refresh
            self.refreshControlState = FYHeaderRefreshStateReady;
        }
        else if (([self allControlEvents] & UIControlEventValueChanged) == 0) {
            NSLog(@"No action configured for UIControlEventValueChanged event, not transitioning to refreshing state");
        }
        else {
            // They let go! Refresh!
            self.refreshControlState = FYHeaderRefreshStateRefreshing;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
    else if (scrollview.decelerating == NO && pullHeight > 0) {
        self.refreshControlState = FYHeaderRefreshStatePulling;
    }
    else {
        self.refreshControlState = FYHeaderRefreshStateHidden;
    }
    
    [self repositionAboveContent];
}

@end
