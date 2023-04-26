//
//  YLProgressManager.m
//  CherishSDK
//
//  Created by kook on 2021/11/30.
//

#import "CN_HudManager.h"
#import "CN_MBProgressHUD.h"

@interface CN_HudManager ()

@property (nonatomic, strong) CN_MBProgressHUD *PN_hudProgress;


@end

@implementation CN_HudManager

 
+ (instancetype)MN_share
{
    static id _PN_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _PN_sharedInstance = [[CN_HudManager alloc] init];
    });
    return _PN_sharedInstance;
    
}

- (UIWindow *)PN_loadingWindow
{
    if (!_PN_loadingWindow) {
        
        _PN_loadingWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        if (@available(iOS 13.0, *)) {
            _PN_loadingWindow.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        _PN_loadingWindow.windowLevel = TIPLevel;
        _PN_loadingWindow.rootViewController = [[UIViewController alloc] init];
  
    }
    return _PN_loadingWindow;
}

#pragma mark - HUD
//配置指示器
- (CN_MBProgressHUD *)PN_hudProgress
{
    if (!_PN_hudProgress) {
        self.PN_loadingWindow.hidden = NO;
        CN_MBProgressHUD *PN_myHud = [CN_MBProgressHUD MN_showHUDAddedTo:self.PN_loadingWindow MN_animated:YES];
        PN_myHud.PN_contentColor = UIColor.whiteColor;
        PN_myHud.PN_margin = 15;
        PN_myHud.PN_removeFromSuperViewOnHide = YES;
        PN_myHud.PN_bezelView.PN_color = UIColor.blackColor;
        PN_myHud.PN_bezelView.PN_style = PN_MBProgressHUDBackgroundStyleSolidColor;
        PN_myHud.PN_animationType = PN_MBProgressHUDAnimationZoom;
        _PN_hudProgress = PN_myHud;
    }
 
    return _PN_hudProgress;
}


//提示,自动消失
- (void)MN_showToastWith:(NSString *)text{
    __weak typeof(self) weakSelf = self;
    [self MN_mainThread:^{
        [weakSelf MN_dismiss];
        self.PN_hudProgress.PN_mode = PN_MBProgressHUDModeText;
        self.PN_hudProgress.PN_detailsLabel.textColor = [UIColor whiteColor];
        self.PN_hudProgress.PN_detailsLabel.text = text;
        [self.PN_hudProgress MN_hideAnimated:YES MN_afterDelay:2];
    }];
}

 
//loading
- (void)MN_showLoading{
    __weak typeof(self) weakSelf = self;
    [self MN_mainThread:^{
        [weakSelf MN_dismiss];
         self.PN_hudProgress.PN_mode = PN_MBProgressHUDModeIndeterminate;
    }];
    
}

//关闭loading
- (void)MN_dismiss{
    [self MN_mainThread:^{
        [CN_MBProgressHUD MN_hideHUDForView:self.PN_loadingWindow MN_animated:YES];
        self.PN_loadingWindow.hidden = YES;
        self.PN_hudProgress = nil;
    }];
}

//带文字loading
- (void)MN_showLoadingWithText:(NSString *)text
{
    __weak typeof(self) weakSelf = self;
    [self MN_mainThread:^{
        [weakSelf MN_dismiss];
        self.PN_hudProgress.PN_mode = PN_MBProgressHUDModeIndeterminate;
        self.PN_hudProgress.PN_label.text = text;
    }];
  
}

- (void)MN_mainThread:(void(^)(void))    PN_block {

    if ([NSThread currentThread].isMainThread) {
        if (    PN_block) {
                PN_block();
        }
    } else if (    PN_block) {
        dispatch_async(dispatch_get_main_queue(), ^{
                PN_block();
        });
    }

}


@end
