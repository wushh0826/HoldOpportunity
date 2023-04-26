//
//  CN_OwnModel.h
//  HoldOpportunity
//
//  Created by ylhd on 2023/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CN_OwnModel : NSObject <NSCoding>    //解归档需要遵循Nscoding协议，并实现相关方法

+ (CN_OwnModel *)MN_ShareManager;

- (NSString *)description;

//各道具

@property (nonatomic,assign) int PN_propOne;

@property (nonatomic,assign) int PN_propTwo;

@property (nonatomic,assign) int PN_propThree;

@property (nonatomic,assign) int PN_propFour;

//保存数据
-(void)MN_SaveToModel:(NSArray *)PN_saveToArr MN_jiaOrjian:(BOOL)PN_IsOR;

//读取数据
-(NSMutableDictionary *)MN_ReadToModel;

//结构体定义示例
typedef struct {
    int PN_propOne;
    int PN_propTwo;
    int PN_propThree;
    int PN_propFour;
} CN_POS;

@end

NS_ASSUME_NONNULL_END
