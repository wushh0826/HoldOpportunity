//
//  SKGameIAPManager.h
//  LSQY
//
//  Created by kook on 2022/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CN_SKGameIAPManager : NSObject

//单例
+ (CN_SKGameIAPManager*)MN_share;

//内购下单接口 设置回调
- (void)MN_inPurchaseWithInfo:(NSString *)productID MN_withBlock:(void(^)(BOOL success))block;
@end

NS_ASSUME_NONNULL_END
