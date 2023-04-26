//
//  IAPManager.h
//  CherishSDK
//
//  Created by kook on 2021/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CN_SKPurchaseManager : NSObject

+ (CN_SKPurchaseManager*)MN_shareiap;

- (void)MN_observeSupplement;

//内购下单接口
- (void)MN_inPurchaseWithInfo:(NSDictionary *)orderInfo;

@end

NS_ASSUME_NONNULL_END
