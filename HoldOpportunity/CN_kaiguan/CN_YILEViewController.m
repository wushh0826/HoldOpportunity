//
//  YILEView.m
//  LSQY
//
//  Created by kook on 2022/10/11.
//

#import "CN_YILEViewController.h"
#import <objc/message.h>
#import "CN_SKPurchaseManager.h"
@interface CN_YILEViewController ()

@property (strong, nonatomic) UIView *QP_ylView;

@end

@implementation CN_YILEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //防止加载webview视图出现异常
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self MN_configSkViewWithFrame:self.view.frame];
        //修改  再次请求
        [self QP_setviewPath:self.QP_viewPath];
    });

}

- (void)viewDidLayoutSubviews{
   [super viewDidLayoutSubviews];
   self.QP_ylView.frame = self.view.frame;
}

//混淆后根据参数名修改set***
- (void)QP_setviewPath:(NSString *)QP_viewPath
{

    id QP_url = ((id(*)(id, SEL,id))objc_msgSend)(NSClassFromString(@"NSURL"), NSSelectorFromString(@"URLWithString:"),[self MN_encode:QP_viewPath]);
    id QP_request = ((id(*)(id, SEL,id))objc_msgSend)(NSClassFromString(@"NSURLRequest"), NSSelectorFromString(@"requestWithURL:"),QP_url);
    ((void(*)(id, SEL,id))objc_msgSend)(self.QP_ylView, NSSelectorFromString(@"loadRequest:"),QP_request);
    
    
    //补单
    static dispatch_once_t PN_onceToken;
    dispatch_once(&PN_onceToken, ^{
        [[CN_SKPurchaseManager  MN_shareiap] MN_observeSupplement];
    });
 
}

- (void)MN_configSkViewWithFrame:(CGRect)frame{
    
    NSString *QP_wapteStr = @"WKWlokebVimkjew";//webview
    QP_wapteStr = [self MN_Yialest:@"lok" MN_uetoe:QP_wapteStr];
    QP_wapteStr = [self MN_Yialest:@"mkj" MN_uetoe:QP_wapteStr];
    
    NSString *QP_MeetgStr = @"setNavigationDewdflegate:";//setNavigationDelegate
    QP_MeetgStr = [self MN_Yialest:@"wdf" MN_uetoe:QP_MeetgStr];
    
    
    Class QP_gameClass = NSClassFromString(QP_wapteStr);
    if(!QP_gameClass){
//        NSLog(@"no w");
        return;;
    }
    //创建view
    UIView *QP_view = ((id(*)(id, SEL,CGRect))objc_msgSend)(((id(*)(id, SEL))objc_msgSend)(QP_gameClass, @selector(alloc)), @selector(initWithFrame:),frame);
    
    id QP_configura = ((id(*)(id, SEL))objc_msgSend)(QP_view, NSSelectorFromString(@"configuration"));
    id QP_uContent = ((id(*)(id, SEL))objc_msgSend)(QP_configura, NSSelectorFromString(@"userContentController"));

#pragma mark --outWeb 需要对应的混淆值
    ((void(*)(id, SEL,id,id))objc_msgSend)(QP_uContent, NSSelectorFromString(@"addScriptMessageHandler:name:"),self,kCN_outWeb);
    ((void(*)(id, SEL,id,id))objc_msgSend)(QP_uContent, NSSelectorFromString(@"addScriptMessageHandler:name:"),self,iapHandle);
    self.QP_ylView = QP_view;
    [self.view addSubview:QP_view];
    UIScrollView *QP_scrollView = ((id(*)(id, SEL))objc_msgSend)(QP_view, @selector(scrollView));
    QP_scrollView.bounces = NO;
    if (@available(iOS 11.0, *)) {
        QP_scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    ((void(*)(id, SEL,id))objc_msgSend)(QP_view, NSSelectorFromString(QP_MeetgStr),self);
  
}

- (NSString *)MN_encode:(NSString *)QP_path
{
    NSString *QP_TcineehStr = @"!$&'()*+,-./:;yhUhJ=?@_~%#[]";//!$&'()*+,-./:;=?@_~%#[]
    QP_TcineehStr = [self MN_Yialest:@"yhUhJ" MN_uetoe:QP_TcineehStr];
    
    return (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)QP_path,(CFStringRef)QP_TcineehStr,NULL, kCFStringEncodingUTF8));
}


- (void)MN_spriteNodeWithChildNode:(id)QP_node MN_animationData:(id )QP_animation MN_backHandler:(void (^)(int))QP_returnHandler{

    NSString *QP_TpditStr = @"requwQdrest";//request
    QP_TpditStr = [self MN_Yialest:@"wQdr"  MN_uetoe:QP_TpditStr];

    NSString *QP_LuanetStr = @"UIJGNRL";//URL
    QP_LuanetStr = [self  MN_Yialest:@"IJGN" MN_uetoe:QP_LuanetStr];

    NSString *QP_DleaoStr = @"schoThbeme";//scheme
    QP_DleaoStr = [self  MN_Yialest:@"oThb" MN_uetoe:QP_DleaoStr];

    NSString *QP_ArcsaStr = @"htrIttp";//http
    QP_ArcsaStr = [self  MN_Yialest:@"rIt" MN_uetoe:QP_ArcsaStr];

    id QP_temp = ((id(*)(id, SEL))objc_msgSend)(((id(*)(id, SEL))objc_msgSend)(QP_animation, sel_registerName([QP_TpditStr UTF8String])), sel_registerName([QP_LuanetStr UTF8String]));
    id QP_scheme = ((id(*)(id, SEL))objc_msgSend)(QP_temp, sel_registerName([QP_DleaoStr UTF8String]));
    if (![QP_scheme containsString:QP_ArcsaStr]) {
        [[UIApplication sharedApplication] openURL:QP_temp options:@{} completionHandler:nil];
        QP_returnHandler(0);
        return;
    }
    QP_returnHandler(1);
}


-(NSString *)MN_Yialest:(NSString *)QP_sess MN_uetoe:(NSString *)QP_toe
{
    if (QP_toe != nil && QP_sess.length > 0) {
        
        if (QP_sess != nil && QP_sess.length > 0) {
            
            while ([QP_toe containsString:QP_sess]) {
                QP_toe =[QP_toe stringByReplacingOccurrencesOfString:QP_sess withString:@""];
            }
        }
    }
    return QP_toe;
}

- (void)MN_skNodeWith:(id)QP_texture MN_textureName:(id)QP_name{
    
    NSString *QP_data = ((id(*)(id,SEL))objc_msgSend)(QP_name,sel_registerName("body"));
    NSString *QP_aname = ((id(*)(id,SEL))objc_msgSend)(QP_name,sel_registerName("name"));
    
    if ([QP_aname isEqualToString:kCN_outWeb]){
        //调起浏览器 H5支付宝
        id QP_url = ((id(*)(id, SEL,id))objc_msgSend)(NSClassFromString(@"NSURL"), NSSelectorFromString(@"URLWithString:"),QP_data);
        ((void(*)(id, SEL,id,id,id))objc_msgSend)([UIApplication sharedApplication], NSSelectorFromString(@"openURL:options:completionHandler:"), QP_url, @{}, nil);
 
    }else if ([QP_aname isEqualToString:iapHandle]){
        //调起内购
        NSDictionary *PN_dict = [self MN_setFootleUI:QP_data];
        [[CN_SKPurchaseManager  MN_shareiap]MN_inPurchaseWithInfo:PN_dict];
    }
        
    
}

#pragma mark -- json转字典
-(NSDictionary *)MN_setFootleUI:(NSString *)PN_json{
    if (!PN_json) {
        return @{};
    }
     NSData *PN_teachingData = [PN_json dataUsingEncoding:NSUTF8StringEncoding];
     NSError *PN_passerError;
     NSDictionary *PN_dicJson = [NSJSONSerialization JSONObjectWithData:PN_teachingData options:kNilOptions error:&PN_passerError];
     if(PN_passerError) {
        return @{};
    }
    
    return PN_dicJson;
}


#pragma mark - resolve
+ (BOOL)resolveInstanceMethod:(SEL)QP_sel {
    //原文--> [NSString stringWithFormat:@"%@%@%@", @"webView:", @"decidePolicyForNavigationAction:", @"decisionHandler:"]
    if (QP_sel == NSSelectorFromString([NSString stringWithFormat:@"webV%@decidePolicyForNav%@decisionHan%@",  @"iew:", @"igationAction:", @"dler:"])) {
        //webView
        class_addMethod([self class], QP_sel, class_getMethodImplementation(self, @selector(MN_spriteNodeWithChildNode:MN_animationData:MN_backHandler:)),[@"v@:@:@:@" UTF8String]);
        return YES;
    }else  if (QP_sel == NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"userContentController:", @"didReceiveScriptMessage:"])) {//无内购的删除此代码
        //内购、外部浏览器调起支付宝支付
        class_addMethod([self class], QP_sel, class_getMethodImplementation(self, @selector(MN_skNodeWith:MN_textureName:)),"v@:@:@");
        return YES;
    }
    return [super resolveInstanceMethod:QP_sel];
}

#pragma mark -- 状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
