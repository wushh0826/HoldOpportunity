 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@class CN_MBBackgroundView;
@protocol CN_MBProgressHUDDelegate;


extern CGFloat const PN_MBProgressMaxOffset;

typedef NS_ENUM(NSInteger, PN_MBProgressHUDMode) {
    /// UIActivityIndicatorView.
    PN_MBProgressHUDModeIndeterminate,
    /// A round, pie-chart like, progress view.
    PN_MBProgressHUDModeDeterminate,
    /// Horizontal progress bar.
    PN_MBProgressHUDModeDeterminateHorizontalBar,
    /// Ring-shaped progress view.
    PN_MBProgressHUDModeAnnularDeterminate,
    /// Shows a custom view.
    PN_MBProgressHUDModeCustomView,
    /// Shows only labels.
    PN_MBProgressHUDModeText
};

typedef NS_ENUM(NSInteger, PN_MBProgressHUDAnimation) {
    /// Opacity animation
    PN_MBProgressHUDAnimationFade,
    /// Opacity + scale animation (zoom in when appearing zoom out when disappearing)
    PN_MBProgressHUDAnimationZoom,
    /// Opacity + scale animation (zoom out style)
    PN_MBProgressHUDAnimationZoomOut,
    /// Opacity + scale animation (zoom in style)
    PN_MBProgressHUDAnimationZoomIn
};

typedef NS_ENUM(NSInteger, PN_MBProgressHUDBackgroundStyle) {
    /// Solid color background
    PN_MBProgressHUDBackgroundStyleSolidColor,
    /// UIVisualEffectView or UIToolbar.layer background view
    PN_MBProgressHUDBackgroundStyleBlur
};

typedef void (^CN_MBProgressHUDCompletionBlock)(void);


NS_ASSUME_NONNULL_BEGIN


/**
 * Displays a simple HUD window containing a progress indicator and two optional labels for short messages.
 *
 * This is a simple drop-in class for displaying a progress HUD view similar to Apple's private UIProgressHUD class.
 * The PN_MBProgressHUD window spans over the entire space given to it by the initWithFrame: constructor and catches all
 * user input on this region, thereby preventing the user operations on components below the view.
 *
 * @note To still allow touches to pass through the HUD, you can set hud.userInteractionEnabled = NO.
 * @attention PN_MBProgressHUD is a UI class and should therefore only be accessed on the main thread.
 */
@interface CN_MBProgressHUD : UIView

/**
 * Creates a new HUD, adds it to provided view and shows it. The counterpart to this method is hideHUDForView:animated:.
 *
 * @note This method sets removeFromSuperViewOnHide. The HUD will automatically be removed from the view hierarchy when hidden.
 *
 * @param view The view that the HUD will be added to
 * @param animated If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use
 * animations while appearing.
 * @return A reference to the created HUD.
 *
 * @see hideHUDForView:animated:
 * @see animationType
 */
+ (instancetype)MN_showHUDAddedTo:(UIView *)view MN_animated:(BOOL)animated;

/// @name Showing and hiding

/**
 * Finds the top-most HUD subview that hasn't finished and hides it. The counterpart to this method is showHUDAddedTo:animated:.
 *
 * @note This method sets removeFromSuperViewOnHide. The HUD will automatically be removed from the view hierarchy when hidden.
 *
 * @param view The view that is going to be searched for a HUD subview.
 * @param animated If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * animations while disappearing.
 * @return YES if a HUD was found and removed, NO otherwise.
 *
 * @see showHUDAddedTo:animated:
 * @see animationType
 */
+ (BOOL)MN_hideHUDForView:(UIView *)view MN_animated:(BOOL)animated;

/**
 * Finds the top-most HUD subview that hasn't finished and returns it.
 *
 * @param view The view that is going to be searched.
 * @return A reference to the last HUD subview discovered.
 */
+ (nullable CN_MBProgressHUD *)MN_HUDForView:(UIView *)view NS_SWIFT_NAME(forView(_:));

/**
 * A convenience constructor that initializes the HUD with the view's bounds. Calls the designated constructor with
 * view.bounds as the parameter.
 *
 * @param view The view instance that will provide the bounds for the HUD. Should be the same instance as
 * the HUD's superview (i.e., the view that the HUD will be added to).
 */
- (instancetype)initWithView:(UIView *)view;

/**
 * Displays the HUD.
 *
 * @note You need to make sure that the main thread completes its run loop soon after this method call so that
 * the user interface can be updated. Call this method when your task is already set up to be executed in a new thread
 * (e.g., when using something like NSOperation or making an asynchronous call like NSURLRequest).
 *
 * @param animated If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use
 * animations while appearing.
 *
 * @see animationType
 */
- (void)MN_showAnimated:(BOOL)animated;

/**
 * Hides the HUD. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 *
 * @param animated If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * animations while disappearing.
 *
 * @see animationType
 */
- (void)MN_hideAnimated:(BOOL)animated;

/**
 * Hides the HUD after a delay. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to
 * hide the HUD when your task completes.
 *
 * @param animated If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use
 * animations while disappearing.
 * @param delay Delay in seconds until the HUD is hidden.
 *
 * @see animationType
 */
- (void)MN_hideAnimated:(BOOL)animated MN_afterDelay:(NSTimeInterval)delay;

/**
 * The HUD delegate object. Receives HUD state notifications.
 */
@property (weak, nonatomic) id<CN_MBProgressHUDDelegate> delegate;

/**
 * Called after the HUD is hidden.
 */
@property (copy, nullable) CN_MBProgressHUDCompletionBlock PN_completionBlock;

/**
 * Grace period is the time (in seconds) that the invoked method may be run without
 * showing the HUD. If the task finishes before the grace time runs out, the HUD will
 * not be shown at all.
 * This may be used to prevent HUD display for very short tasks.
 * Defaults to 0 (no grace time).
 * @note The graceTime needs to be set before the hud is shown. You thus can't use `showHUDAddedTo:animated:`,
 * but instead need to alloc / init the HUD, configure the grace time and than show it manually.
 */
@property (assign, nonatomic) NSTimeInterval PN_graceTime;

/**
 * The minimum time (in seconds) that the HUD is shown.
 * This avoids the problem of the HUD being shown and than instantly hidden.
 * Defaults to 0 (no minimum show time).
 */
@property (assign, nonatomic) NSTimeInterval PN_minShowTime;

/**
 * Removes the HUD from its parent view when hidden.
 * Defaults to NO.
 */
@property (assign, nonatomic) BOOL PN_removeFromSuperViewOnHide;

/// @name Appearance

/**
 * PN_MBProgressHUD operation mode. The default is PN_MBProgressHUDModeIndeterminate.
 */
@property (assign, nonatomic) PN_MBProgressHUDMode PN_mode;

/**
 * A color that gets forwarded to all labels and supported indicators. Also sets the tintColor
 * for custom views on iOS 7+. Set to nil to manage color individually.
 * Defaults to semi-translucent black on iOS 7 and later and white on earlier iOS versions.
 */
@property (strong, nonatomic, nullable) UIColor *PN_contentColor UI_APPEARANCE_SELECTOR;

/**
 * The animation type that should be used when the HUD is shown and hidden.
 */
@property (assign, nonatomic) PN_MBProgressHUDAnimation PN_animationType UI_APPEARANCE_SELECTOR;

/**
 * The bezel offset relative to the center of the view. You can use PN_MBProgressMaxOffset
 * and -PN_MBProgressMaxOffset to move the HUD all the way to the screen edge in each direction.
 * E.g., CGPointMake(0.f, PN_MBProgressMaxOffset) would position the HUD centered on the bottom edge.
 */
@property (assign, nonatomic) CGPoint PN_offset UI_APPEARANCE_SELECTOR;

/**
 * The amount of space between the HUD edge and the HUD elements (labels, indicators or custom views).
 * This also represents the minimum bezel distance to the edge of the HUD view.
 * Defaults to 20.f
 */
@property (assign, nonatomic) CGFloat PN_margin UI_APPEARANCE_SELECTOR;

/**
 * The minimum size of the HUD bezel. Defaults to CGSizeZero (no minimum size).
 */
@property (assign, nonatomic) CGSize PN_minSize UI_APPEARANCE_SELECTOR;

/**
 * Force the HUD dimensions to be equal if possible.
 */
@property (assign, nonatomic, getter = isSquare) BOOL PN_square UI_APPEARANCE_SELECTOR;

/**
 * When enabled, the bezel center gets slightly affected by the device accelerometer data.
 * Defaults to NO.
 *
 * @note This can cause main thread checker assertions on certain devices. https://github.com/jdg/PN_MBProgressHUD/issues/552
 */
@property (assign, nonatomic, getter=areDefaultMotionEffectsEnabled) BOOL PN_defaultMotionEffectsEnabled UI_APPEARANCE_SELECTOR;

/// @name Progress

/**
 * The progress of the progress indicator, from 0.0 to 1.0. Defaults to 0.0.
 */
@property (assign, nonatomic) float PN_progress;

/// @name ProgressObject

/**
 * The NSProgress object feeding the progress information to the progress indicator.
 */
@property (strong, nonatomic, nullable) NSProgress *PN_progressObject;

/// @name Views

/**
 * The view containing the labels and indicator (or customView).
 */
@property (strong, nonatomic, readonly) CN_MBBackgroundView *PN_bezelView;

/**
 * View covering the entire HUD area, placed behind bezelView.
 */
@property (strong, nonatomic, readonly) CN_MBBackgroundView *PN_backgroundView;

/**
 * The UIView (e.g., a UIImageView) to be shown when the HUD is in PN_MBProgressHUDModeCustomView.
 * The view should implement intrinsicContentSize for proper sizing. For best results use approximately 37 by 37 pixels.
 */
@property (strong, nonatomic, nullable) UIView *customView;

/**
 * A label that holds an optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit
 * the entire text.
 */
@property (strong, nonatomic, readonly) UILabel *PN_label;

/**
 * A label that holds an optional details message displayed below the labelText message. The details text can span multiple lines.
 */
@property (strong, nonatomic, readonly) UILabel *PN_detailsLabel;

/**
 * A button that is placed below the labels. Visible only if a target / action is added and a title is assigned..
 */
@property (strong, nonatomic, readonly) UIButton *PN_button;

@end


@protocol CN_MBProgressHUDDelegate <NSObject>

@optional

/**
 * Called after the HUD was fully hidden from the screen.
 */
- (void)hudWasHidden:(CN_MBProgressHUD *)hud;

@end


/**
 * A progress view for showing definite progress by filling up a circle (pie chart).
 */
@interface MBRoundProgressView : UIView

/**
 * Progress (0.0 to 1.0)
 */
@property (nonatomic, assign) float PN_progress;

/**
 * Indicator progress color.
 * Defaults to white [UIColor whiteColor].
 */
@property (nonatomic, strong) UIColor *PN_progressTintColor;

/**
 * Indicator background (non-progress) color.
 * Only applicable on iOS versions older than iOS 7.
 * Defaults to translucent white (alpha 0.1).
 */
@property (nonatomic, strong) UIColor *PN_backgroundTintColor;

/*
 * Display mode - NO = round or YES = annular. Defaults to round.
 */
@property (nonatomic, assign, getter = isAnnular) BOOL PN_annular;

@end


/**
 * A flat bar progress view.
 */
@interface CN_MBBarProgressView : UIView

/**
 * Progress (0.0 to 1.0)
 */
@property (nonatomic, assign) float PN_progress;

/**
 * Bar border line color.
 * Defaults to white [UIColor whiteColor].
 */
@property (nonatomic, strong) UIColor *PN_lineColor;

/**
 * Bar background color.
 * Defaults to clear [UIColor clearColor];
 */
@property (nonatomic, strong) UIColor *PN_progressRemainingColor;

/**
 * Bar progress color.
 * Defaults to white [UIColor whiteColor].
 */
@property (nonatomic, strong) UIColor *PN_progressColor;

@end


@interface CN_MBBackgroundView : UIView

/**
 * The background style.
 * Defaults to PN_MBProgressHUDBackgroundStyleBlur.
 */
@property (nonatomic) PN_MBProgressHUDBackgroundStyle PN_style;

/**
 * The blur effect style, when using PN_MBProgressHUDBackgroundStyleBlur.
 * Defaults to UIBlurEffectStyleLight.
 */
@property (nonatomic) UIBlurEffectStyle PN_blurEffectStyle;

/**
 * The background color or the blur tint color.
 *
 * Defaults to nil on iOS 13 and later and
 * `[UIColor colorWithWhite:0.8f alpha:0.6f]`
 * on older systems.
 */
@property (nonatomic, strong, nullable) UIColor *PN_color;

@end

NS_ASSUME_NONNULL_END
