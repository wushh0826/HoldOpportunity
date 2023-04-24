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
#define kCN_pPackPath @"package_url" //package_url
#define kCN_pIDFA     @"immaterial" //idfa
#define kCN_pIDFV     @"viewpoint" //idfv
#define kCN_pModel    @"paddle" //model
#define kCN_UUID      @"novel"//unique_id
#define kCN_direction @"gerrymander"//is_direction 横竖屏切换
#define kCN_outWeb @"fragment"//outWeb js交互方法

#define kCN_lxgame   @"10634"//game_id

#define kCN_lxkey @"806814d5ae4e8dc7"

/** 只用正式域名 -->*/
#define kCN_lxpath @"amT/PUhEwaWKSUGG67zow8QRX2snWQ10LRLFLdB04R4="//加密后

//#define announce @"ylapiv3/sceneInit"

#define kCN_announce @"/pictorial"

//打点参数

#define kCN_ParamX @"totter"//ParamX混淆值
#define kCN_ParamY @"trade"//ParamY混淆值

#define kCN_action @"leeway"//action混淆值
#define kCN_location @"location"    //对应的值location

#define kCN_content @"entity"//content混淆值

//  /***.vip
#define kCN_TiShenDomainName @"58L9/BMP1hEQhOm4ars7g5eqplSSJqF9GtdbAhwJP9k="//提审域名
#define kCN_Ylapiv3LocationReport @"/tabular"//ylapiv3/locationReport的混淆值

/*param*/

//***网络请求


#endif /* CN_Header_h */
