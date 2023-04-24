//
//  GOStart.m
//  HoldOpportunity
//
//  Created by ylhd on 2023/4/21.
//

#import "GOStart.h"

@implementation GOStart

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SKScene *GOStart_scene = [SKScene nodeWithFileNamed:@"GameScene"];
    GOStart_scene.scaleMode = SKSceneScaleModeFill;
    [self.scene.view presentScene:GOStart_scene transition:[SKTransition flipHorizontalWithDuration:1.0]];
}

@end
