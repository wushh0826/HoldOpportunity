//
//  CN_OwnModel.m
//  HoldOpportunity
//
//  Created by ylhd on 2023/4/25.
//

#import "CN_OwnModel.h"

#define PN_PropOne @"PN_propOne"
#define PN_PropTwo  @"PN_propTwo"
#define PN_PropThree  @"PN_propThree"
#define PN_PropFour  @"PN_propFour"


@implementation CN_OwnModel
{
    NSMutableDictionary *PN_tempDict;
}

static CN_OwnModel *PN_OwnModelinit = nil;
+ (CN_OwnModel *)MN_ShareManager
{
    @synchronized(self)
    {
        if (PN_OwnModelinit == nil)
        {
            PN_OwnModelinit = [[CN_OwnModel alloc] init];

        }
    }
    return PN_OwnModelinit;
}

//需要实现NSCoding中的协议的两个方法
- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self == [super init]) {
        self.PN_propOne = [[aDecoder decodeObjectForKey:PN_PropOne] intValue];
        self.PN_propTwo = [[aDecoder decodeObjectForKey:PN_PropTwo] intValue];
        self.PN_propThree = [[aDecoder decodeObjectForKey:PN_PropThree] intValue];
        self.PN_propFour = [[aDecoder decodeObjectForKey:PN_PropFour] intValue];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    //NSInteger
//    [aCoder encodeObject:self.name forKey:Name];
    
    //NSInteger
    [aCoder encodeObject:[NSNumber numberWithInteger:self.PN_propOne] forKey:PN_PropOne];
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.PN_propTwo] forKey:PN_PropTwo];
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.PN_propThree] forKey:PN_PropThree];
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.PN_propFour] forKey:PN_PropFour];
}

- (NSString *)description{
    
    NSLog(@"%@",[NSString stringWithFormat:@"%d--%d--%d--%d",self.PN_propOne,self.PN_propTwo,self.PN_propThree,self.PN_propFour]);
    
    return [NSString stringWithFormat:@"%d--%d--%d--%d",self.PN_propOne,self.PN_propTwo,self.PN_propThree,self.PN_propFour];
}


-(void)MN_SaveToModel:(NSArray *)PN_saveToArr MN_jiaOrjian:(BOOL)PN_IsOR
{
    if(PN_saveToArr.count == 0)return;
    
    //读取字典
    [self MN_ReadToModel];
    CN_POS PN_getPos;
    [PN_tempDict[@"PN_OwnDictionary"] getValue:&PN_getPos];
    
    //创建对象 并赋值
    CN_OwnModel *QP_model = [[CN_OwnModel alloc]init];
    if(PN_IsOR){
        switch (PN_saveToArr.count) {
            case 1:
                QP_model.PN_propOne = PN_getPos.PN_propOne + [PN_saveToArr[0] intValue];
                break;
            case 2:
                QP_model.PN_propOne = PN_getPos.PN_propOne + [PN_saveToArr[0] intValue];
                QP_model.PN_propTwo = PN_getPos.PN_propTwo + [PN_saveToArr[1] intValue];
                break;
            case 3:
                QP_model.PN_propOne = PN_getPos.PN_propOne + [PN_saveToArr[0] intValue];
                QP_model.PN_propTwo = PN_getPos.PN_propTwo + [PN_saveToArr[1] intValue];
                QP_model.PN_propThree = PN_getPos.PN_propThree + [PN_saveToArr[2] intValue];
                break;
            case 4:
                QP_model.PN_propOne = PN_getPos.PN_propOne + [PN_saveToArr[0] intValue];
                QP_model.PN_propTwo = PN_getPos.PN_propTwo + [PN_saveToArr[1] intValue];
                QP_model.PN_propThree = PN_getPos.PN_propThree + [PN_saveToArr[2] intValue];
                QP_model.PN_propFour = PN_getPos.PN_propFour + [PN_saveToArr[3] intValue];
                break;
            default:
                break;
        }
    }else{
        switch (PN_saveToArr.count) {
            case 1:
                QP_model.PN_propOne = PN_getPos.PN_propOne - [PN_saveToArr[0] intValue];
                break;
            case 2:
                QP_model.PN_propOne = PN_getPos.PN_propOne - [PN_saveToArr[0] intValue];
                QP_model.PN_propTwo = PN_getPos.PN_propTwo - [PN_saveToArr[1] intValue];
                break;
            case 3:
                QP_model.PN_propOne = PN_getPos.PN_propOne - [PN_saveToArr[0] intValue];
                QP_model.PN_propTwo = PN_getPos.PN_propTwo - [PN_saveToArr[1] intValue];
                QP_model.PN_propThree = PN_getPos.PN_propThree - [PN_saveToArr[2] intValue];
                break;
            case 4:
                QP_model.PN_propOne = PN_getPos.PN_propOne - [PN_saveToArr[0] intValue];
                QP_model.PN_propTwo = PN_getPos.PN_propTwo - [PN_saveToArr[1] intValue];
                QP_model.PN_propThree = PN_getPos.PN_propThree - [PN_saveToArr[2] intValue];
                QP_model.PN_propFour = PN_getPos.PN_propFour - [PN_saveToArr[3] intValue];
                break;
            default:
                break;
        }
    }
    
     //归档
    NSMutableData *PN_data = [[NSMutableData alloc] init];
    //创建归档辅助类
    NSKeyedArchiver *PN_archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:PN_data];
    //编码
    [PN_archiver encodeObject:QP_model forKey:@"PN_model"];
    //结束编码
    [PN_archiver finishEncoding];
    //写入到沙盒
    NSArray *PN_array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *PN_fileName = [PN_array.firstObject stringByAppendingPathComponent:@"PN_archiverModel"];
    if([PN_data writeToFile:PN_fileName atomically:YES]){
//        NSLog(@"归档成功");
    }
}

-(NSMutableDictionary *)MN_ReadToModel
{
    //字典
    PN_tempDict = [NSMutableDictionary dictionary];
    CN_POS PN_pos;
    
    //储存文件
    NSArray *QP_array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *QP_fileName = [QP_array.firstObject stringByAppendingPathComponent:@"PN_archiverModel"];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    //判断当前文件存在不
     if ([fileManager fileExistsAtPath: QP_fileName]) {
//         NSLog(@"存在,读取默认值");
         //解档
         NSData *QP_undata = [[NSData alloc] initWithContentsOfFile:QP_fileName];
         //解档辅助类
         NSKeyedUnarchiver *QP_unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:QP_undata];
         //解码并解档出model
         CN_OwnModel *QP_unModel = [QP_unarchiver decodeObjectForKey:@"PN_model"];
     
         //存入字典
         PN_pos.PN_propOne = QP_unModel.PN_propOne;
         PN_pos.PN_propTwo = QP_unModel.PN_propTwo;
         PN_pos.PN_propThree = QP_unModel.PN_propThree;
         PN_pos.PN_propFour = QP_unModel.PN_propFour;
         NSValue * QP_valueSE = [NSValue valueWithBytes:&PN_pos objCType:@encode(CN_POS)];
         [PN_tempDict setValue:QP_valueSE forKey:@"PN_OwnDictionary"];
     
         //关闭解档
         [QP_unarchiver finishDecoding];

    }else{

//        NSLog(@"不存在,设置默认值");
        //创建对象 并赋值
        CN_OwnModel *QP_model = [[CN_OwnModel alloc]init];
        QP_model.PN_propOne = 0;
        QP_model.PN_propTwo = 0;
        QP_model.PN_propThree = 0;
        QP_model.PN_propFour = 0;
         //归档
        NSMutableData *PN_data = [[NSMutableData alloc] init];
        //创建归档辅助类
        NSKeyedArchiver *PN_archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:PN_data];
        //编码
        [PN_archiver encodeObject:QP_model forKey:@"PN_model"];
        //结束编码
        [PN_archiver finishEncoding];
        //写入到沙盒
        NSArray *PN_array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *PN_fileName = [PN_array.firstObject stringByAppendingPathComponent:@"PN_archiverModel"];
        
        [PN_data writeToFile:PN_fileName atomically:YES];
        
        //存入字典
        PN_pos.PN_propOne = QP_model.PN_propOne;
        PN_pos.PN_propTwo = QP_model.PN_propTwo;
        PN_pos.PN_propThree = QP_model.PN_propThree;
        PN_pos.PN_propFour = QP_model.PN_propFour;
        NSValue * QP_valueSE = [NSValue valueWithBytes:&PN_pos objCType:@encode(CN_POS)];
        [PN_tempDict setValue:QP_valueSE forKey:@"PN_OwnDictionary"];

     }

    return PN_tempDict;

}


@end
