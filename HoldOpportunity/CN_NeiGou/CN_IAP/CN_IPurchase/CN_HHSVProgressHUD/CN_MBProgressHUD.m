//
// PN_MBProgressHUD.m
// Version 1.2.0
// Created by Matej Bukovinski on 2.4.09.
//

#import "CN_MBProgressHUD.h"
#import <tgmath.h>
#import "CN_HudManager.h"

#define MBMainThreadAssert() NSAssert([NSThread isMainThread], @"PN_MBProgressHUD needs to be accessed on the main thread.");

CGFloat const PN_MBProgressMaxOffset = 1000000.f;

static const CGFloat PN_MBDefaultPadding = 4.f;
static const CGFloat PN_MBDefaultLabelFontSize = 16.f;
static const CGFloat PN_MBDefaultDetailsLabelFontSize = 16.f;


@interface CN_MBProgressHUD ()

@property (nonatomic, assign) BOOL PN_useAnimation;
@property (nonatomic, assign, getter=hasFinished) BOOL PN_finished;
@property (nonatomic, strong) UIView *PN_indicator;
@property (nonatomic, strong) NSDate *PN_showStarted;
@property (nonatomic, strong) NSArray *PN_paddingConstraints;
@property (nonatomic, strong) NSArray *PN_bezelConstraints;
@property (nonatomic, strong) UIView *PN_topSpacer;
@property (nonatomic, strong) UIView *PN_bottomSpacer;
@property (nonatomic, strong) UIMotionEffectGroup *PN_bezelMotionEffects;
@property (nonatomic, weak) NSTimer *PN_graceTimer;
@property (nonatomic, weak) NSTimer *PN_minShowTimer;
@property (nonatomic, weak) NSTimer *PN_hideDelayTimer;
@property (nonatomic, weak) CADisplayLink *PN_progressObjectDisplayLink;

@end


@interface CN_MBProgressHUDRoundedButton : UIButton
@end


@implementation CN_MBProgressHUD

#pragma mark - Class methods

+ (instancetype)MN_showHUDAddedTo:(UIView *)PN_view MN_animated:(BOOL)animated {
    CN_MBProgressHUD *PN_hud = [[self alloc] initWithView:PN_view];
    PN_hud.PN_removeFromSuperViewOnHide = YES;
    [PN_view addSubview:PN_hud];
    [PN_hud MN_showAnimated:animated];
    return PN_hud;
}

+ (BOOL)MN_hideHUDForView:(UIView *)view MN_animated:(BOOL)animated {
    CN_MBProgressHUD *PN_hud = [self MN_HUDForView:view];
    if (PN_hud != nil) {
        PN_hud.PN_removeFromSuperViewOnHide = YES;
        [PN_hud MN_hideAnimated:animated];
        return YES;
    }
    return NO;
}

+ (CN_MBProgressHUD *)MN_HUDForView:(UIView *)view {
    NSEnumerator *PN_subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *PN_subview in PN_subviewsEnum) {
        if ([PN_subview isKindOfClass:self]) {
            CN_MBProgressHUD *PN_hud = (CN_MBProgressHUD *)PN_subview;
            if (PN_hud.hasFinished == NO) {
                return PN_hud;
            }
        }
    }
    return nil;
}

#pragma mark - Lifecycle

- (void)MN_commonInit {
    // Set default values for properties
    _PN_animationType = PN_MBProgressHUDAnimationFade;
    _PN_mode = PN_MBProgressHUDModeIndeterminate;
    _PN_margin = 20.0f;
    _PN_defaultMotionEffectsEnabled = NO;

    if (@available(iOS 13.0, tvOS 13, *)) {
       _PN_contentColor = [[UIColor labelColor] colorWithAlphaComponent:0.7f];
    } else {
        _PN_contentColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    }

    // Transparent background
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    // Make it invisible for now
    self.alpha = 0.0f;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.layer.allowsGroupOpacity = NO;

    [self MN_setupViews];
    [self updateIndicators];
    [self registerForNotifications];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self MN_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self MN_commonInit];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}

- (void)dealloc {
    [self unregisterFromNotifications];
}

#pragma mark - Show & hide

- (void)MN_showAnimated:(BOOL)animated {
    MBMainThreadAssert();
    [self.PN_minShowTimer invalidate];
    self.PN_useAnimation = animated;
    self.PN_finished = NO;
    // If the grace time is set, postpone the HUD display
    if (self.PN_graceTime > 0.0) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.PN_graceTime target:self selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.PN_graceTimer = timer;
    }
    // ... otherwise show the HUD immediately
    else {
        [self showUsingAnimation:self.PN_useAnimation];
    }
}

- (void)MN_hideAnimated:(BOOL)animated {
    MBMainThreadAssert();
    [self.PN_graceTimer invalidate];
    self.PN_useAnimation = animated;
    self.PN_finished = YES;
    // If the minShow time is set, calculate how long the HUD was shown,
    // and postpone the hiding operation if necessary
    if (self.PN_minShowTime > 0.0 && self.PN_showStarted) {
        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:self.PN_showStarted];
        if (interv < self.PN_minShowTime) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:(self.PN_minShowTime - interv) target:self selector:@selector(handleMinShowTimer:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            self.PN_minShowTimer = timer;
            return;
        }
    }
    [CN_HudManager MN_share].PN_loadingWindow.hidden = YES;
    // ... otherwise hide the HUD immediately
    [self hideUsingAnimation:self.PN_useAnimation];
}

- (void)MN_hideAnimated:(BOOL)animated MN_afterDelay:(NSTimeInterval)delay {
    // Cancel any scheduled hideAnimated:afterDelay: calls
    [self.PN_hideDelayTimer invalidate];

    NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(handleHideTimer:) userInfo:@(animated) repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.PN_hideDelayTimer = timer;
}

#pragma mark - Timer callbacks

- (void)handleGraceTimer:(NSTimer *)theTimer {
    // Show the HUD only if the task is still running
    if (!self.hasFinished) {
        [self showUsingAnimation:self.PN_useAnimation];
    }
}

- (void)handleMinShowTimer:(NSTimer *)theTimer {
    [self hideUsingAnimation:self.PN_useAnimation];
}

- (void)handleHideTimer:(NSTimer *)timer {
    [self MN_hideAnimated:[timer.userInfo boolValue]];
}

#pragma mark - View Hierrarchy

- (void)didMoveToSuperview {
    [self updateForCurrentOrientationAnimated:NO];
}

#pragma mark - Internal show & hide operations

- (void)showUsingAnimation:(BOOL)animated {
    // Cancel any previous animations
    [self.PN_bezelView.layer removeAllAnimations];
    [self.PN_backgroundView.layer removeAllAnimations];

    // Cancel any scheduled hideAnimated:afterDelay: calls
    [self.PN_hideDelayTimer invalidate];

    self.PN_showStarted = [NSDate date];
    self.alpha = 1.f;

    // Needed in case we hide and re-show with the same NSProgress object attached.
    [self setNSProgressDisplayLinkEnabled:YES];

    // Set up motion effects only at this point to avoid needlessly
    // creating the effect if it was disabled after initialization.
    [self updateBezelMotionEffects];

    if (animated) {
        [self animateIn:YES withType:self.PN_animationType completion:NULL];
    } else {
        self.PN_bezelView.alpha = 1.f;
        self.PN_backgroundView.alpha = 1.f;
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    // Cancel any scheduled hideAnimated:afterDelay: calls.
    // This needs to happen here instead of in done,
    // to avoid races if another hideAnimated:afterDelay:
    // call comes in while the HUD is animating out.
    [self.PN_hideDelayTimer invalidate];

    if (animated && self.PN_showStarted) {
        self.PN_showStarted = nil;
        [self animateIn:NO withType:self.PN_animationType completion:^(BOOL finished) {
            [self done];
        }];
    } else {
        self.PN_showStarted = nil;
        self.PN_bezelView.alpha = 0.f;
        self.PN_backgroundView.alpha = 1.f;
        [self done];
    }
}

- (void)animateIn:(BOOL)animatingIn withType:(PN_MBProgressHUDAnimation)type completion:(void(^)(BOOL finished))completion {
    // Automatically determine the correct zoom animation type
    if (type == PN_MBProgressHUDAnimationZoom) {
        type = animatingIn ? PN_MBProgressHUDAnimationZoomIn : PN_MBProgressHUDAnimationZoomOut;
    }

    CGAffineTransform small = CGAffineTransformMakeScale(0.5f, 0.5f);
    CGAffineTransform large = CGAffineTransformMakeScale(1.5f, 1.5f);

    // Set starting state
    UIView *bezelView = self.PN_bezelView;
    if (animatingIn && bezelView.alpha == 0.f && type == PN_MBProgressHUDAnimationZoomIn) {
        bezelView.transform = small;
    } else if (animatingIn && bezelView.alpha == 0.f && type == PN_MBProgressHUDAnimationZoomOut) {
        bezelView.transform = large;
    }

    // Perform animations
    dispatch_block_t animations = ^{
        if (animatingIn) {
            bezelView.transform = CGAffineTransformIdentity;
        } else if (!animatingIn && type == PN_MBProgressHUDAnimationZoomIn) {
            bezelView.transform = large;
        } else if (!animatingIn && type == PN_MBProgressHUDAnimationZoomOut) {
            bezelView.transform = small;
        }
        CGFloat alpha = animatingIn ? 1.f : 0.f;
        bezelView.alpha = alpha;
        self.PN_backgroundView.alpha = alpha;
    };
    [UIView animateWithDuration:0.3 delay:0. usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
}

- (void)done {
    [self setNSProgressDisplayLinkEnabled:NO];

    if (self.hasFinished) {
        self.alpha = 0.0f;
        if (self.PN_removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        }
    }
    CN_MBProgressHUDCompletionBlock completionBlock = self.PN_completionBlock;
    if (completionBlock) {
        completionBlock();
    }
    id<CN_MBProgressHUDDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(hudWasHidden:)]) {
        [delegate performSelector:@selector(hudWasHidden:) withObject:self];
    }
}

#pragma mark - UI

- (void)MN_setupViews {
    UIColor *defaultColor = self.PN_contentColor;

    CN_MBBackgroundView *PN_backgroundView = [[CN_MBBackgroundView alloc] initWithFrame:self.bounds];
    PN_backgroundView.PN_style = PN_MBProgressHUDBackgroundStyleSolidColor;
    PN_backgroundView.backgroundColor = [UIColor clearColor];
    PN_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    PN_backgroundView.alpha = 0.f;
    [self addSubview:PN_backgroundView];
    _PN_backgroundView = PN_backgroundView;

    CN_MBBackgroundView *PN_bezelView = [CN_MBBackgroundView new];
    PN_bezelView.translatesAutoresizingMaskIntoConstraints = NO;
    PN_bezelView.layer.cornerRadius = 5.f;
    PN_bezelView.alpha = 0.f;
    [self addSubview:PN_bezelView];
    _PN_bezelView = PN_bezelView;

    UILabel *PN_label = [UILabel new];
    PN_label.adjustsFontSizeToFitWidth = NO;
    PN_label.textAlignment = NSTextAlignmentCenter;
    PN_label.textColor = defaultColor;
    PN_label.font = [UIFont boldSystemFontOfSize:PN_MBDefaultLabelFontSize];
    PN_label.opaque = NO;
    PN_label.backgroundColor = [UIColor clearColor];
    _PN_label = PN_label;

    UILabel *PN_detailsLabel = [UILabel new];
    PN_detailsLabel.adjustsFontSizeToFitWidth = NO;
    PN_detailsLabel.textAlignment = NSTextAlignmentCenter;
    PN_detailsLabel.textColor = defaultColor;
    PN_detailsLabel.numberOfLines = 0;
    PN_detailsLabel.font = [UIFont boldSystemFontOfSize:PN_MBDefaultDetailsLabelFontSize];
    PN_detailsLabel.opaque = NO;
    PN_detailsLabel.backgroundColor = [UIColor clearColor];
    _PN_detailsLabel = PN_detailsLabel;

    UIButton *PN_button = [CN_MBProgressHUDRoundedButton buttonWithType:UIButtonTypeCustom];
    PN_button.titleLabel.textAlignment = NSTextAlignmentCenter;
    PN_button.titleLabel.font = [UIFont boldSystemFontOfSize:PN_MBDefaultDetailsLabelFontSize];
    [PN_button setTitleColor:defaultColor forState:UIControlStateNormal];
    _PN_button = PN_button;

    for (UIView *PN_view in @[PN_label, PN_detailsLabel, PN_button]) {
        PN_view.translatesAutoresizingMaskIntoConstraints = NO;
        [PN_view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
        [PN_view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        [PN_bezelView addSubview:PN_view];
    }

    UIView *PN_topSpacer = [UIView new];
    PN_topSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    PN_topSpacer.hidden = YES;
    [PN_bezelView addSubview:PN_topSpacer];
    _PN_topSpacer = PN_topSpacer;

    UIView *PN_bottomSpacer = [UIView new];
    PN_bottomSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    PN_bottomSpacer.hidden = YES;
    [PN_bezelView addSubview:PN_bottomSpacer];
    _PN_bottomSpacer = PN_bottomSpacer;
}

- (void)updateIndicators {
    UIView *PN_indicator = self.PN_indicator;
    BOOL PN_isActivityIndicator = [PN_indicator isKindOfClass:[UIActivityIndicatorView class]];
    BOOL PN_isRoundIndicator = [PN_indicator isKindOfClass:[MBRoundProgressView class]];

    PN_MBProgressHUDMode PN_mode = self.PN_mode;
    if (PN_mode == PN_MBProgressHUDModeIndeterminate) {
        if (!PN_isActivityIndicator) {
            // Update to indeterminate indicator
            UIActivityIndicatorView *activityIndicator;
            [PN_indicator removeFromSuperview];
#if !TARGET_OS_MACCATALYST
            if (@available(iOS 13.0, tvOS 13.0, *)) {
#endif
                activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
                activityIndicator.color = [UIColor whiteColor];
#if !TARGET_OS_MACCATALYST
            } else {
               activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            }
#endif
            [activityIndicator startAnimating];
            PN_indicator = activityIndicator;
            [self.PN_bezelView addSubview:PN_indicator];
        }
    }
    else if (PN_mode == PN_MBProgressHUDModeDeterminateHorizontalBar) {
        // Update to bar determinate indicator
        [PN_indicator removeFromSuperview];
        PN_indicator = [[CN_MBBarProgressView alloc] init];
        [self.PN_bezelView addSubview:PN_indicator];
    }
    else if (PN_mode == PN_MBProgressHUDModeDeterminate || PN_mode == PN_MBProgressHUDModeAnnularDeterminate) {
        if (!PN_isRoundIndicator) {
            // Update to determinante indicator
            [PN_indicator removeFromSuperview];
            PN_indicator = [[MBRoundProgressView alloc] init];
            [self.PN_bezelView addSubview:PN_indicator];
        }
        if (PN_mode == PN_MBProgressHUDModeAnnularDeterminate) {
            [(MBRoundProgressView *)PN_indicator setPN_annular:YES];
        }
    }
    else if (PN_mode == PN_MBProgressHUDModeCustomView && self.customView != PN_indicator) {
        // Update custom view indicator
        [PN_indicator removeFromSuperview];
        PN_indicator = self.customView;
        [self.PN_bezelView addSubview:PN_indicator];
    }
    else if (PN_mode == PN_MBProgressHUDModeText) {
        [PN_indicator removeFromSuperview];
        PN_indicator = nil;
    }
    PN_indicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.PN_indicator = PN_indicator;

    if ([PN_indicator respondsToSelector:@selector(setPN_progress:)]) {
        [(id)PN_indicator setValue:@(self.PN_progress) forKey:@"progress"];
    }

    [PN_indicator setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
    [PN_indicator setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];

    [self MN_updateViewsForColor:self.PN_contentColor];
    [self setNeedsUpdateConstraints];
}

- (void)MN_updateViewsForColor:(UIColor *)color {
    if (!color) return;

    self.PN_label.textColor = color;
    self.PN_detailsLabel.textColor = color;
    [self.PN_button setTitleColor:color forState:UIControlStateNormal];

    // UIAppearance settings are prioritized. If they are preset the set color is ignored.

    UIView *PN_indicator = self.PN_indicator;
    if ([PN_indicator isKindOfClass:[UIActivityIndicatorView class]]) {
        UIActivityIndicatorView *appearance = nil;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 90000
        appearance = [UIActivityIndicatorView appearanceWhenContainedIn:[PN_MBProgressHUD class], nil];
#else
        // For iOS 9+
        appearance = [UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[CN_MBProgressHUD class]]];
#endif

        if (appearance.color == nil) {
            ((UIActivityIndicatorView *)PN_indicator).color = color;
        }
    } else if ([PN_indicator isKindOfClass:[MBRoundProgressView class]]) {
        MBRoundProgressView *appearance = nil;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 90000
        appearance = [MBRoundProgressView appearanceWhenContainedIn:[PN_MBProgressHUD class], nil];
#else
        appearance = [MBRoundProgressView appearanceWhenContainedInInstancesOfClasses:@[[CN_MBProgressHUD class]]];
#endif
        if (appearance.PN_progressTintColor == nil) {
            ((MBRoundProgressView *)PN_indicator).PN_progressTintColor = color;
        }
        if (appearance.PN_backgroundTintColor == nil) {
            ((MBRoundProgressView *)PN_indicator).PN_backgroundTintColor = [color colorWithAlphaComponent:0.1];
        }
    } else if ([PN_indicator isKindOfClass:[CN_MBBarProgressView class]]) {
        CN_MBBarProgressView *appearance = nil;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 90000
        appearance = [MBBarProgressView appearanceWhenContainedIn:[PN_MBProgressHUD class], nil];
#else
        appearance = [CN_MBBarProgressView appearanceWhenContainedInInstancesOfClasses:@[[CN_MBProgressHUD class]]];
#endif
        if (appearance.PN_progressColor == nil) {
            ((CN_MBBarProgressView *)PN_indicator).PN_progressColor = color;
        }
        if (appearance.PN_lineColor == nil) {
            ((CN_MBBarProgressView *)PN_indicator).PN_lineColor = color;
        }
    } else {
        [PN_indicator setTintColor:color];
    }
}

- (void)updateBezelMotionEffects {
    CN_MBBackgroundView *bezelView = self.PN_bezelView;
    UIMotionEffectGroup *bezelMotionEffects = self.PN_bezelMotionEffects;

    if (self.PN_defaultMotionEffectsEnabled && !bezelMotionEffects) {
        CGFloat effectOffset = 10.f;
        UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        effectX.maximumRelativeValue = @(effectOffset);
        effectX.minimumRelativeValue = @(-effectOffset);

        UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        effectY.maximumRelativeValue = @(effectOffset);
        effectY.minimumRelativeValue = @(-effectOffset);

        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[effectX, effectY];

        self.PN_bezelMotionEffects = group;
        [bezelView addMotionEffect:group];
    } else if (bezelMotionEffects) {
        self.PN_bezelMotionEffects = nil;
        [bezelView removeMotionEffect:bezelMotionEffects];
    }
}

#pragma mark - Layout

- (void)updateConstraints {
    UIView *bezel = self.PN_bezelView;
    UIView *topSpacer = self.PN_topSpacer;
    UIView *bottomSpacer = self.PN_bottomSpacer;
    CGFloat margin = self.PN_margin;
    NSMutableArray *bezelConstraints = [NSMutableArray array];
    NSDictionary *metrics = @{@"margin": @(margin)};

    NSMutableArray *subviews = [NSMutableArray arrayWithObjects:self.PN_topSpacer, self.PN_label, self.PN_detailsLabel, self.PN_button, self.PN_bottomSpacer, nil];
    if (self.PN_indicator) [subviews insertObject:self.PN_indicator atIndex:1];

    // Remove existing constraints
    [self removeConstraints:self.constraints];
    [topSpacer removeConstraints:topSpacer.constraints];
    [bottomSpacer removeConstraints:bottomSpacer.constraints];
    if (self.PN_bezelConstraints) {
        [bezel removeConstraints:self.PN_bezelConstraints];
        self.PN_bezelConstraints = nil;
    }

    // Center bezel in container (self), applying the offset if set
    CGPoint offset = self.PN_offset;
    NSMutableArray *centeringConstraints = [NSMutableArray array];
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:offset.x]];
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:offset.y]];
    [self applyPriority:998.f toConstraints:centeringConstraints];
    [self addConstraints:centeringConstraints];

    // Ensure minimum side margin is kept
    NSMutableArray *sideConstraints = [NSMutableArray array];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=margin)-[bezel]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel)]];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=margin)-[bezel]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel)]];
    [self applyPriority:999.f toConstraints:sideConstraints];
    [self addConstraints:sideConstraints];

    // Minimum bezel size, if set
    CGSize minimumSize = self.PN_minSize;
    if (!CGSizeEqualToSize(minimumSize, CGSizeZero)) {
        NSMutableArray *minSizeConstraints = [NSMutableArray array];
        [minSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.width]];
        [minSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.height]];
        [self applyPriority:997.f toConstraints:minSizeConstraints];
        [bezelConstraints addObjectsFromArray:minSizeConstraints];
    }

    // Square aspect ratio, if set
    if (self.PN_square) {
        NSLayoutConstraint *square = [NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeWidth multiplier:1.f constant:0];
        square.priority = 997.f;
        [bezelConstraints addObject:square];
    }

    // Top and bottom spacing
    [topSpacer addConstraint:[NSLayoutConstraint constraintWithItem:topSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin]];
    [bottomSpacer addConstraint:[NSLayoutConstraint constraintWithItem:bottomSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin]];
    // Top and bottom spaces should be equal
    [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:topSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:bottomSpacer attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f]];

    // Layout subviews in bezel
    NSMutableArray *paddingConstraints = [NSMutableArray new];
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        // Center in bezel
        [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
        // Ensure the minimum edge margin is kept
        [bezelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=margin)-[view]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
        // Element spacing
        if (idx == 0) {
            // First, ensure spacing to bezel edge
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        } else if (idx == subviews.count - 1) {
            // Last, ensure spacing to bezel edge
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f]];
        }
        if (idx > 0) {
            // Has previous
            NSLayoutConstraint *padding = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
            [bezelConstraints addObject:padding];
            [paddingConstraints addObject:padding];
        }
    }];

    [bezel addConstraints:bezelConstraints];
    self.PN_bezelConstraints = bezelConstraints;

    self.PN_paddingConstraints = [paddingConstraints copy];
    [self updatePaddingConstraints];

    [super updateConstraints];
}

- (void)layoutSubviews {
    // There is no need to update constraints if they are going to
    // be recreated in [super layoutSubviews] due to needsUpdateConstraints being set.
    // This also avoids an issue on iOS 8, where updatePaddingConstraints
    // would trigger a zombie object access.
    if (!self.needsUpdateConstraints) {
        [self updatePaddingConstraints];
    }
    [super layoutSubviews];
}

- (void)updatePaddingConstraints {
    // Set padding dynamically, depending on whether the view is visible or not
    __block BOOL hasVisibleAncestors = NO;
    [self.PN_paddingConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *padding, NSUInteger idx, BOOL *stop) {
        UIView *firstView = (UIView *)padding.firstItem;
        UIView *secondView = (UIView *)padding.secondItem;
        BOOL firstVisible = !firstView.hidden && !CGSizeEqualToSize(firstView.intrinsicContentSize, CGSizeZero);
        BOOL secondVisible = !secondView.hidden && !CGSizeEqualToSize(secondView.intrinsicContentSize, CGSizeZero);
        // Set if both views are visible or if there's a visible view on top that doesn't have padding
        // added relative to the current view yet
        padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? PN_MBDefaultPadding : 0.f;
        hasVisibleAncestors |= secondVisible;
    }];
}

- (void)applyPriority:(UILayoutPriority)priority toConstraints:(NSArray *)constraints {
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.priority = priority;
    }
}

#pragma mark - Properties

- (void)setPN_mode:(PN_MBProgressHUDMode)mode {
    if (mode != _PN_mode) {
        _PN_mode = mode;
        [self updateIndicators];
    }
}

- (void)setCustomView:(UIView *)customView {
    if (customView != _customView) {
        _customView = customView;
        if (self.PN_mode == PN_MBProgressHUDModeCustomView) {
            [self updateIndicators];
        }
    }
}

- (void)setPN_offset:(CGPoint)offset {
    if (!CGPointEqualToPoint(offset, _PN_offset)) {
        _PN_offset = offset;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setPN_margin:(CGFloat)margin {
    if (margin != _PN_margin) {
        _PN_margin = margin;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setPN_minSize:(CGSize)minSize {
    if (!CGSizeEqualToSize(minSize, _PN_minSize)) {
        _PN_minSize = minSize;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setPN_square:(BOOL)square {
    if (square != _PN_square) {
        _PN_square = square;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setPN_progressObjectDisplayLink:(CADisplayLink *)progressObjectDisplayLink {
    if (progressObjectDisplayLink != _PN_progressObjectDisplayLink) {
        [_PN_progressObjectDisplayLink invalidate];

        _PN_progressObjectDisplayLink = progressObjectDisplayLink;

        [_PN_progressObjectDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)setPN_progressObject:(NSProgress *)progressObject {
    if (progressObject != _PN_progressObject) {
        _PN_progressObject = progressObject;
        [self setNSProgressDisplayLinkEnabled:YES];
    }
}

- (void)setPN_progress:(float)progress {
    if (progress != _PN_progress) {
        _PN_progress = progress;
        UIView *indicator = self.PN_indicator;
        if ([indicator respondsToSelector:@selector(setPN_progress:)]) {
            [(id)indicator setValue:@(self.PN_progress) forKey:@"progress"];
        }
    }
}

- (void)setPN_contentColor:(UIColor *)contentColor {
    if (contentColor != _PN_contentColor && ![contentColor isEqual:_PN_contentColor]) {
        _PN_contentColor = contentColor;
        [self MN_updateViewsForColor:contentColor];
    }
}

- (void)setPN_defaultMotionEffectsEnabled:(BOOL)defaultMotionEffectsEnabled {
    if (defaultMotionEffectsEnabled != _PN_defaultMotionEffectsEnabled) {
        _PN_defaultMotionEffectsEnabled = defaultMotionEffectsEnabled;
        [self updateBezelMotionEffects];
    }
}

#pragma mark - NSProgress

- (void)setNSProgressDisplayLinkEnabled:(BOOL)enabled {
    // We're using CADisplayLink, because NSProgress can change very quickly and observing it may starve the main thread,
    // so we're refreshing the progress only every frame draw
    if (enabled && self.PN_progressObject) {
        // Only create if not already active.
        if (!self.PN_progressObjectDisplayLink) {
            self.PN_progressObjectDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgressFromProgressObject)];
        }
    } else {
        self.PN_progressObjectDisplayLink = nil;
    }
}

- (void)updateProgressFromProgressObject {
    self.PN_progress = self.PN_progressObject.fractionCompleted;
}

#pragma mark - Notifications

- (void)registerForNotifications {
#if !TARGET_OS_TV && !TARGET_OS_MACCATALYST
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(statusBarOrientationDidChange:)
               name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#endif
}

- (void)unregisterFromNotifications {
#if !TARGET_OS_TV && !TARGET_OS_MACCATALYST
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#endif
}

#if !TARGET_OS_TV && !TARGET_OS_MACCATALYST
- (void)statusBarOrientationDidChange:(NSNotification *)notification {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    } else {
        [self updateForCurrentOrientationAnimated:YES];
    }
}
#endif

- (void)updateForCurrentOrientationAnimated:(BOOL)animated {
    // Stay in sync with the superview in any case
    if (self.superview) {
        self.frame = self.superview.bounds;
    }

    // Not needed on iOS 8+, compile out when the deployment target allows,
    // to avoid sharedApplication problems on extension targets
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 80000
    // Only needed pre iOS 8 when added to a window
    BOOL iOS8OrLater = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0;
    if (iOS8OrLater || ![self.superview isKindOfClass:[UIWindow class]]) return;

    // Make extension friendly. Will not get called on extensions (iOS 8+) due to the above check.
    // This just ensures we don't get a warning about extension-unsafe API.
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if (!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) return;

    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    UIInterfaceOrientation orientation = application.statusBarOrientation;
    CGFloat radians = 0;

    if (UIInterfaceOrientationIsLandscape(orientation)) {
        radians = orientation == UIInterfaceOrientationLandscapeLeft ? -(CGFloat)M_PI_2 : (CGFloat)M_PI_2;
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        radians = orientation == UIInterfaceOrientationPortraitUpsideDown ? (CGFloat)M_PI : 0.f;
    }

    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeRotation(radians);
        }];
    } else {
        self.transform = CGAffineTransformMakeRotation(radians);
    }
#endif
}

@end


@implementation MBRoundProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _PN_progress = 0.f;
        _PN_annular = NO;
        _PN_progressTintColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
        _PN_backgroundTintColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(37.f, 37.f);
}

#pragma mark - Properties

- (void)setPN_progress:(float)progress {
    if (progress != _PN_progress) {
        _PN_progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)setPN_progressTintColor:(UIColor *)progressTintColor {
    NSAssert(progressTintColor, @"The color should not be nil.");
    if (progressTintColor != _PN_progressTintColor && ![progressTintColor isEqual:_PN_progressTintColor]) {
        _PN_progressTintColor = progressTintColor;
        [self setNeedsDisplay];
    }
}

- (void)setPN_backgroundTintColor:(UIColor *)backgroundTintColor {
    NSAssert(backgroundTintColor, @"The color should not be nil.");
    if (backgroundTintColor != _PN_backgroundTintColor && ![backgroundTintColor isEqual:_PN_backgroundTintColor]) {
        _PN_backgroundTintColor = backgroundTintColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef PN_context = UIGraphicsGetCurrentContext();

    if (_PN_annular) {
        // Draw background
        CGFloat PN_lineWidth = 2.f;
        UIBezierPath *PN_processBackgroundPath = [UIBezierPath bezierPath];
        PN_processBackgroundPath.lineWidth = PN_lineWidth;
        PN_processBackgroundPath.lineCapStyle = kCGLineCapButt;
        CGPoint PN_center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGFloat PN_radius = (self.bounds.size.width - PN_lineWidth)/2;
        CGFloat PN_startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat PN_endAngle = (2 * (float)M_PI) + PN_startAngle;
        [PN_processBackgroundPath addArcWithCenter:PN_center radius:PN_radius startAngle:PN_startAngle endAngle:PN_endAngle clockwise:YES];
        [_PN_backgroundTintColor set];
        [PN_processBackgroundPath stroke];
        // Draw progress
        UIBezierPath *PN_processPath = [UIBezierPath bezierPath];
        PN_processPath.lineCapStyle = kCGLineCapSquare;
        PN_processPath.lineWidth = PN_lineWidth;
        PN_endAngle = (self.PN_progress * 2 * (float)M_PI) + PN_startAngle;
        [PN_processPath addArcWithCenter:PN_center radius:PN_radius startAngle:PN_startAngle endAngle:PN_endAngle clockwise:YES];
        [_PN_progressTintColor set];
        [PN_processPath stroke];
    } else {
        // Draw background
        CGFloat PN_lineWidth = 2.f;
        CGRect PN_allRect = self.bounds;
        CGRect PN_circleRect = CGRectInset(PN_allRect, PN_lineWidth/2.f, PN_lineWidth/2.f);
        CGPoint PN_center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [_PN_progressTintColor setStroke];
        [_PN_backgroundTintColor setFill];
        CGContextSetLineWidth(PN_context, PN_lineWidth);
        CGContextStrokeEllipseInRect(PN_context, PN_circleRect);
        // 90 degrees
        CGFloat PN_startAngle = - ((float)M_PI / 2.f);
        // Draw progress
        UIBezierPath *PN_processPath = [UIBezierPath bezierPath];
        PN_processPath.lineCapStyle = kCGLineCapButt;
        PN_processPath.lineWidth = PN_lineWidth * 2.f;
        CGFloat PN_radius = (CGRectGetWidth(self.bounds) / 2.f) - (PN_processPath.lineWidth / 2.f);
        CGFloat PN_endAngle = (self.PN_progress * 2.f * (float)M_PI) + PN_startAngle;
        [PN_processPath addArcWithCenter:PN_center radius:PN_radius startAngle:PN_startAngle endAngle:PN_endAngle clockwise:YES];
        // Ensure that we don't get color overlapping when _progressTintColor alpha < 1.f.
        CGContextSetBlendMode(PN_context, kCGBlendModeCopy);
        [_PN_progressTintColor set];
        [PN_processPath stroke];
    }
}

@end


@implementation CN_MBBarProgressView

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(.0f, .0f, 120.0f, 20.0f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _PN_progress = 0.f;
        _PN_lineColor = [UIColor whiteColor];
        _PN_progressColor = [UIColor whiteColor];
        _PN_progressRemainingColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(120.f, 10.f);
}

#pragma mark - Properties

- (void)setPN_progress:(float)PN_progress {
    if (PN_progress != _PN_progress) {
        _PN_progress = PN_progress;
        [self setNeedsDisplay];
    }
}

- (void)setPN_progressColor:(UIColor *)PN_progressColor {
    NSAssert(PN_progressColor, @"The color should not be nil.");
    if (PN_progressColor != _PN_progressColor && ![PN_progressColor isEqual:_PN_progressColor]) {
        _PN_progressColor = PN_progressColor;
        [self setNeedsDisplay];
    }
}

- (void)setPN_progressRemainingColor:(UIColor *)PN_progressRemainingColor {
    NSAssert(PN_progressRemainingColor, @"The color should not be nil.");
    if (PN_progressRemainingColor != _PN_progressRemainingColor && ![PN_progressRemainingColor isEqual:_PN_progressRemainingColor]) {
        _PN_progressRemainingColor = PN_progressRemainingColor;
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)PN_rect {
    CGContextRef PN_context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(PN_context, 2);
    CGContextSetStrokeColorWithColor(PN_context,[_PN_lineColor CGColor]);
    CGContextSetFillColorWithColor(PN_context, [_PN_progressRemainingColor CGColor]);

    // Draw background and Border
    CGFloat PN_radius = (PN_rect.size.height / 2) - 2;
    CGContextMoveToPoint(PN_context, 2, PN_rect.size.height/2);
    CGContextAddArcToPoint(PN_context, 2, 2, PN_radius + 2, 2, PN_radius);
    CGContextAddArcToPoint(PN_context, PN_rect.size.width - 2, 2, PN_rect.size.width - 2, PN_rect.size.height / 2, PN_radius);
    CGContextAddArcToPoint(PN_context, PN_rect.size.width - 2, PN_rect.size.height - 2, PN_rect.size.width - PN_radius - 2, PN_rect.size.height - 2, PN_radius);
    CGContextAddArcToPoint(PN_context, 2, PN_rect.size.height - 2, 2, PN_rect.size.height/2, PN_radius);
    CGContextDrawPath(PN_context, kCGPathFillStroke);

    CGContextSetFillColorWithColor(PN_context, [_PN_progressColor CGColor]);
    PN_radius = PN_radius - 2;
    CGFloat PN_amount = self.PN_progress * PN_rect.size.width;

    // Progress in the middle area
    if (PN_amount >= PN_radius + 4 && PN_amount <= (PN_rect.size.width - PN_radius - 4)) {
        CGContextMoveToPoint(PN_context, 4, PN_rect.size.height/2);
        CGContextAddArcToPoint(PN_context, 4, 4, PN_radius + 4, 4, PN_radius);
        CGContextAddLineToPoint(PN_context, PN_amount, 4);
        CGContextAddLineToPoint(PN_context, PN_amount, PN_radius + 4);

        CGContextMoveToPoint(PN_context, 4, PN_rect.size.height/2);
        CGContextAddArcToPoint(PN_context, 4, PN_rect.size.height - 4, PN_radius + 4, PN_rect.size.height - 4, PN_radius);
        CGContextAddLineToPoint(PN_context, PN_amount, PN_rect.size.height - 4);
        CGContextAddLineToPoint(PN_context, PN_amount, PN_radius + 4);

        CGContextFillPath(PN_context);
    }

    // Progress in the right arc
    else if (PN_amount > PN_radius + 4) {
        CGFloat x = PN_amount - (PN_rect.size.width - PN_radius - 4);

        CGContextMoveToPoint(PN_context, 4, PN_rect.size.height/2);
        CGContextAddArcToPoint(PN_context, 4, 4, PN_radius + 4, 4, PN_radius);
        CGContextAddLineToPoint(PN_context, PN_rect.size.width - PN_radius - 4, 4);
        CGFloat angle = -acos(x/PN_radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(PN_context, PN_rect.size.width - PN_radius - 4, PN_rect.size.height/2, PN_radius, M_PI, angle, 0);
        CGContextAddLineToPoint(PN_context, PN_amount, PN_rect.size.height/2);

        CGContextMoveToPoint(PN_context, 4, PN_rect.size.height/2);
        CGContextAddArcToPoint(PN_context, 4, PN_rect.size.height - 4, PN_radius + 4, PN_rect.size.height - 4, PN_radius);
        CGContextAddLineToPoint(PN_context, PN_rect.size.width - PN_radius - 4, PN_rect.size.height - 4);
        angle = acos(x/PN_radius);
        if (isnan(angle)) angle = 0;
        CGContextAddArc(PN_context, PN_rect.size.width - PN_radius - 4, PN_rect.size.height/2, PN_radius, -M_PI, angle, 1);
        CGContextAddLineToPoint(PN_context, PN_amount, PN_rect.size.height/2);

        CGContextFillPath(PN_context);
    }

    // Progress is in the left arc
    else if (PN_amount < PN_radius + 4 && PN_amount > 0) {
        CGContextMoveToPoint(PN_context, 4, PN_rect.size.height/2);
        CGContextAddArcToPoint(PN_context, 4, 4, PN_radius + 4, 4, PN_radius);
        CGContextAddLineToPoint(PN_context, PN_radius + 4, PN_rect.size.height/2);

        CGContextMoveToPoint(PN_context, 4, PN_rect.size.height/2);
        CGContextAddArcToPoint(PN_context, 4, PN_rect.size.height - 4, PN_radius + 4, PN_rect.size.height - 4, PN_radius);
        CGContextAddLineToPoint(PN_context, PN_radius + 4, PN_rect.size.height/2);

        CGContextFillPath(PN_context);
    }
}

@end


@interface CN_MBBackgroundView ()

@property UIVisualEffectView *PN_effectView;

@end


@implementation CN_MBBackgroundView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _PN_style = PN_MBProgressHUDBackgroundStyleBlur;
        if (@available(iOS 13.0, *)) {
            #if TARGET_OS_TV
            _blurEffectStyle = UIBlurEffectStyleRegular;
            #else
            _PN_blurEffectStyle = UIBlurEffectStyleSystemThickMaterial;
            #endif
            // Leaving the color unassigned yields best results.
        } else {
            _PN_blurEffectStyle = UIBlurEffectStyleLight;
            _PN_color = [UIColor colorWithWhite:0.8f alpha:0.6f];
        }

        self.clipsToBounds = YES;

        [self updateForBackgroundStyle];
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    // Smallest size possible. Content pushes against this.
    return CGSizeZero;
}

#pragma mark - Appearance

- (void)setPN_style:(PN_MBProgressHUDBackgroundStyle)PN_style {
    if (_PN_style != PN_style) {
        _PN_style = PN_style;
        [self updateForBackgroundStyle];
    }
}

- (void)setPN_color:(UIColor *)PN_color {
    NSAssert(PN_color, @"The color should not be nil.");
    if (PN_color != _PN_color && ![PN_color isEqual:_PN_color]) {
        _PN_color = PN_color;
        [self updateViewsForColor:PN_color];
    }
}

- (void)setPN_blurEffectStyle:(UIBlurEffectStyle)PN_blurEffectStyle {
    if (_PN_blurEffectStyle == PN_blurEffectStyle) {
        return;
    }

    _PN_blurEffectStyle = PN_blurEffectStyle;

    [self updateForBackgroundStyle];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Views

- (void)updateForBackgroundStyle {
    [self.PN_effectView removeFromSuperview];
    self.PN_effectView = nil;

    PN_MBProgressHUDBackgroundStyle PN_style = self.PN_style;
    if (PN_style == PN_MBProgressHUDBackgroundStyleBlur) {
        UIBlurEffect *PN_effect =  [UIBlurEffect effectWithStyle:self.PN_blurEffectStyle];
        UIVisualEffectView *PN_effectView = [[UIVisualEffectView alloc] initWithEffect:PN_effect];
        [self insertSubview: PN_effectView atIndex:0];
        PN_effectView.frame = self.bounds;
        PN_effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = self.PN_color;
        self.layer.allowsGroupOpacity = NO;
        self.PN_effectView = PN_effectView;
    } else {
        self.backgroundColor = self.PN_color;
    }
}

- (void)updateViewsForColor:(UIColor *)color {
    if (self.PN_style == PN_MBProgressHUDBackgroundStyleBlur) {
        self.backgroundColor = self.PN_color;
    } else {
        self.backgroundColor = self.PN_color;
    }
}

@end


@implementation CN_MBProgressHUDRoundedButton

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CALayer *layer = self.layer;
        layer.borderWidth = 1.f;
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    // Fully rounded corners
    CGFloat height = CGRectGetHeight(self.bounds);
    self.layer.cornerRadius = ceil(height / 2.f);
}

- (CGSize)intrinsicContentSize {
    // Only show if we have associated control events and a title
    if ((self.allControlEvents == 0) || ([self titleForState:UIControlStateNormal].length == 0))
		return CGSizeZero;
    CGSize PN_size = [super intrinsicContentSize];
    // Add some side padding
    PN_size.width += 20.f;
    return PN_size;
}

#pragma mark - Color

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    // Update related colors
    [self setHighlighted:self.highlighted];
    self.layer.borderColor = color.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    UIColor *baseColor = [self titleColorForState:UIControlStateSelected];
    self.backgroundColor = highlighted ? [baseColor colorWithAlphaComponent:0.1f] : [UIColor clearColor];
}

@end
