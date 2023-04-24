//
//  CN_huuTool.h
//  WordGame
//
//  Created by ylhd on 2022/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CN_huuTool : NSObject

//自定义base64解密
//+ (NSString *)MN_URLDecodedString:(NSString *)PN_String;

//ase cbc 解密
+(NSString *)MN_origiolEncryptWith:(NSString *)QP_plainText;

//网络请求
-(void)MN_InitNetworkRequest:(void (^)(NSString * , BOOL))QP_Handle;

//实例化
+ (CN_huuTool *)MN_ShareManager;

- (BOOL)MN_countries_AdidfaTime;//时间开关

@end

NS_ASSUME_NONNULL_END
