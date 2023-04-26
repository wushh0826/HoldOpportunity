//
//  SKGameIAPManager.m
//  LSQY
//
//  Created by kook on 2022/8/26.
//

#import "CN_SKGameIAPManager.h"
#import <StoreKit/StoreKit.h>
#import "CN_HudManager.h"

@interface CN_SKGameIAPManager ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property(nonatomic, copy) NSString *PN_productID;

@property (copy, nonatomic) void(^PN_purchaseBlock)(BOOL success);

@end

@implementation CN_SKGameIAPManager

+ (CN_SKGameIAPManager*)MN_share
{
    static id PN_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PN_manager = [[CN_SKGameIAPManager alloc] init];
    });
    return PN_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    }
    return self;
}

 
- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}



//通知后台发货
- (void)MN_deliveryProduct:(NSString*)receipt {
    [[CN_HudManager MN_share] MN_showToastWith:@"灵灵玉石到账成功"];
    self.PN_purchaseBlock(YES);
}
 

//触发内购
- (void)MN_inPurchaseWithInfo:(NSString *)PN_productID MN_withBlock:(void(^)(BOOL success))PN_block{
    if(PN_block){
        self.PN_purchaseBlock = PN_block;
    }
    if (PN_productID.length <= 0) {
        [[CN_HudManager MN_share] MN_showToastWith:@"商品ID为空!"];return;
    }
    self.PN_productID = PN_productID;
    [[CN_HudManager MN_share] MN_showLoadingWithText:@"购买中..."];
    
    SKProductsRequest *PN_productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:PN_productID, nil]];
    PN_productsRequest.delegate = self;
    [PN_productsRequest start];
  
}
 

#pragma mark - 自定义事件
///发货
- (void)MN_appleComplete:(SKPaymentTransaction *)transaction
{
    NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    if (data) {
        NSString *receipt = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
   
        //标记为结束
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        //通知发货
        [self MN_deliveryProduct:receipt];
   
    }
 
}



-(void)MN_purchaseComplete:(BOOL)success MN_andResult:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[CN_HudManager MN_share] MN_showToastWith:message];
 
    });
}


#pragma mark - SKPaymentTransactionObserver SKProductsRequestDelegate
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self MN_purchaseComplete:NO MN_andResult:[error localizedDescription]];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"---->%@",response);
    
    if (response.products.count == 0) {
 
        [self MN_purchaseComplete:NO MN_andResult:@"找不到该商品"];
    }
    
    SKProduct *current_product = nil;
    for (SKProduct *product in response.products) {
        NSLog(@"%@",product.productIdentifier);
        if ([product.productIdentifier isEqualToString:self.PN_productID]) {
            current_product = product;
            break;
        }
    }
    
    if (current_product) {
        [[CN_HudManager MN_share] MN_showLoadingWithText:@"正在连接商店..."];;
       
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:current_product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        
        [self MN_purchaseComplete:NO MN_andResult:@"找不到该匹配商品"];
        
    }
}


- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *PN_transaction in transactions) {
        switch (PN_transaction.transactionState) {
            case SKPaymentTransactionStateRestored:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:PN_transaction];
                [self MN_purchaseComplete:NO MN_andResult:@"恢复已购买商品"];
                
            }
                break;
            case SKPaymentTransactionStatePurchased:
            {
                
                //发货
                [self MN_appleComplete:PN_transaction];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
            {
                [[CN_HudManager MN_share] MN_showLoadingWithText:@"购买商品中..."];
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:PN_transaction];
                NSString *PN_content = PN_transaction.error.code == SKErrorPaymentCancelled ? @"取消购买" : (PN_transaction.error.localizedDescription ?: @"无法连接iTunes Store");
                
                [self MN_purchaseComplete:NO MN_andResult:PN_content];
                
            }
                break;
            case SKPaymentTransactionStateDeferred: {
                [[SKPaymentQueue defaultQueue] finishTransaction:PN_transaction];
                [self MN_purchaseComplete:NO MN_andResult:@"状态未确定"];
                
            }
                break;
            default:
                break;
        }
    }
}



@end
