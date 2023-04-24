//
//  CN_GameStart.m
//  MewUnexpected iOS
//
//  Created by ylhd on 2022/11/18.
//

#import "CN_GameStart.h"
#import "CN_Aootldxsso.h"
#import "CN_YILEViewController.h"
#import "AppDelegate.h"

@interface CN_GameStart ()

@property(nonatomic,strong)UIImageView *PN_HeiSeBgImg;//黑色层

@end

@implementation CN_GameStart

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
//    self.view.backgroundColor = [UIColor blackColor];

    
    //机型适配
//    [[CN_RepetitionTool alloc] MN_deviceInit];
    
    //启动页
    UIImageView *PN_hSeBgImg = [[UIImageView alloc] initWithFrame:self.view.frame];
//    #pragma mark -- imageNamed不能释放内存，会导致UIImage缓存
////    PN_hSeBgImg.image = [UIImage imageNamed:[CN_RepetitionTool MN_initWithBundleStr :@"jetoasbg"]];
    ///
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.png",[[NSBundle mainBundle] resourcePath],@"首页背景"];
    
    PN_hSeBgImg.image = [[UIImage alloc] initWithContentsOfFile:filePath];
    self.PN_HeiSeBgImg = PN_hSeBgImg;
    [self.view addSubview:self.PN_HeiSeBgImg];
     
    //请求api控制
    [[CN_huuTool alloc] MN_InitNetworkRequest:^(NSString * PN_intoStr  , BOOL PN_prepareBool) {

        if(PN_prepareBool){
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.PN_HeiSeBgImg removeFromSuperview];
                // 非主线程，将操作切换到主线程进行
                [self.PN_HeiSeBgImg removeFromSuperview];
                CN_YILEViewController *PN_NetControl = [[CN_YILEViewController alloc] init];
                PN_NetControl.QP_viewPath = PN_intoStr;
                [UIApplication sharedApplication].delegate.window.rootViewController = PN_NetControl;
            });

        }else{
            [self MN_first];
        }

    }];

}

#pragma mark  --小游戏

-(void)MN_first
{
//    [self.PN_HeiSeBgImg removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //小游戏视图
//        创建SKView视图
        SKView *PN_skView = [[SKView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:PN_skView];
        // Load the SKScene from 'GameScene.sks'
        SKScene *scene = [SKScene nodeWithFileNamed:@"GOStart"];
        scene.scaleMode = SKSceneScaleModeFill;
        [PN_skView presentScene:scene];
        
//        NSLog(@"进入小游戏");
        [self.PN_HeiSeBgImg removeFromSuperview];
    });
}

//屏幕旋转之后，约束的代码要重新被调用一次
//- (void)viewDidLayoutSubviews{
//   [super viewDidLayoutSubviews];
//    //横改成竖 更新启动图frame
//    if(self.PN_HeiSeBgImg == nil)return;
//    self.PN_HeiSeBgImg.frame = self.view.frame;
//    
//}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
