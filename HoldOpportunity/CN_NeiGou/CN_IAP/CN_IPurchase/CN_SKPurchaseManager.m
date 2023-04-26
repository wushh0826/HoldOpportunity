//
//  PurchaseManager.m
//  CherishSDK
//
//  Created by kook on 2021/12/21.
//

#import "CN_SKPurchaseManager.h"
#import <StoreKit/StoreKit.h>
#import "CN_TradeFailHelper.h"
#import "CN_HudManager.h"
#import "CN_AFNManager.h"

@interface CN_SKPurchaseManager ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

/**
 nowOrder
 */
@property (strong, nonatomic) NSMutableDictionary *PN_tradeInfo;

@property (nonatomic, strong) NSDictionary *PN_orderInfo;
/**
 transactionArray
 */
@property (strong, nonatomic) NSMutableArray *PN_failTrades;

@property (nonatomic, strong)dispatch_queue_t PN_dealQueue;//创建一个子线程

@end

@implementation CN_SKPurchaseManager

 
+ (CN_SKPurchaseManager*)MN_shareiap
{
    static id PN_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PN_manager = [[CN_SKPurchaseManager alloc] init];
    });
    return PN_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [self obtainfailTrades];
        
    }
    return self;
}

- (void)obtainfailTrades{
    NSArray *PN_orders = [CN_TradeFailHelper MN_handleTrades];
    _PN_failTrades = [NSMutableArray arrayWithArray:PN_orders];
    NSDictionary *PN_localDict = [CN_TradeFailHelper MN_currentOrder];
    _PN_tradeInfo = [NSMutableDictionary dictionaryWithDictionary:PN_localDict];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)MN_observeSupplement
{
    NSArray *PN_orders = [CN_TradeFailHelper MN_handleTrades];
    if (PN_orders.count == 0) {
        return;
    }
    
    //补单
    for (NSDictionary *PN_dict in PN_orders) {
        if (![PN_dict.allKeys containsObject:ParaAllowedload]) {
            continue;
        }
        [self MN_deliveryFailProduct:PN_dict];
    }
    
}
 

//通知后台发货
- (void)MN_deliveryFailProduct:(NSDictionary *)PN_productDict
{
    
    NSMutableDictionary *PN_pDict = [NSMutableDictionary dictionaryWithDictionary:PN_productDict];
  
  
    [CN_AFNManager MN_requestWith:fahuo_task MN_paramDict:PN_pDict MN_overBlock:^(NSInteger statusCode, NSString * _Nonnull message, NSDictionary * _Nonnull object) {
        if (statusCode ==20000) {

            NSLog(@"补货成功!");
            [self.PN_failTrades removeObject:PN_productDict];
            [self MN_collectTrades];
 

        }else{
            
            NSString *PN_tips = [NSString stringWithFormat:@"补货失败-%@",message];
            NSLog(@"%@",PN_tips);
            

        }

    }];
 
    
}

//通知后台发货
- (void)MN_deliveryProduct:(NSDictionary *)PN_productDict {
    
    NSMutableDictionary *pDict = [NSMutableDictionary dictionaryWithDictionary:PN_productDict];
  
    [[CN_HudManager MN_share] MN_showLoadingWithText:@"正在派送..."];

    [CN_AFNManager MN_requestWith:fahuo_task MN_paramDict:pDict MN_overBlock:^(NSInteger statusCode, NSString * _Nonnull message, NSDictionary * _Nonnull object) {
        if (statusCode == 20000) {

            NSLog(@"发货成功!");
            [self.PN_failTrades removeObject:PN_productDict];
            [self MN_collectTrades];

            [self MN_purchaseComplete:YES MN_andResult:message];
            
 
        }else{
            
                NSString *PN_tips = [NSString stringWithFormat:@"支付成功,发货失败-%@",message];
                [self MN_purchaseComplete:NO MN_andResult:PN_tips];
            

        }

    }];
 
    
}
- (NSString *)MN_preventInfo:(NSDictionary *)info MN_withKey:(NSString *)key {
    id PN_object = @"";
    if (info && key.length > 0) {
        PN_object = info[key];
        if (!PN_object || [PN_object isKindOfClass:[NSNull class]]) {
            PN_object = @"";
        } else if (![PN_object isKindOfClass:[NSString class]]) {
            PN_object = [NSString stringWithFormat:@"%@", PN_object];
        }
    }
    return PN_object;
}

- (void)MN_inPurchaseWithInfo:(NSDictionary *)PN_orderInfo{
    
    //获取参数
    NSDictionary *PN_paramDict = @{
        ParaAmount         :[self MN_preventInfo:PN_orderInfo MN_withKey:@"amount"],
        ParaCpOrderId      :[self MN_preventInfo:PN_orderInfo MN_withKey:@"cp_order_id"],
        ParaProductID      :[self MN_preventInfo:PN_orderInfo MN_withKey:@"goods_id"],
        ParaGoods_desc     :[self MN_preventInfo:PN_orderInfo MN_withKey:@"goods_desc"],
        ParaExt            :[self MN_preventInfo:PN_orderInfo MN_withKey:@"ext"],
        ParaRoleID         :[self MN_preventInfo:PN_orderInfo MN_withKey:@"role_id"],
        ParaRoleName       :[self MN_preventInfo:PN_orderInfo MN_withKey:@"role_name"],
        ParaServerID       :[self MN_preventInfo:PN_orderInfo MN_withKey:@"server_id"],
        ParaServerName     :[self MN_preventInfo:PN_orderInfo MN_withKey:@"server_name"],
        ParaUID            :[self MN_preventInfo:PN_orderInfo MN_withKey:@"uid"],
        ParaToken          :[self MN_preventInfo:PN_orderInfo MN_withKey:@"token"]
    };
    
    NSMutableDictionary *PN_dataDict = [NSMutableDictionary dictionaryWithDictionary:PN_paramDict];
    NSDictionary *PN_orderDict = @{
        ParaGameID:lxgame,
        ParaChannel_id:@"0",
        ParaOS:@"ios",
        ParaPackCode:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
    };
    [PN_dataDict addEntriesFromDictionary:PN_orderDict];

    //下单前检查
//    [self MN_observeSupplement];

    _PN_dealQueue = dispatch_queue_create("com.MN_observeSupplement.PN_observeSupplement", DISPATCH_QUEUE_SERIAL);
    //异步处理
    dispatch_async(_PN_dealQueue, ^{
        [self MN_observeSupplement];

    });

    
    self.PN_orderInfo = PN_orderInfo;
    
    if (![SKPaymentQueue canMakePayments]) {
        [[CN_HudManager MN_share] MN_showToastWith:@"当前设备不支持内购!"];return ;
    }
    
    NSString *PN_productID = [NSString stringWithFormat:@"%@", [PN_dataDict valueForKey:ParaProductID]];
    if (PN_productID.length <= 0) {
        [[CN_HudManager MN_share] MN_showToastWith:@"商品ID为空!"];return;
    }
    
    [[CN_HudManager MN_share] MN_showLoadingWithText:@"正在进行购买..."];
    __weak typeof(self) PN_weak = self;
    
        NSMutableDictionary *PN_dealDict = [NSMutableDictionary dictionaryWithDictionary:PN_dataDict];
        [PN_dealDict setValue:@"appleallowed_app_000000" forKey:ParaA_channel];
        [PN_dealDict setValue:@"appleallowed_app" forKey:ParaAWay];
 
        
        [CN_AFNManager MN_requestWith:xiadan_task MN_paramDict:PN_dealDict MN_overBlock:^(NSInteger PN_statusCode, NSString * _Nonnull message, NSDictionary * _Nonnull object) {
            if (PN_statusCode == 20000) {
                NSString *PN_oID = [NSString stringWithFormat:@"%@",[object valueForKey:ParaOrderID]];
                if (PN_oID.length<=0) {
                    [[CN_HudManager MN_share] MN_showToastWith:@"订单生成失败"];;return;
                }
                
                [PN_weak.PN_tradeInfo setValue:PN_oID forKey:ParaOrderID];
                [PN_weak.PN_tradeInfo setValue:@"appleallowed_app_000000" forKey:ParaA_channel];
                [PN_weak.PN_tradeInfo setValue:PN_productID forKey:ParaProductID];
                [[CN_HudManager MN_share] MN_showLoadingWithText:@"获取商品信息中..."];
                SKProductsRequest *PN_productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:PN_productID, nil]];
                PN_productsRequest.delegate = PN_weak;
                [PN_productsRequest start];
                
            }else{
                [self MN_purchaseComplete:NO MN_andResult:message];
            }
        }];
  
}
- (NSString *)MN_encodeString:(NSString *)string {
   NSString *PN_charactersToEscape = @"!*'();:@&;=+$,/?%#[] ";
   NSCharacterSet *PN_allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:PN_charactersToEscape] invertedSet];
   NSString *PN_encodedUrl = [string stringByAddingPercentEncodingWithAllowedCharacters:PN_allowedCharacters];
   return PN_encodedUrl;
}

#pragma mark - 自定义事件
///发货
- (void)MN_appleComplete:(SKPaymentTransaction *)transaction
{
    NSData *PN_data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    if (PN_data) {
        NSString *PN_receipt = [PN_data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        NSString *PN_new_receipt = [self MN_encodeString:PN_receipt];
        NSString *PN_identifier = transaction.transactionIdentifier;
       
        //链接中端,再次回调
        [_PN_tradeInfo setValue:PN_identifier ?:@"1" forKey:ParaTransaction_id];
        [_PN_tradeInfo setValue:PN_new_receipt forKey:ParaAllowedload];
        [_PN_tradeInfo setValue:@"ios" forKey:ParaOS];
        [_PN_tradeInfo setValue:lxgame forKey:ParaGameID];
        [_PN_tradeInfo setValue:@"0" forKey:ParaChannel_id];
        
        if ([_PN_tradeInfo valueForKey:ParaAllowedload] == 0) {
            return;
        }
        [_PN_failTrades addObject:_PN_tradeInfo];
       
        [self MN_collectTrades];
        //标记为结束
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        //通知发货
        [self MN_deliveryProduct:_PN_tradeInfo];
        [self MN_collectCurrentTrade:@{}];
        _PN_tradeInfo = [NSMutableDictionary dictionary];
    
    }
 
}

 

//获取没发货订单
- (NSMutableArray *)PN_failTrades
{
    NSArray *orders = [CN_TradeFailHelper MN_handleTrades];
    _PN_failTrades = [NSMutableArray arrayWithArray:orders];
    return _PN_failTrades;
}



//保存没发货订单
- (void)MN_collectTrades {
    [CN_TradeFailHelper MN_keepTrade:_PN_failTrades];
}

#pragma mark - localized storage
- (void)MN_collectCurrentTrade:(NSDictionary *)currentOrder {

    [CN_TradeFailHelper MN_keepCurrentOrder:currentOrder];
}


-(void)MN_purchaseComplete:(BOOL)success MN_andResult:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[CN_HudManager MN_share] MN_showToastWith:message];;
 
    });
}


#pragma mark - SKPaymentTransactionObserver SKProductsRequestDelegate
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self MN_purchaseComplete:NO MN_andResult:[error localizedDescription]];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (response.products.count == 0) {
 
        [self MN_purchaseComplete:NO MN_andResult:@"找不到该商品"];
    }
    
    SKProduct *current_product = nil;
    for (SKProduct *product in response.products) {
        if ([product.productIdentifier isEqualToString:self.PN_tradeInfo[ParaProductID]]) {
            current_product = product;
            break;
        }
    }
    
    if (current_product) {
        [[CN_HudManager MN_share] MN_showLoadingWithText:@"正在连接商店..."];;
        NSString *currencyCode = [current_product.priceLocale objectForKey:NSLocaleCurrencyCode];
        
        //保存信息
        [self.PN_tradeInfo setValue:currencyCode forKey:ParaCurrency];
        [self.PN_tradeInfo setValue:current_product.price forKey:ParaMoney];
        
        [self MN_collectCurrentTrade:_PN_tradeInfo];
        
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:current_product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        
        [self MN_purchaseComplete:NO MN_andResult:@"找不到该匹配商品"];
        
    }
}


- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateRestored:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self MN_purchaseComplete:NO MN_andResult:@"恢复购买"];
            }
                break;
            case SKPaymentTransactionStatePurchased:
            {
                //发货
                [self MN_appleComplete:transaction];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
            {
                [[CN_HudManager MN_share] MN_showLoadingWithText:@"购买商品中..."];
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSString *content = transaction.error.code == SKErrorPaymentCancelled ? @"取消购买" : (transaction.error.localizedDescription ?: @"无法连接iTunes Store");
                
                [self MN_purchaseComplete:NO MN_andResult:content];
                
            }
                break;
            case SKPaymentTransactionStateDeferred:
            {
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self MN_purchaseComplete:NO MN_andResult:@"status未确定"];
                
            }
                break;
            default:
                break;
        }
    }
}


@end
