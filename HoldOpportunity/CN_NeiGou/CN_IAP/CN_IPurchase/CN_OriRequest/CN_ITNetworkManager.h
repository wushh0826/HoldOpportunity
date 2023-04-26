//
//  ITNetworkManager.h
//  InteractSDK
//
//  Created by kook on 2021/10/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CN_ITNetworkManager : NSObject

+(CN_ITNetworkManager *)MN_myNet;



/// 网络请求
/// @param requestURL 请求url
/// @param params 参数
/// @param complete 回调
- (void)MN_startRequestWithPath:(NSString *)requestURL MN_paras:(NSDictionary *)params MN_handle:(void(^)(NSInteger statusCode,NSString *message,NSDictionary *object))complete;
@end

NS_ASSUME_NONNULL_END
