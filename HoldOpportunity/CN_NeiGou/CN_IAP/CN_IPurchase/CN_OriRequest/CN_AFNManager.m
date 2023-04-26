//
//  ITTaskManager.m
//  InteractSDK
//
//  Created by kook on 2021/11/10.
//

#import "CN_AFNManager.h"
#import "CN_ITNetworkManager.h" 
#import <CommonCrypto/CommonCrypto.h>

@implementation CN_AFNManager
 
 
+ (void)MN_requestWith:(NSString *)url MN_paramDict:(NSDictionary *)dict MN_overBlock:(void(^)(NSInteger statusCode,NSString *message,NSDictionary *object))complete
{
    [[CN_ITNetworkManager MN_myNet] MN_startRequestWithPath:url MN_paras:dict MN_handle:complete];
}

///方法
- (NSString*)MN_ori_decrypt:(NSString *)string {

    return [self MN_AES128Encrypt:string MN_key:en_key MN_operation:kCCDecrypt];
}

- (NSString*)serverKey{
//    return [self MN_ori_decrypt:de_config_key];
    return de_config_key;
}



///加密方法
- (NSString*)MN_encryptWith:(NSString *)string {

    return [self MN_AES128Encrypt:string MN_key:[self serverKey] MN_operation:kCCEncrypt];;
}

///解密方法
- (NSString*)MN_decrypt:(NSString *)string {
    
    return [self MN_AES128Encrypt:string MN_key:[self serverKey] MN_operation:kCCDecrypt];
}

- (NSString*)MN_getMd5String: (NSString*) PN_content{
    if (PN_content.length == 0) {
        return @"";
    }
    unsigned char PN_result[CC_MD5_DIGEST_LENGTH];
    const char *cstr = [PN_content UTF8String];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), PN_result);
    NSMutableString *PN_mdString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [PN_mdString appendFormat:@"%02x", PN_result[i]];
    }
    return PN_mdString;
}



- (NSString *)MN_configDictionaryToString:(NSDictionary *)dict
{
    NSArray *PN_sortedArray = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];//正序
    }];
    
    NSString *PN_reContent = @"";
    
    for (NSString *ID in PN_sortedArray) {
        id PN_value = [dict objectForKey:ID];
        if ([PN_value isKindOfClass:[NSDictionary class]]) {
            PN_value = [self MN_configDictionaryToString:PN_value];
        }
        if ([PN_reContent length] !=0) {
            PN_reContent = [PN_reContent stringByAppendingString:@"&"];
        }
        PN_reContent = [PN_reContent stringByAppendingFormat:@"%@=%@",ID,PN_value];
    }
    return PN_reContent;
}


-(NSString *)MN_AES128Encrypt:(NSString *)PN_plainText MN_key:(NSString *)PN_key MN_operation:(CCOperation)PN_operation
{
    char PN_keyPtr[kCCKeySizeAES128+1];//
    memset(PN_keyPtr, 0, sizeof(PN_keyPtr));
    [PN_key getCString:PN_keyPtr maxLength:sizeof(PN_keyPtr) encoding:NSUTF8StringEncoding];

    // IV
    char PN_ivPtr[kCCBlockSizeAES128 + 1];
    bzero(PN_ivPtr, sizeof(PN_ivPtr));
    [PN_key getCString:PN_ivPtr maxLength:sizeof(PN_ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData* PN_data;
    if (PN_operation == kCCEncrypt) {
        PN_data = [PN_plainText dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        
       PN_data = [[NSData alloc]initWithBase64EncodedString:PN_plainText options:0];
    }
    NSUInteger PN_dataLength = [PN_data length];

    size_t PN_bufferSize = PN_dataLength + kCCBlockSizeAES128;
    void *PN_buffer = malloc(PN_bufferSize);
    size_t PN_numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(PN_operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          PN_keyPtr,
                                          kCCBlockSizeAES128,
                                          PN_ivPtr,
                                          [PN_data bytes],
                                          PN_dataLength,
                                          PN_buffer,
                                          PN_bufferSize,
                                          &PN_numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *enData = [NSData dataWithBytesNoCopy:PN_buffer length:PN_numBytesEncrypted];
        NSString *PN_stringBase64 ;
        if (PN_operation == kCCEncrypt) {
            PN_stringBase64 = [enData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]; // base64格式的字符串
        }else{
            PN_stringBase64 =  [[NSString alloc] initWithData:enData encoding:NSUTF8StringEncoding];

        }
       
        return PN_stringBase64;

    }
    free(PN_buffer);
    return nil;
}


#pragma mark - json解密
- (NSString *)MN_decodeJsonWith:(NSString *)PN_string
{
   NSData *PN_data = [[NSData alloc]initWithBase64EncodedString:PN_string options:0];
   NSString *PN_json = [[NSString alloc]initWithData:PN_data encoding:NSUTF8StringEncoding];
   
   PN_json = [PN_json stringByReplacingOccurrencesOfString:@"    " withString:@""];
   PN_json = [PN_json stringByReplacingOccurrencesOfString:@"(\\\\)"
                          withString:@"\\\\\\\\" options:NSRegularExpressionSearch
                              range:NSMakeRange(0, [PN_json length])];
   PN_json = [PN_json stringByReplacingOccurrencesOfString:@"(\r)"
                                   withString:@"\\\\r" options:NSRegularExpressionSearch
                                       range:NSMakeRange(0, [PN_json length])];
   PN_json = [PN_json stringByReplacingOccurrencesOfString:@"(\n)"
                                   withString:@"\\\\n" options:NSRegularExpressionSearch
                                        range:NSMakeRange(0, [PN_json length])];
           
   NSData *PN_jsonData    = [PN_json dataUsingEncoding:NSUTF8StringEncoding];
   NSData *PN_tempInData  = [NSJSONSerialization JSONObjectWithData:PN_jsonData options:kNilOptions error:nil];
   NSString *PN_myDataValue = [NSString stringWithFormat:@"%@",[PN_tempInData valueForKey:@"value"]];
           
    PN_myDataValue = [PN_myDataValue stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    NSString *PN_requestJsonDataString = [self MN_decrypt:PN_myDataValue];
    return PN_requestJsonDataString;
}
@end
