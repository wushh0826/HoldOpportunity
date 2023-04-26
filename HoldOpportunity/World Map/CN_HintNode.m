//
//  HintNode.m
//  ReachThePeak
//
//  Created by ylhd on 2023/3/14.
//

#import "CN_HintNode.h"

@implementation CN_HintNode

- (instancetype)initWithText:(NSString *)text MN_fontSize:(CGFloat)fontSize {
    self = [super init];
    if (self) {
        SKLabelNode *PN_labelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Bold"];
        PN_labelNode.fontSize = fontSize;
        PN_labelNode.text = text;
        PN_labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        PN_labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        PN_labelNode.fontColor = [SKColor whiteColor];
        
        SKSpriteNode *PN_backgroundNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:0.6 alpha:1.0] size:CGSizeMake(PN_labelNode.frame.size.width + 20, PN_labelNode.frame.size.height + 20)];
        PN_backgroundNode.position = CGPointZero;
//        PN_backgroundNode.zPosition = 0;
        
        [self addChild:PN_backgroundNode];
        [self addChild:PN_labelNode];
        
        SKAction *QP_fadeOut = [SKAction fadeOutWithDuration:0.5];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *sequence = [SKAction sequence:@[[SKAction waitForDuration:2.0], QP_fadeOut, remove]];
        [self runAction:sequence];
    }
    return self;
}

@end
