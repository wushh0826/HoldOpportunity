//
//  GOStart.m
//  HoldOpportunity
//
//  Created by ylhd on 2023/4/21.
//

#import "GOStart.h"

@implementation GOStart

- (void)didMoveToView:(SKView *)view
{
    SKNode *optionsNode = (SKNode *)[self childNodeWithName:@"options"];
    
    [optionsNode runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:1.0 duration:1.3],[SKAction scaleTo:2.0 duration:1.3]]]]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    SKScene *GOStart_scene = [SKScene nodeWithFileNamed:@"WorldTree"];
    GOStart_scene.scaleMode = SKSceneScaleModeFill;
    [self.scene.view presentScene:GOStart_scene transition:[SKTransition flipHorizontalWithDuration:1.0]];
}

@end
