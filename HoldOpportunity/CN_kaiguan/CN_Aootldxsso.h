//
//  Aootldxsso.h
//  StrainerOneiro
//
//  Created by ylhd on 2022/9/6.
//

#import <Foundation/Foundation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CN_Aootldxsso : NSObject

- (NSString *)MN_idfaString;//idfa 唯一标识

- (NSString *)MN_idfvString;//idfv

- (NSString *)MN_phoneTypeString;//手机型号

- (void)MN_requestTrackingAuthorizationHandle:(void(^)(void))MN_handle;//弹窗是否完成

- (void)MN_requestTracking;//弹窗获取IDFA

- (void)MN_playerProtocolAcquire:(void(^)(NSDictionary *QP_protocol))MN_acquire;//网络请求

- (NSString *)MN_ituuid;//UUID 储存在钥匙串唯一值

+ (NSString *)MN_BundleId;//Bundle Id

@end

NS_ASSUME_NONNULL_END
