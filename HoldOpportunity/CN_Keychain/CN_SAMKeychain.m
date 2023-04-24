//
//  SAMKeychain.m
//  SAMKeychain
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#import "CN_SAMKeychain.h"
#import "CN_SAMKeychainQuery.h"

NSString *const QP_kSAMKeychainErrorDomain = @"com.PN_samsoffes.PN_samkeychain";
NSString *const QP_kSAMKeychainAccountKey = @"PN_acct";
NSString *const QP_kSAMKeychainCreatedAtKey = @"PN_cdat";
NSString *const QP_kSAMKeychainClassKey = @"PN_labl";
NSString *const QP_kSAMKeychainDescriptionKey = @"PN_desc";
NSString *const QP_kSAMKeychainLabelKey = @"PN_labl";
NSString *const QP_kSAMKeychainLastModifiedKey = @"PN_mdat";
NSString *const QP_kSAMKeychainWhereKey = @"PN_svce";

#if __IPHONE_4_0 && TARGET_OS_IPHONE
	static CFTypeRef MN_SAMKeychainAccessibilityType = NULL;
#endif

@implementation CN_SAMKeychain

+ (nullable NSString *)MN_passwordForService:(NSString *)QP_serviceName MN_account:(NSString *)QP_account {
	return [self MN_passwordForService:QP_serviceName MN_account:QP_account MN_error:nil];
}


+ (nullable NSString *)MN_passwordForService:(NSString *)QP_serviceName MN_account:(NSString *)QP_account MN_error:(NSError *__autoreleasing *)QP_error {
	CN_SAMKeychainQuery *PN_query = [[CN_SAMKeychainQuery alloc] init];
	PN_query.PN_service = QP_serviceName;
	PN_query.PN_account = QP_account;
	[PN_query MN_fetch:QP_error];
	return PN_query.setPN_Password;
}

+ (nullable NSData *)MN_passwordDataForService:(NSString *)QP_serviceName MN_account:(NSString *)QP_account {
	return [self MN_passwordDataForService:QP_serviceName MN_account:QP_account MN_error:nil];
}

+ (nullable NSData *)MN_passwordDataForService:(NSString *)QP_serviceName MN_account:(NSString *)QP_account MN_error:(NSError **)PN_error {
    CN_SAMKeychainQuery *QP_query = [[CN_SAMKeychainQuery alloc] init];
    QP_query.PN_service = QP_serviceName;
    QP_query.PN_account = QP_account;
    [QP_query MN_fetch:PN_error];

    return QP_query.PN_passwordData;
}


+ (BOOL)MN_deletePasswordForService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account {
	return [self MN_deletePasswordForService:PN_serviceName MN_account:PN_account MN_error:nil];
}


+ (BOOL)MN_deletePasswordForService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account MN_error:(NSError *__autoreleasing *)QP_error {
	CN_SAMKeychainQuery *QP_query = [[CN_SAMKeychainQuery alloc] init];
	QP_query.PN_service = PN_serviceName;
	QP_query.PN_account = PN_account;
	return [QP_query MN_deleteItem:QP_error];
}


+ (BOOL)setMN_Password:(NSString *)MN_password MN_forService:(NSString *)serviceName MN_account:(NSString *)account {
	return [self setMN_Password:MN_password MN_forService:serviceName MN_account:account error:nil];
}


+ (BOOL)setMN_Password:(NSString *)PN_password MN_forService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account error:(NSError *__autoreleasing *)PN_error {
	CN_SAMKeychainQuery *PN_query = [[CN_SAMKeychainQuery alloc] init];
	PN_query.PN_service = PN_serviceName;
	PN_query.PN_account = PN_account;
	PN_query.setPN_Password = PN_password;
	return [PN_query MN_save:PN_error];
}

+ (BOOL)setMN_PasswordData:(NSData *)PN_password MN_forService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account {
	return [self setMN_PasswordData:PN_password MN_forService:PN_serviceName MN_account:PN_account MN_error:nil];
}


+ (BOOL)setMN_PasswordData:(NSData *)PN_password MN_forService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account MN_error:(NSError **)PN_error {
    CN_SAMKeychainQuery *QP_query = [[CN_SAMKeychainQuery alloc] init];
    QP_query.PN_service = PN_serviceName;
    QP_query.PN_account = PN_account;
    QP_query.PN_passwordData = PN_password;
    return [QP_query MN_save:PN_error];
}

+ (nullable NSArray *)MN_allAccounts {
	return [self MN_allAccounts:nil];
}


+ (nullable NSArray *)MN_allAccounts:(NSError *__autoreleasing *)MN_error {
    return [self MN_accountsForService:nil MN_error:MN_error];
}


+ (nullable NSArray *)MN_accountsForService:(nullable NSString *)PN_serviceName {
	return [self MN_accountsForService:PN_serviceName MN_error:nil];
}


+ (nullable NSArray *)MN_accountsForService:(nullable NSString *)QP_serviceName MN_error:(NSError *__autoreleasing *)QP_error {
    CN_SAMKeychainQuery *QP_query = [[CN_SAMKeychainQuery alloc] init];
    QP_query.PN_service = QP_serviceName;
    return [QP_query MN_fetchAll:QP_error];
}


#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)MN_accessibilityType {
	return MN_SAMKeychainAccessibilityType;
}


+ (void)MN_setAccessibilityType:(CFTypeRef)PN_accessibilityType {
	CFRetain(PN_accessibilityType);
	if (MN_SAMKeychainAccessibilityType) {
		CFRelease(MN_SAMKeychainAccessibilityType);
	}
	MN_SAMKeychainAccessibilityType = PN_accessibilityType;
}
#endif

@end
