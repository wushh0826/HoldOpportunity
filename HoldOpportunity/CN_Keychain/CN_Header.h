//
//  CN_Header.h
//  ForwardTerrace
//
//  Created by ylhd on 2022/11/19.
//

#ifndef CN_Header_h
#define CN_Header_h

//网络请求***
/*param*/

//字符串加密
#import "CN_huuTool.h"

//base64解密
//#define kCN_Decode(a)               [CN_huuTool MN_URLDecodedString:a]

//ase 128 cbc 解密
#define kCN_AseCBCDecrypt(a)               [CN_huuTool MN_origiolEncryptWith:a]

#define kCN_pGameID   @"_distrait" //game_id
#define kCN_pData     @"broil" //data
#define kCN_pPackPath @"programing" //package_url
#define kCN_pIDFA     @"immaterial" //idfa
#define kCN_pIDFV     @"viewpoint" //idfv
#define kCN_pModel    @"paddle" //model
#define kCN_BundleId  @"reconstitute"//package_code
#define kCN_UUID      @"novel"//unique_id
#define kCN_direction @"gerrymander"//is_direction 横竖屏切换
#define kCN_outWeb @"fragment"//outWeb js交互方法

#define kCN_lxgame   @"10634"//game_id

#define kCN_lxkey @"ed1f09610f8736f2"

/** 只用正式域名 -->*/
#define kCN_lxpath @"cIdTZqWo8yVLAjhaSHsrMOygR6GsrS+WSm7crMP1mJM="//加密后

//#define announce @"ylapiv3/sceneInit"

#define kCN_announce @"/pictorial"

//打点参数

#define kCN_ParamX @"ptX"//ParamX混淆值
#define kCN_ParamY @"ptY"//ParamY混淆值

#define kCN_action @""//action混淆值
#define kCN_location @""    //对应的值location

#define kCN_content @"内容"//content混淆值

//  /***.vip
#define kCN_TiShenDomainName @"p6cN0OILGMBYaFIzH1DtPQ7InB3YpHhsKWc9JMXaLOLK9Xf3XwnnlyU3d6hWSSSd"//提审域名
#define kCN_Ylapiv3LocationReport @""//ylapiv3/locationReport的混淆值

/*param*/

//***网络请求

//内购
#import "CN_iap.h"


#endif /* CN_Header_h */
