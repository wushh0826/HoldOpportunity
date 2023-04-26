//
//  TradeKeepHelper.m
//  CherishSDK
//
//  Created by kook on 2021/12/21.
//

#import "CN_TradeFailHelper.h"

@implementation CN_TradeFailHelper

+ (void)MN_keepTrade:(NSMutableArray*)trades{
    NSString *PN_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:RECEIPT_DATA];
    BOOL PN_success = [NSKeyedArchiver archiveRootObject:trades toFile:PN_path];
    if (!PN_success) {
        NSLog(@"订单保存失败");
    }
}

+ (NSArray*)MN_handleTrades
{
    NSString *PN_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:RECEIPT_DATA];
    NSMutableArray *PN_array  = [NSKeyedUnarchiver unarchiveObjectWithFile:PN_path];
    return PN_array ? : @[];
}

+ (void)MN_keepCurrentOrder:(NSDictionary *)order
{
    NSString *PN_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:en_key];
    BOOL PN_success = [NSKeyedArchiver archiveRootObject:order toFile:PN_path];
    if (!PN_success) {
        NSLog(@"订单保存失败");
    }
}

+ (NSDictionary *)MN_currentOrder
{
    NSString *PN_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:en_key];
    NSDictionary *PN_order  = [NSKeyedUnarchiver unarchiveObjectWithFile:PN_path];
    return PN_order ? : @{};
}
@end
