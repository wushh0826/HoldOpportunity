//
//  Aootldxsso.m
//  StrainerOneiro
//
//  Created by ylhd on 2022/9/6.
//

#import "CN_Aootldxsso.h"
#import <sys/utsname.h>
#import <CommonCrypto/CommonCrypto.h>
#import "CN_SAMKeychain.h"
#import "CN_YILEViewController.h"
@implementation CN_Aootldxsso

- (void)MN_playerProtocolAcquire:(void(^)(NSDictionary *QP_protocol))MN_acquire
{
//    NSLog(@"------>%@",kCN_AseCBCDecrypt(kCN_lxpath));
    NSMutableURLRequest *QP_nodeRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kCN_AseCBCDecrypt(kCN_lxpath),kCN_announce]]];
    QP_nodeRequest.timeoutInterval = 20;
    QP_nodeRequest.HTTPMethod = [@[@"POST"] componentsJoinedByString:@""];
    [QP_nodeRequest setValue:[@[@"application/json"] componentsJoinedByString:@""] forHTTPHeaderField:[@[@"Content-Type"] componentsJoinedByString:@""]];
    QP_nodeRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{kCN_pGameID:kCN_lxgame,kCN_pIDFA:[self MN_idfaString]} options:NSJSONWritingPrettyPrinted error:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:QP_nodeRequest completionHandler:^(NSData * _Nullable QP_yetData, NSURLResponse * _Nullable QP_response, NSError * _Nullable error) {
        
#pragma mark --  打印返参 要删除
//        NSString * PN_str  =[[NSString alloc] initWithData:QP_yetData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",QP_nodeRequest);
        
        if (error == nil && QP_yetData != nil) {
            
            NSData *QP_cData =[[NSData alloc] initWithBase64EncodedData:QP_yetData options:0];
            
            NSString *QP_dResult =[[NSString alloc] initWithData:QP_cData encoding:NSUTF8StringEncoding];
            
           NSDictionary *QP_dDict = [NSJSONSerialization JSONObjectWithData:[QP_dResult dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
             if ([QP_dDict[kCN_pData] isKindOfClass:[NSDictionary class]]){
                NSDictionary *QP_yetData = QP_dDict[kCN_pData];
                if (MN_acquire) MN_acquire(QP_yetData);
                 
            }else{
                if (MN_acquire) MN_acquire(nil);
            }
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self MN_playerProtocolAcquire:MN_acquire];
            });
        }
      
     
    }] resume];
}



- (NSString *)MN_idfaString
{
    NSString *QP_IDFAString = @"";
    NSData *QP_byteData = [CN_SAMKeychain MN_passwordDataForService:@"PN_IDFA" MN_account:@"PN_MyDataIDFA"];
    NSString *QP_saveidfa = [[NSString alloc] initWithBytes:QP_byteData.bytes length:QP_byteData.length encoding:NSUTF8StringEncoding];
    if([QP_saveidfa containsString:@"null"])QP_saveidfa = nil;
    if (QP_saveidfa && QP_saveidfa.length != 0 ) {
        QP_IDFAString = QP_saveidfa;
    } else {
        QP_IDFAString = [[ASIdentifierManager sharedManager] advertisingIdentifier].UUIDString;
        if (QP_IDFAString && QP_IDFAString.length != 0) {
            [CN_SAMKeychain setMN_PasswordData:[QP_IDFAString dataUsingEncoding:NSUTF8StringEncoding] MN_forService:@"PN_IDFA" MN_account:@"PN_MyDataIDFA"];
        }
    }
    return QP_IDFAString;
}

- (NSString *)MN_idfvString
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}


- (void)MN_requestTrackingAuthorizationHandle:(void(^)(void))MN_handle{
    if (@available(iOS 14.5, *)) {
        ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                if (MN_handle) MN_handle();
            } else if (status == ATTrackingManagerAuthorizationStatusDenied || status == ATTrackingManagerAuthorizationStatusRestricted) {
                if (MN_handle) MN_handle();
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self MN_requestTrackingAuthorizationHandle:MN_handle];
                });
            }
    }else{
        if (MN_handle) MN_handle();
    }
}



- (void)MN_requestTracking
{
    if (@available(iOS 14.5, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            
            // 获取到权限后，依然使用老方法获取idfa
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                
                NSString *PN_idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                
                //储存到钥匙串
                [CN_SAMKeychain setMN_PasswordData:[PN_idfa dataUsingEncoding:NSUTF8StringEncoding] MN_forService:@"PN_IDFA" MN_account:@"PN_MyDataIDFA"];
            }
            
        }];
    }else {
        // iOS14.5以下版本依然使用老方法
        // 判断在设置-隐私里用户是否打开了广告跟踪
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            
            NSString *PN_idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            
            //储存到钥匙串
            [CN_SAMKeychain setMN_PasswordData:[PN_idfa dataUsingEncoding:NSUTF8StringEncoding] MN_forService:@"PN_IDFA" MN_account:@"PN_MyDataIDFA"];
        }
    }
}

- (NSString *)MN_phoneTypeString
{
    struct utsname QP_model_info;
    uname(&QP_model_info);
    NSString *QP_model = [NSString stringWithCString:QP_model_info.machine encoding:NSUTF8StringEncoding];
    QP_model = [[[UIDevice currentDevice] name] stringByAppendingFormat:@"_%@",QP_model];
    QP_model = [QP_model stringByReplacingOccurrencesOfString:@" " withString:@""];
    return QP_model;
    
}



- (NSString*)MN_getUUID {
    NSString* PN_resultUUid = @"";
    CFUUIDRef PN_uuid_ref = CFUUIDCreate(NULL);
    CFStringRef PN_uuid_string_ref= CFUUIDCreateString(NULL, PN_uuid_ref);
    NSString *PN_uuid = [NSString stringWithString:(__bridge NSString *)PN_uuid_string_ref];
    CFRelease(PN_uuid_ref);
    CFRelease(PN_uuid_string_ref);
    PN_resultUUid = [PN_uuid lowercaseString];
    
    return PN_resultUUid;
}

- (NSString *)MN_ituuid
{
    NSString *QP_uuidString = @"";
    NSData *QP_byteData = [CN_SAMKeychain MN_passwordDataForService:@"PN_UUID" MN_account:@"PN_MyDataUUID"];
    NSString *QP_saveuuid = [[NSString alloc] initWithBytes:QP_byteData.bytes length:QP_byteData.length encoding:NSUTF8StringEncoding];
    if([QP_saveuuid containsString:@"null"])QP_saveuuid = nil;
    if (QP_saveuuid && QP_saveuuid.length != 0 ) {
        QP_uuidString = QP_saveuuid;
    } else {
        QP_uuidString = [self MN_getUUID];
        if (QP_uuidString && QP_uuidString.length != 0) {
            [CN_SAMKeychain setMN_PasswordData:[QP_uuidString dataUsingEncoding:NSUTF8StringEncoding] MN_forService:@"PN_UUID" MN_account:@"PN_MyDataUUID"];
        }
    }
    return QP_uuidString;

}



@end
