//
//  WorldTree.m
//  HoldOpportunity
//
//  Created by ylhd on 2023/4/24.
//

#import "WorldTree.h"
#import "CN_OwnModel.h"

@implementation WorldTree
{
    SKNode *explainInfo;
}

- (void)didMoveToView:(SKView *)view
{
//    [[CN_OwnModel alloc] MN_SaveToModel:@[@10,@10,@10,@10] MN_jiaOrjian:YES];
    explainInfo = (SKNode *)[self childNodeWithName:@"explainInfo"];
    
    //显示最高分数
    NSInteger HighScores = [[NSUserDefaults standardUserDefaults] integerForKey:@"integral"];
    SKLabelNode *HighScoresLabel = (SKLabelNode *)[self childNodeWithName:@"HighScores"];
    
    HighScoresLabel.text = [NSString stringWithFormat:@"High scores：%ld",HighScores];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches){
        CGPoint location = [touch locationInNode:self];
        NSArray *array = [self nodesAtPoint:location];
        SKNode *WorldNode = array[0];
        
        //玩法说明
        if([WorldNode.name isEqualToString:@"explain"]){
            explainInfo.hidden = NO;
        }
        
        if([WorldNode.name isEqualToString:@"explainInfo"]){
            explainInfo.hidden = YES;
        }
        
        //返回
        if([WorldNode.name isEqualToString:@"getBack"]){
            SKScene *GOStart_scene = [SKScene nodeWithFileNamed:@"GOStart"];
            GOStart_scene.scaleMode = SKSceneScaleModeFill;
            [self.scene.view presentScene:GOStart_scene transition:[SKTransition moveInWithDirection:3 duration:1.3]];
        }
        
        
        //小游戏界面
        if([WorldNode.name containsString:@"customs"]){
            SKScene *GOGame_scene = [SKScene nodeWithFileNamed:@"GameScene"];
            GOGame_scene.scaleMode = SKSceneScaleModeFill;
            [self.scene.view presentScene:GOGame_scene transition:[SKTransition doorwayWithDuration:1.3]];
        }
        
        //内购界面
        if([WorldNode.name containsString:@"store"]){
            SKScene *store_scene = [SKScene nodeWithFileNamed:@"StoreShop"];
            store_scene.scaleMode = SKSceneScaleModeFill;
            [self.scene.view presentScene:store_scene transition:[SKTransition doorwayWithDuration:1.3]];
        }
        
    }
}

@end
