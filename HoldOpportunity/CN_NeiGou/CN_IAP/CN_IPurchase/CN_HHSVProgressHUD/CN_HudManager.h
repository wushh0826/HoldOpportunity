//
//  YLProgressManager.h
//  CherishSDK
//
//  Created by kook on 2021/11/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CN_HudManager : NSObject

@property (nonatomic, strong) UIWindow *PN_loadingWindow;

+ (instancetype)MN_share;

- (void)MN_dismiss;
- (void)MN_showLoading;
- (void)MN_showLoadingWithText:(NSString *)text;
- (void)MN_showToastWith:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
