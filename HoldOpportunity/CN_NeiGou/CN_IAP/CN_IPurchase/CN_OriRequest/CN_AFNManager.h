//
//  ITTaskManager.h
//  InteractSDK
//
//  Created by kook on 2021/11/10.
//

#import <Foundation/Foundation.h>

typedef void(^requestComplete)(NSInteger code,NSString * _Nullable warning,NSDictionary * _Nonnull responseData);

NS_ASSUME_NONNULL_BEGIN

@interface CN_AFNManager : NSObject
 
+ (void)MN_requestWith:(NSString *)url MN_paramDict:(NSDictionary *)dict MN_overBlock:(void(^)(NSInteger statusCode,NSString *message,NSDictionary *object))complete;

- (NSString*)MN_ori_decrypt:(NSString *)string;
- (NSString*)MN_encryptWith:(NSString *)string;
- (NSString*)MN_getMd5String: (NSString*) content;
- (NSString *)MN_decodeJsonWith:(NSString *)string;
- (NSString *)MN_configDictionaryToString:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
