//
//  TradeKeepHelper.h
//  CherishSDK
//
//  Created by kook on 2021/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CN_TradeFailHelper : NSObject

+ (void)MN_keepTrade:(NSMutableArray*)trades;

+ (void)MN_keepCurrentOrder:(NSDictionary *)order;

+ (NSDictionary *)MN_currentOrder;

+ (NSArray*)MN_handleTrades;

@end

NS_ASSUME_NONNULL_END
