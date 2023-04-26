//
//  StoreShop.m
//  HoldOpportunity
//
//  Created by ylhd on 2023/4/24.
//

#import "StoreShop.h"
#import "CN_SKGameIAPManager.h"
#import "CN_OwnModel.h"

@implementation StoreShop

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)PN_Over_view
{
    
    for (UITouch *touch in touches) {
        CGPoint PN_Deter_node = [touch locationInNode:self];
        NSArray *PN_ComprisMyMArr = [self nodesAtPoint:PN_Deter_node];
        SKNode *PN_Basicnode = PN_ComprisMyMArr[0];
        //返回
        if([PN_Basicnode.name isEqualToString:@"getBack"]){
            SKScene *GOStart_scene = [SKScene nodeWithFileNamed:@"WorldTree"];
            GOStart_scene.scaleMode = SKSceneScaleModeFill;
            [self.scene.view presentScene:GOStart_scene transition:[SKTransition moveInWithDirection:3 duration:1.3]];
        }
        
        //购买
        if([PN_Basicnode.name containsString:@"price"]){

            NSArray *PN_goinsArr = @[@(1), @(6), @(12), @(18)];
            //购买的物品
            NSInteger QP_shopNum = [self MN_numericValueOfString:PN_Basicnode.name];
            NSString *PN_productId = [NSString stringWithFormat:@"sjwdh.ofwhi.qoed%@",[[PN_goinsArr objectAtIndex:QP_shopNum] stringValue]];
            [[CN_SKGameIAPManager MN_share] MN_inPurchaseWithInfo:PN_productId MN_withBlock:^(BOOL success) {
                if (success) {
                    //回调
//                    NSLog(@"购买成功");
                    //道具数量增加
                    if(QP_shopNum == 0)[[CN_OwnModel alloc] MN_SaveToModel:@[@1,@0,@0,@0] MN_jiaOrjian:YES];
                    if(QP_shopNum == 1)[[CN_OwnModel alloc] MN_SaveToModel:@[@0,@1,@0,@0] MN_jiaOrjian:YES];
                    if(QP_shopNum == 2)[[CN_OwnModel alloc] MN_SaveToModel:@[@0,@0,@1,@0] MN_jiaOrjian:YES];
                    if(QP_shopNum == 3)[[CN_OwnModel alloc] MN_SaveToModel:@[@0,@0,@0,@1] MN_jiaOrjian:YES];
                    

                }
            }];

        }

    }

}

#pragma mark -- 获取字符串中数字
-(int)MN_numericValueOfString:(NSString *)PN_string {
    NSMutableArray *QP_characters = [NSMutableArray array];
    NSMutableString *QP_numericString = [NSMutableString string];

    // 将字符串中的每个字符添加到字符数组中
    for (NSUInteger i = 0; i < PN_string.length; i ++) {
        NSString *QP_substring = [PN_string substringWithRange:NSMakeRange(i, 1)];
        [QP_characters addObject:QP_substring];
    }

    // 对于字符数组中的每个元素，如果是数字则将其添加到数字字符串中
    for (NSString *QP_character in QP_characters) {
        NSString *QP_regex = @"^\\d*$";
        NSPredicate *QP_predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", QP_regex];
        BOOL QP_isDigit = [QP_predicate evaluateWithObject:QP_character];
        if (QP_isDigit) {
            [QP_numericString appendString:QP_character];
        }
    }

    // 返回数字字符串的浮点值
    return [QP_numericString intValue];
}


@end
