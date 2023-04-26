//
//  ITNetworkManager.m
//  InteractSDK
//
//  Created by kook on 2021/10/20.
//

#import "CN_ITNetworkManager.h"
#import "CN_AFNManager.h"

@implementation CN_ITNetworkManager

+ (CN_ITNetworkManager*)MN_myNet
{
    static id PN_share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PN_share = [[self alloc] init];
    });
    return PN_share;
}

- (NSString *)main_host
{
    return [[CN_AFNManager alloc] MN_ori_decrypt:domainUrl];
}


- (void)MN_startRequestWithPath:(NSString *)PN_requestURL MN_paras:(NSDictionary *)params MN_handle:(void(^)(NSInteger statusCode,NSString *PN_message,NSDictionary *object))PN_complete {
    
    NSString *PN_requestUrl = [self.main_host stringByAppendingString:PN_requestURL];
    NSLog(@"main_host: %@", self.main_host);
    NSMutableDictionary *PN_mainParams = [NSMutableDictionary dictionaryWithDictionary:@{}];
     [PN_mainParams addEntriesFromDictionary:params];
    
    NSString *info = @"";
    if ([PN_mainParams.allKeys containsObject:ParaInfo]) {
        info = [PN_mainParams valueForKey:ParaInfo];
        [PN_mainParams removeObjectForKey:ParaInfo];
    }
    
    NSString *PN_content = @"";
    if ([PN_mainParams.allKeys containsObject:ParaContent]) {
        PN_content = [PN_mainParams valueForKey:ParaContent];
        [PN_mainParams removeObjectForKey:ParaContent];
    }
    
    
    NSString *PN_requestMsg = [NSString stringWithFormat:@"%@&%@", [[CN_AFNManager alloc] MN_configDictionaryToString:PN_mainParams],game_key];
    
    [PN_mainParams setValue:[[CN_AFNManager alloc] MN_getMd5String:PN_requestMsg] forKey:ParaSign];
    
    if (info) {
        [PN_mainParams setValue:info forKey:ParaInfo];
    }
    
    if (PN_content) {
        [PN_mainParams setValue:PN_content forKey:ParaContent];
    }
  
    
    NSString *requestContent  = [[CN_AFNManager alloc] MN_configDictionaryToString:PN_mainParams];
    
    NSString *body = [[CN_AFNManager alloc] MN_encryptWith:requestContent];
    
    NSMutableDictionary *PN_bodyDict = [NSMutableDictionary new];
    [PN_bodyDict setValue:body forKey:ParaParas];
    
    NSMutableURLRequest *PN_itRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:PN_requestUrl]];
    PN_itRequest.timeoutInterval = 25;
    PN_itRequest.HTTPMethod = @"POST";
    [PN_itRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    PN_itRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:PN_bodyDict options:NSJSONWritingPrettyPrinted error:nil];
    
    NSLog(@"URL--------%@,ParaS-%@",PN_requestUrl,PN_bodyDict);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:PN_itRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            if (PN_complete) {
                PN_complete(error.code, error.localizedDescription, @{});
            }
        } else {
  
            NSString *PN_result =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                ///解密方法
            NSString *requestJsonDataString = [[CN_AFNManager alloc] MN_decodeJsonWith:PN_result];;
            
                if (requestJsonDataString == nil) {
                    if (PN_complete) {
                        PN_complete(990, @"无法解密请求结果!", @{});
                    }
                    return;
                }
                NSData *PN_requestJsonData = [requestJsonDataString dataUsingEncoding:NSUTF8StringEncoding];
                id PN_jsonToData = [NSJSONSerialization JSONObjectWithData:PN_requestJsonData options:kNilOptions error:nil];
    
                if ([PN_jsonToData isKindOfClass:[NSDictionary class]]) {
                
                    //数据
                    NSDictionary *PN_dicResult = [PN_jsonToData valueForKey:ParaData];
                    //statuCode
                    NSString *PN_netCode = [NSString stringWithFormat:@"%@",[PN_jsonToData valueForKey:ParaCode]];
                    //tips
                    NSString *requestMsg = [NSString stringWithFormat:@"%@",[PN_jsonToData valueForKey:ParaMsg]];
                    NSLog(@"jsonToData: %@", PN_jsonToData);
                    if (PN_complete) {
                        PN_complete(PN_netCode.integerValue, requestMsg, PN_dicResult?:@{});
                    }
                    
                } else {
                    if (PN_complete) {
                        PN_complete(2001, @"服务端返回数据无法解析!", @{});
                    }
                }
                
              

        }
        
        }] resume];
    
    
}


@end
