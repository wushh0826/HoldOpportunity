//
//  GameScene.m
//  HoldOpportunity
//
//  Created by ylhd on 2023/4/20.
//

#import "GameScene.h"
#import "CN_OwnModel.h"
#import "CN_HintNode.h"

@interface GameScene ()<SKPhysicsContactDelegate>
// 属性
@property (nonatomic, assign)CGFloat PN_squareLength;//游戏方块的长度
@property (nonatomic, assign)CGPoint PN_backgroundOrigin;//背景方块的长度

@property (nonatomic, strong)NSMutableArray *PN_squareArray;//游戏方块的数组
@property (nonatomic, strong)NSMutableArray *PN_findArray;//需要销毁的方块数组

@property (nonatomic, strong)dispatch_queue_t dealQueue;//创建一个子线程

// 自定义用户界面
- (void)initializePN_DataSource;/**< 初始化数据源 */
- (void)initializeUserPN_Interface;/**< 初始化用户界面 */

@property (nonatomic, strong) SKSpriteNode   *focusNode;//人物

@end

@implementation GameScene
{
    NSTimeInterval _LastCurrentTime;//记录上次执行时间
    SKSpriteNode *_settleNode;//结算界面
    
    //小狐狸
    SKSpriteNode *PN_littleFox;
    BOOL PN_IsMop;//是否可以拖动
    
    SKCameraNode *PN_cameraNode;
    SKSpriteNode *PN_mapNode;
    
    NSInteger integral;//积分
    SKLabelNode *integralLabel;
    
    CN_POS PN_getPos;//存储数据字典
    
    int QP_propOne;
    int QP_propTwo;
    int QP_propThree;
    int QP_propFour;

}


#pragma mark -初始化
- (void)didMoveToView:(SKView *)view
{
    // 初始化数据源一定要在初始化用户界面之前
    [self initializePN_DataSource];
    [self initializeUserPN_Interface];
    
    [self addBackSquare];
    [self addSquare];
    
    //结算界面
    _settleNode = (SKSpriteNode *)[self childNodeWithName:@"//settle"];

    //积分
    integral = _extendScore;
    integralLabel = (SKLabelNode *)[self childNodeWithName:@"//integral"];
    
    //读取数据
    NSMutableDictionary *PN_tempDict = [[CN_OwnModel MN_ShareManager] MN_ReadToModel];
//    CN_POS PN_getPos;
    [PN_tempDict[@"PN_OwnDictionary"] getValue:&PN_getPos];
//    NSLog(@"%d",PN_getPos.PN_propOne);

    QP_propOne = PN_getPos.PN_propOne;
    QP_propTwo = PN_getPos.PN_propTwo;
    QP_propThree = PN_getPos.PN_propThree;
    QP_propFour = PN_getPos.PN_propFour;

}

#pragma mark -初始化数据源 方块放置和数据处理
- (void)initializePN_DataSource {
    _PN_squareArray = [[NSMutableArray alloc] init];
    _PN_findArray = [[NSMutableArray alloc] init];
    _dealQueue = dispatch_queue_create("com.wushh.colorful", DISPATCH_QUEUE_SERIAL);
}

- (void)initializeUserPN_Interface {
    
    //设置镜头移动
    
    self.focusNode = (SKSpriteNode *)[self childNodeWithName:@"//focus"];//移动的焦点
    [self.focusNode runAction:[SKAction moveToY:19000.0 duration:200] withKey:@"moveLittleFox"];
    
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:10.0],[SKAction runBlock:^{
        [self removeActionForKey:@"moveLittleFox"];
        [self.focusNode runAction:[SKAction moveToY:19000.0 duration:100] withKey:@"moveLittleFox"];
    }]]]];
    
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:20.0],[SKAction runBlock:^{
        [self removeActionForKey:@"moveLittleFox"];
        [self.focusNode runAction:[SKAction moveToY:19000.0 duration:80] withKey:@"moveLittleFox"];
    }]]]];
    
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:30.0],[SKAction runBlock:^{
        [self removeActionForKey:@"moveLittleFox"];
        [self.focusNode runAction:[SKAction moveToY:19000.0 duration:50] withKey:@"moveLittleFox"];
    }]]]];
    
    PN_cameraNode = (SKCameraNode *) [self childNodeWithName:@"//worldMapCamera"];//镜头
    PN_mapNode = (SKSpriteNode *)[self childNodeWithName:@"//worldMap"];//地图

    [self MN_Shceosaaafo:self.focusNode];

}

-(void)MN_Shceosaaafo:(SKNode *)MN_rhecemNode
{
    
    id PN_DokaesID = [SKConstraint distance:[SKRange rangeWithUpperLimit:0] toNode:MN_rhecemNode];
    id PN_tenteID = [SKConstraint distance:[SKRange rangeWithUpperLimit:0] toNode:MN_rhecemNode];
    id PN_omnID = [SKConstraint positionX:[SKRange rangeWithLowerLimit:PN_cameraNode.position.x]];
    id PN_bhaaeID = [SKConstraint positionX:[SKRange rangeWithUpperLimit:0 ]];
    id PN_FrtefoID = [SKConstraint positionY:[SKRange rangeWithLowerLimit:PN_cameraNode.position.y]];
    id PN_rhndtID = [SKConstraint positionY: [SKRange rangeWithUpperLimit:PN_mapNode.frame.size.height *9]];
    [PN_cameraNode setConstraints:@[PN_DokaesID,PN_tenteID,PN_omnID,PN_bhaaeID,PN_FrtefoID,PN_rhndtID]];

    //重立场
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
        self.physicsWorld.contactDelegate = self;

    });
}

-(void)addBackSquare {
    // 获取游戏屏幕的长宽
    CGFloat width = self.size.width;

    // 设置游戏区域的长宽和起始点
    _PN_squareLength = width / 5.3;
//    _squareLength = 120.5;
    _PN_backgroundOrigin = CGPointMake(-580, 0);

    // 挂载背景方格
    SKSpriteNode *node;
    for (NSInteger i = 0; i < 100; i ++) {
        for (NSInteger j = 0; j < 5; j ++) {
            node = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:CGSizeMake(_PN_squareLength, _PN_squareLength)];
            
            node.alpha = 0.031;
            // 设置布局的位置
            CGFloat positionX = _PN_backgroundOrigin.x + j * _PN_squareLength + _PN_squareLength / 2;
            CGFloat positionY = _PN_backgroundOrigin.y + i * _PN_squareLength + _PN_squareLength / 2;
            node.position = CGPointMake(positionX, positionY);

            // 将node的信息存入userdata中
            node.userData = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"backSquare", @"nodeType", [NSValue valueWithCGPoint:CGPointMake(positionX, positionY)],@"position", nil];
            node.name = @"backSquare";
            [self addChild:node];
        }
    }
}

// 添加游戏方块
-(void)addSquare {

    // 计算添加彩色方块的长度
    CGFloat colorSquareLength = _PN_squareLength - 5;

    // 随机取数
    int index;
    SKSpriteNode *node;

    //行
    for (NSInteger i = 0; i < 99; i ++) {
        //列
        NSMutableArray *NumArr=[[NSMutableArray alloc]initWithObjects:@0,@1,@2,@3,@4, nil];
        for (NSInteger j = 0; j < 5; j ++) {
            
            //特俗处理 第一列
            if(i == 0 ){
                if(j == 2){
                    if(PN_littleFox == nil){
                        //控制的方块
                        node = [[SKSpriteNode alloc] initWithImageNamed:@"紫色宠物"];
                        node.size = CGSizeMake(colorSquareLength, colorSquareLength);
                        node.color =[UIColor purpleColor];
                        
                        //小狐狸 节点赋值
                        PN_littleFox = node;
                        PN_littleFox.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:100 center:CGPointMake(0, -20)];
                        PN_littleFox.physicsBody.affectedByGravity = 0;   //设置重力为零
                            //设置物理体的标识符
                        PN_littleFox.physicsBody.categoryBitMask = 1;
                            //设置可与哪一类的物理体发生碰撞
                        PN_littleFox.physicsBody.contactTestBitMask = 9;
                    }else{
                        node = PN_littleFox;
                    }

                }else{
                    //空白
                    continue;
                }
                
            }else{
                
                //每一行颜色唯一 removeObject
                int PN_OnlyNum = arc4random()%NumArr.count;
                index = [NumArr[PN_OnlyNum] intValue];
                
                switch (index) {
                    case 0:
                        node = [[SKSpriteNode alloc] initWithImageNamed:@"黄色云"];
                        node.size = CGSizeMake(colorSquareLength, colorSquareLength);
                        node.color =[UIColor yellowColor];
                        [NumArr removeObject:NumArr[PN_OnlyNum]];
                        break;
                    case 1:
                        node = [[SKSpriteNode alloc] initWithImageNamed:@"蓝色云"];
                        node.size = CGSizeMake(colorSquareLength, colorSquareLength);
                        node.color =[UIColor blueColor];
                        [NumArr removeObject:NumArr[PN_OnlyNum]];
                        break;
                    case 2:
                        node = [[SKSpriteNode alloc] initWithImageNamed:@"粉色云"];
                        node.size = CGSizeMake(colorSquareLength, colorSquareLength);
                        node.color =[UIColor systemPinkColor];
                        [NumArr removeObject:NumArr[PN_OnlyNum]];
                        break;
                    case 3:
                        node = [[SKSpriteNode alloc] initWithImageNamed:@"红色云"];
                        node.size = CGSizeMake(colorSquareLength, colorSquareLength);
                        node.color =[UIColor orangeColor];
                        [NumArr removeObject:NumArr[PN_OnlyNum]];
                        break;
                    case 4:
                        node = [[SKSpriteNode alloc] initWithImageNamed:@"紫色云"];
                        node.size = CGSizeMake(colorSquareLength, colorSquareLength);
                        node.color =[UIColor purpleColor];
                        [NumArr removeObject:NumArr[PN_OnlyNum]];
                        break;
                    default:
                        break;
                }
            }
            

            // 指定节点的位置
            CGFloat positionX = _PN_backgroundOrigin.x + _PN_squareLength * j + _PN_squareLength / 2;
            CGFloat positionY = _PN_backgroundOrigin.y + _PN_squareLength * i + _PN_squareLength / 2;
            node.position = CGPointMake(positionX, positionY);

            // 将node的信息存入userdata中
            node.userData = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"colorSquare", @"nodeType", [NSValue valueWithCGPoint:CGPointMake(positionX, positionY)],@"position", [node color], @"color", @"YES", @"exsit", nil];
            node.name = @"colorSquare";

            [_PN_squareArray addObject:node];

            [self addChild:node];
        }
    }
}


#pragma mark - 点触
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{


    // 获得点击的点
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *PN_PreviouPassportcont = [self nodesAtPoint:location];
    SKNode *node = PN_PreviouPassportcont.firstObject;
    
    //返回
    if ([node.name isEqualToString:@"getBack"])
    {
        //跳转场景
        SKScene *WorldTreeScene = [SKScene nodeWithFileNamed:@"WorldTree"];
        WorldTreeScene.scaleMode = SKSceneScaleModeFill;
        [self.scene.view presentScene:WorldTreeScene transition:[SKTransition crossFadeWithDuration:0.8]];

    }
    
    //结算
    if ([node isEqualToNode:_settleNode])
    {
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"integral"] > integral
           || [[NSUserDefaults standardUserDefaults] integerForKey:@"integral"] == 0){
            //记录最高分数
            [[NSUserDefaults standardUserDefaults] setInteger:integral?:0 forKey:@"integral"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //跳转场景
        GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"WorldTree"];
        scene.scaleMode = SKSceneScaleModeFill;
        [self.scene.view presentScene:scene transition:[SKTransition flipVerticalWithDuration:0.8]];

    }
    
    //复活
    if ([node.name isEqualToString:@"resurgence"])
    {
        if(QP_propFour >0){
            //道具减1
            QP_propFour --;
            [[CN_OwnModel alloc] MN_SaveToModel:@[@0,@0,@0,@1] MN_jiaOrjian:NO];
            
            GameScene *scene = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];
            scene.scaleMode = SKSceneScaleModeFill;
            scene.extendScore = integral;
            [self.scene.view presentScene:scene transition:[SKTransition doorwayWithDuration:0.8]];
            
        }else{
            [self MN_publicHint:@"你尚未拥有该道具,请先购买"];
        }

    }
    
    //小狐狸
    if ([node isEqualToNode:PN_littleFox])
    {
        //可拖动
        PN_IsMop = YES;

    }
    
    //道具1
    if ([node.name isEqualToString:@"useItem1"])
    {
        if(QP_propOne >0){
            //道具减1
            QP_propOne --;
            [[CN_OwnModel alloc] MN_SaveToModel:@[@1,@0,@0,@0] MN_jiaOrjian:NO];
            [self MN_usePoporLine:1];
            
        }else{
            [self MN_publicHint:@"你尚未拥有该道具,请先购买"];
        }
    }
    
    //道具2
    if ([node.name isEqualToString:@"useItem2"])
    {
        if(QP_propTwo >0){
            //道具减1
            QP_propTwo --;
            [[CN_OwnModel alloc] MN_SaveToModel:@[@0,@1,@0,@0] MN_jiaOrjian:NO];
            [self MN_usePoporLine:2];
            
        }else{
            [self MN_publicHint:@"你尚未拥有该道具,请先购买"];
        }

    }
    
    //道具3
    if ([node.name isEqualToString:@"useItem3"])
    {

        if(QP_propThree > 0){
            //道具减1
            QP_propThree --;
            [[CN_OwnModel alloc] MN_SaveToModel:@[@0,@0,@1,@0] MN_jiaOrjian:NO];
            [self MN_usePoporLine:3];
            
        }else{
            [self MN_publicHint:@"你尚未拥有该道具,请先购买"];
        }

    }
    


}

#pragma mark -- 道具使用 消除多行
-(void)MN_usePoporLine:(int)PN_LineNum
{
    for(int i = 1;i <= PN_LineNum;i++){
        CGFloat upNodePositionY = PN_littleFox.position.y + _PN_squareLength * i;
        
        NSArray *upNodeArr = [self nodesAtPoint:CGPointMake(PN_littleFox.position.x, upNodePositionY)];
        for(SKNode *presentNode in upNodeArr){
                if ([presentNode.name isEqualToString:@"colorSquare"]) {
                    if (![_PN_findArray containsObject:presentNode]) {
                        [_PN_findArray addObject:presentNode];
                        //整行消除
                        [self DealLineNode:presentNode AndNsMutableArray:_PN_findArray];
                    }
                    
                }
            }

        for (SKNode *node in _PN_findArray) {
            if([node isEqualToNode:PN_littleFox])continue;//跳过删除小狐狸节点
            [node.userData setObject:@"NO" forKey:@"exsit"];
            SKAction *fadeOut = [SKAction fadeOutWithDuration:0.2];
            SKAction *removeAction = [SKAction removeFromParent];
            SKAction *all = [SKAction sequence:@[fadeOut, removeAction]];
            [node runAction:all completion:^{
                [self->_PN_squareArray removeObject:node];

            }];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    UITouch *PN_LargemodelLeast = touches.anyObject;
    CGPoint PN_RecentlGoodluck = [PN_LargemodelLeast locationInNode:self];
    //小狐狸是否可拖动
    if(PN_IsMop){
        [PN_littleFox runAction:[SKAction moveToX:PN_RecentlGoodluck.x duration:0.1] ];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

//    UITouch *PN_LargemodelLeast = touches.anyObject;
//    CGPoint PN_RecentlGoodluck = [PN_LargemodelLeast locationInNode:self];
    //小狐狸是否可拖动
    if(PN_IsMop){
       
        //消除同色
        __weak typeof(self) weakSelf = self;
        //异步处理
        dispatch_async(self->_dealQueue, ^{
            [weakSelf dealWithColorNode:self->PN_littleFox];

        });

        
        PN_IsMop = NO;
    }else{
        self.userInteractionEnabled = YES;
    }
    
}

#pragma mark - 逻辑处理
- (void)dealWithColorNode:(SKNode *)node {
    [self findFourDirectSquareOfSKNode:node AndNsMutableArray:_PN_findArray];
    
    //点击消除一个
//    if (_findArray.count == 1) {
//        self.userInteractionEnabled = YES;
//        return;
//    }

    for (SKNode *node in _PN_findArray) {
        if([node isEqualToNode:PN_littleFox])continue;//跳过删除小狐狸节点
        [node.userData setObject:@"NO" forKey:@"exsit"];
        SKAction *fadeOut = [SKAction fadeOutWithDuration:0.2];
        SKAction *removeAction = [SKAction removeFromParent];
        SKAction *all = [SKAction sequence:@[fadeOut, removeAction]];
        [node runAction:all completion:^{
            [self->_PN_squareArray removeObject:node];

        }];
    }

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self squareDown:[self needEndDown]];//方块向下
//    });

}

// 向上查找是否有相同颜色的node
- (void)findFourDirectSquareOfSKNode:(SKNode *)node AndNsMutableArray:(NSMutableArray *)findArray {

    if (![findArray containsObject:node]) {
        [findArray addObject:node];
    }
//    CGFloat height = self.size.height;
    CGFloat height = 100 * _PN_squareLength;//最大高度
    
    // 获取node的x，y的坐标
    CGFloat positionX = node.position.x;
    CGFloat positionY = node.position.y;

    CGFloat maxY = _PN_backgroundOrigin.y+_PN_squareLength/2 + _PN_squareLength*(height / _PN_squareLength);
    CGFloat upNodePositionY = positionY + _PN_squareLength;

//    SKNode *upNode;

    if (upNodePositionY <= maxY) {
        NSArray *upNodeArr = [self nodesAtPoint:CGPointMake(positionX, upNodePositionY)];
        for(SKNode *presentNode in upNodeArr){
            if ([self isSameColorNode:node WithNode:presentNode]) {
                if (![_PN_findArray containsObject:presentNode]) {
                    [_PN_findArray addObject:presentNode];
                    //整行消除
                    [self DealLineNode:presentNode AndNsMutableArray:_PN_findArray];
                    [self findFourDirectSquareOfSKNode:presentNode AndNsMutableArray:findArray];
                }
            }
        }
    }
    
}

#pragma mark -- 整行删除
- (void)DealLineNode:(SKNode *)node AndNsMutableArray:(NSMutableArray *)findArray {
    
    integral += 1;//积分

    CGFloat leftNodePositionX = node.position.x - _PN_squareLength;
    CGFloat rightNodePositionX = node.position.x + _PN_squareLength;

    //整行消除
    NSArray *leftNodeArr = [self nodesAtPoint:CGPointMake(leftNodePositionX, node.position.y)];
    for(SKNode *leftNode in leftNodeArr){
        if ([leftNode.name isEqualToString:@"colorSquare"]) {
            if (![_PN_findArray containsObject:leftNode]) {
                [_PN_findArray addObject:leftNode];
                [self DealLineNode:leftNode AndNsMutableArray:_PN_findArray];
            }
            
        }
    }
    NSArray *rightNodeArr = [self nodesAtPoint:CGPointMake(rightNodePositionX, node.position.y)];
    for(SKNode *rightNode in rightNodeArr){
        if ([rightNode.name isEqualToString:@"colorSquare"]) {
            if (![_PN_findArray containsObject:rightNode]) {
                [_PN_findArray addObject:rightNode];
                [self DealLineNode:rightNode AndNsMutableArray:_PN_findArray];
            }
        }
    }
    
    // 移动
    SKAction *moveAction = [SKAction moveTo:CGPointMake(node.position.x, node.position.y) duration:0];
    [PN_littleFox runAction:moveAction completion:^{
        NSMutableDictionary *userData = self->PN_littleFox.userData;
        [userData setObject:[NSValue valueWithCGPoint:CGPointMake(self->PN_littleFox.position.x, node.position.y)] forKey:@"position"];
        self->PN_littleFox.userData = userData;
    }];
    
}

// 判断node是否为相同颜色的
- (BOOL)isSameColorNode:(SKNode *)node WithNode:(SKNode *)OtherNode {
    return [[node.userData objectForKey:@"color"] isEqual:[OtherNode.userData objectForKey:@"color"]];
}

// 让findArray中node上方的节点落下
- (void)squareDown:(NSMutableArray *)needDownArray {
    if (needDownArray && needDownArray.count) {
        SKNode *node = needDownArray.firstObject;
        NSInteger number = [self howManyCaseToFallWithSKNode:node];

        // 改变userdata
        CGFloat positionY = node.position.y - number * _PN_squareLength;

        // 移动
        SKAction *moveAction = [SKAction moveTo:CGPointMake(node.position.x, positionY) duration:0];
        [node runAction:moveAction completion:^{
            NSMutableDictionary *userData = node.userData;
            [userData setObject:[NSValue valueWithCGPoint:CGPointMake(node.position.x, positionY)] forKey:@"position"];
            node.userData = userData;
            [needDownArray removeObject:node];
            [self squareDown:needDownArray];
        }];
    }

}


#pragma mark -- 现存方块
- (NSMutableArray *)needEndDown {
    NSMutableDictionary *needDownNodeDic = [[NSMutableDictionary alloc] init];

//    CGFloat height = self.size.height;
    CGFloat height = 100 * _PN_squareLength;//最大高度
    CGFloat maxY = _PN_backgroundOrigin.y + _PN_squareLength / 2 + height;

    for (SKNode *node in _PN_findArray) {
        CGFloat positionX = node.position.x;
        CGFloat positionY = node.position.y;

        NSNumber *positionX_num = [NSNumber numberWithFloat:positionX];
        NSNumber *positionY_num = [NSNumber numberWithFloat:positionY];

        if (![needDownNodeDic objectForKey:positionX_num]) {
            [needDownNodeDic setObject:positionY_num forKey:positionX_num];
        }else {
            NSNumber *oldNumberOfY = [needDownNodeDic objectForKey:positionX_num];
            CGFloat oldY = [oldNumberOfY floatValue];
            CGFloat minPositionY = oldY < positionY ? oldY : positionY;
            NSNumber *maxNumberX = [NSNumber numberWithFloat:minPositionY];
            [needDownNodeDic setObject:maxNumberX forKey:positionX_num];
        }
    }

    NSMutableArray *nodeArray = [[NSMutableArray alloc] init];
    NSArray *keysArray = [needDownNodeDic allKeys];
    for (NSNumber *key in keysArray) {
        CGFloat minPositionY = [[needDownNodeDic objectForKey:key] floatValue];
        CGFloat positionX = [key floatValue];
        for (NSInteger i = 1; minPositionY + (i * _PN_squareLength) <= maxY; i ++) {
            CGFloat nodePositionY = minPositionY + (i * _PN_squareLength);
            __block SKNode *node = nil;
            NSArray<SKNode*> * nodes = [self nodesAtPoint:CGPointMake(positionX, nodePositionY)];
            [nodes enumerateObjectsUsingBlock:^(SKNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.name isEqualToString:@"colorSquare"]) {
                    node = obj;
                    *stop = true;
                }
            }];
            if ([node.name isEqualToString:@"colorSquare"]) {
                [nodeArray addObject:node];
            }
        }
    }
    return nodeArray;
}


//方块下落
- (NSInteger)howManyCaseToFallWithSKNode:(SKNode *)node {

    CGFloat minY = _PN_backgroundOrigin.y + _PN_squareLength / 2;

    CGFloat positionX = node.position.x;
    CGFloat positionY = node.position.y;

    NSInteger fallNumber;
    for (fallNumber = 1; positionY - fallNumber * _PN_squareLength >= minY; fallNumber ++) {
        CGFloat downPositionY = positionY - fallNumber * _PN_squareLength;
        SKNode *downNode = [self nodeAtPoint:CGPointMake(positionX, downPositionY)];
        //不能掉落在小狐狸那行
        if ([downNode.name isEqualToString:@"colorSquare"] || downNode.position.y == PN_littleFox.position.y ) {
            break;
        }
    }
    return fallNumber - 1;
}

#pragma mark -碰撞
- (void)didBeginContact:(SKPhysicsContact *)contact
{
//    NSLog(@"A-->%@---B-->%@",contact.bodyA.node.name,contact.bodyB.node.name);
//    NSLog(@"A-->%u---B-->%u",contact.bodyA.categoryBitMask,contact.bodyB.categoryBitMask);
    
    //gameOver
    if ((contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 9)
        || (contact.bodyA.categoryBitMask == 9 && contact.bodyB.categoryBitMask == 1))
    {
        //结算界面
        _settleNode.alpha = 1.0;
        //复活道具出现
        SKNode *againNode = (SKNode*)[self childNodeWithName:@"//resurgence"];
        againNode.hidden = NO;
        
        [self MN_publicHint:@"可使用复活道具，继续冲关"];
        
        //小狐狸移除
        [PN_littleFox removeFromParent];
    }
}



#pragma mark -帧数
- (void)update:(NSTimeInterval)currentTime
{
    if(currentTime - _LastCurrentTime > 0.033)
    {
        //道具数量
        SKLabelNode *useItem1LabelNode = (SKLabelNode *)[self childNodeWithName:@"//useItem1Label"];
        useItem1LabelNode.text = [NSString stringWithFormat:@"x %d",QP_propOne];
        SKLabelNode *useItem2LabelNode = (SKLabelNode *)[self childNodeWithName:@"//useItem2Label"];
        useItem2LabelNode.text = [NSString stringWithFormat:@"x %d",QP_propTwo];
        SKLabelNode *useItem3LabelNode = (SKLabelNode *)[self childNodeWithName:@"//useItem3Label"];
        useItem3LabelNode.text = [NSString stringWithFormat:@"x %d",QP_propThree];
        SKLabelNode *useItem4LabelNode = (SKLabelNode *)[self childNodeWithName:@"//useItem4Label"];
        useItem4LabelNode.text = [NSString stringWithFormat:@"x %d",QP_propFour];
        
        //设置边界
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-1050, PN_cameraNode.position.y -1200, PN_mapNode.size.width *2.0, PN_mapNode.size.height * 1.5)];
        
        integralLabel.text = [NSString stringWithFormat:@"%ld",(long)integral];//积分
        
        self.physicsBody.categoryBitMask = 9;
        //记录上次执行时间
        _LastCurrentTime = currentTime;
    }
}


-(void)MN_publicHint:(NSString *)PN_HintStr
{
    CN_HintNode *PN_hintNode = [[CN_HintNode alloc] initWithText:PN_HintStr MN_fontSize:80.0f];
    PN_hintNode.position = CGPointZero;
    PN_hintNode.zPosition = 78;
    [PN_cameraNode addChild:PN_hintNode];
}

@end
