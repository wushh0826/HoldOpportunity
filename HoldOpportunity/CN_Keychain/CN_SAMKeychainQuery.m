//
//  SAMKeychainQuery.m
//  SAMKeychain
//
//  Created by Caleb Davenport on 3/19/13.
//  Copyright (c) 2013-2014 Sam Soffes. All rights reserved.
//

#import "CN_SAMKeychainQuery.h"
#import "CN_SAMKeychain.h"

@implementation CN_SAMKeychainQuery

@synthesize PN_account = _PN_account;
@synthesize PN_service = _PN_service;
@synthesize PN_label = _PN_label;
@synthesize PN_passwordData = _PN_passwordData;

#ifdef SAMKEYCHAIN_ACCESS_GROUP_AVAILABLE
@synthesize PN_accessGroup = _PN_accessGroup;
#endif

#ifdef SAMKEYCHAIN_SYNCHRONIZATION_AVAILABLE
@synthesize PN_synchronizationMode = _PN_synchronizationMode;
#endif

#pragma mark - Public

- (BOOL)MN_save:(NSError *__autoreleasing *)PN_error {
	OSStatus QP_status = PN_SAMKeychainErrorBadArguments;
	if (!self.PN_service || !self.PN_account || !self.PN_passwordData) {
		if (PN_error) {
			*PN_error = [[self class] MN_errorWithCode:QP_status];
		}
		return NO;
	}
	NSMutableDictionary *QP_query = nil;
	NSMutableDictionary * QP_searchQuery = [self MN_query];
	QP_status = SecItemCopyMatching((__bridge CFDictionaryRef)QP_searchQuery, nil);
	if (QP_status == errSecSuccess) {//item already exists, update it!
		QP_query = [[NSMutableDictionary alloc]init];
		[QP_query setObject:self.PN_passwordData forKey:(__bridge id)kSecValueData];
#if __IPHONE_4_0 && TARGET_OS_IPHONE
		CFTypeRef MN_accessibilityType = [CN_SAMKeychain MN_accessibilityType];
		if (MN_accessibilityType) {
			[QP_query setObject:(__bridge id)MN_accessibilityType forKey:(__bridge id)kSecAttrAccessible];
		}
#endif
		QP_status = SecItemUpdate((__bridge CFDictionaryRef)(QP_searchQuery), (__bridge CFDictionaryRef)(QP_query));
	}else if(QP_status == errSecItemNotFound){//item not found, create it!
		QP_query = [self MN_query];
		if (self.PN_label) {
			[QP_query setObject:self.PN_label forKey:(__bridge id)kSecAttrLabel];
		}
		[QP_query setObject:self.PN_passwordData forKey:(__bridge id)kSecValueData];
#if __IPHONE_4_0 && TARGET_OS_IPHONE
		CFTypeRef PN_accessibilityType = [CN_SAMKeychain MN_accessibilityType];
		if (PN_accessibilityType) {
			[QP_query setObject:(__bridge id)PN_accessibilityType forKey:(__bridge id)kSecAttrAccessible];
		}
#endif
		QP_status = SecItemAdd((__bridge CFDictionaryRef)QP_query, NULL);
	}
	if (QP_status != errSecSuccess && PN_error != NULL) {
		*PN_error = [[self class] MN_errorWithCode:QP_status];
	}
	return (QP_status == errSecSuccess);}


- (BOOL)MN_deleteItem:(NSError *__autoreleasing *)PN_error {
	OSStatus QP_status = PN_SAMKeychainErrorBadArguments;
	if (!self.PN_service || !self.PN_account) {
		if (PN_error) {
			*PN_error = [[self class] MN_errorWithCode:QP_status];
		}
		return NO;
	}

	NSMutableDictionary *QP_query = [self MN_query];
    
#if TARGET_OS_IPHONE
	QP_status = SecItemDelete((__bridge CFDictionaryRef)QP_query);
#else
	// On Mac OS, SecItemDelete will not delete a key created in a different
	// app, nor in a different version of the same app.
	//
	// To replicate the issue, save a password, change to the code and
	// rebuild the app, and then attempt to delete that password.
	//
	// This was true in OS X 10.6 and probably later versions as well.
	//
	// Work around it by using SecItemCopyMatching and SecKeychainItemDelete.
	CFTypeRef QP_result = NULL;
	[QP_query setObject:@YES forKey:(__bridge id)kSecReturnRef];
    QP_status = SecItemCopyMatching((__bridge CFDictionaryRef)QP_query, &QP_result);
	if (QP_status == errSecSuccess) {
        QP_status = SecKeychainItemDelete((SecKeychainItemRef)QP_result);
		CFRelease(QP_result);
	}
#endif

	if (QP_status != errSecSuccess && PN_error != NULL) {
		*PN_error = [[self class] MN_errorWithCode:QP_status];
	}

	return (QP_status == errSecSuccess);
}


- (nullable NSArray *)MN_fetchAll:(NSError *__autoreleasing *)PN_error {
	NSMutableDictionary *QP_query = [self MN_query];
	[QP_query setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
	[QP_query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
#if __IPHONE_4_0 && TARGET_OS_IPHONE
	CFTypeRef MN_accessibilityType = [CN_SAMKeychain MN_accessibilityType];
	if (MN_accessibilityType) {
		[QP_query setObject:(__bridge id)MN_accessibilityType forKey:(__bridge id)kSecAttrAccessible];
	}
#endif

	CFTypeRef PN_result = NULL;
	OSStatus MN_status = SecItemCopyMatching((__bridge CFDictionaryRef)QP_query, &PN_result);
	if (MN_status != errSecSuccess && PN_error != NULL) {
		*PN_error = [[self class] MN_errorWithCode:MN_status];
		return nil;
	}

	return (__bridge_transfer NSArray *)PN_result;
}


- (BOOL)MN_fetch:(NSError *__autoreleasing *)PN_error {
	OSStatus PN_status = PN_SAMKeychainErrorBadArguments;
	if (!self.PN_service || !self.PN_account) {
		if (PN_error) {
			*PN_error = [[self class] MN_errorWithCode:PN_status];
		}
		return NO;
	}

	CFTypeRef PN_result = NULL;
	NSMutableDictionary *QP_query = [self MN_query];
	[QP_query setObject:@YES forKey:(__bridge id)kSecReturnData];
	[QP_query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	PN_status = SecItemCopyMatching((__bridge CFDictionaryRef)QP_query, &PN_result);

	if (PN_status != errSecSuccess) {
		if (PN_error) {
			*PN_error = [[self class] MN_errorWithCode:PN_status];
		}
		return NO;
	}

	self.PN_passwordData = (__bridge_transfer NSData *)PN_result;
	return YES;
}


#pragma mark - Accessors

- (void)setMN_passwordObject:(id<NSCoding>)MN_object {
	self.PN_passwordData = [NSKeyedArchiver archivedDataWithRootObject:MN_object];
}


- (id<NSCoding>)MN_passwordObject {
	if ([self.PN_passwordData length]) {
		return [NSKeyedUnarchiver unarchiveObjectWithData:self.PN_passwordData];
	}
	return nil;
}


- (void)setPN_Password:(NSString *)PN_password {
	self.PN_passwordData = [PN_password dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)setPN_Password {
	if ([self.PN_passwordData length]) {
		return [[NSString alloc] initWithData:self.PN_passwordData encoding:NSUTF8StringEncoding];
	}
	return nil;
}


#pragma mark - Synchronization Status

#ifdef SAMKEYCHAIN_SYNCHRONIZATION_AVAILABLE
+ (BOOL)MN_isSynchronizationAvailable {
#if TARGET_OS_IPHONE
	// Apple suggested way to check for 7.0 at runtime
	// https://developer.apple.com/library/ios/documentation/userexperience/conceptual/transitionguide/SupportingEarlieriOS.html
	return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
#else
	return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_8_4;
#endif
}
#endif


#pragma mark - Private

- (NSMutableDictionary *)MN_query {
	NSMutableDictionary *PN_dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
	[PN_dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

	if (self.PN_service) {
		[PN_dictionary setObject:self.PN_service forKey:(__bridge id)kSecAttrService];
	}

	if (self.PN_account) {
		[PN_dictionary setObject:self.PN_account forKey:(__bridge id)kSecAttrAccount];
	}

#ifdef SAMKEYCHAIN_ACCESS_GROUP_AVAILABLE
#if !TARGET_IPHONE_SIMULATOR
	if (self.PN_accessGroup) {
		[PN_dictionary setObject:self.PN_accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
	}
#endif
#endif

#ifdef SAMKEYCHAIN_SYNCHRONIZATION_AVAILABLE
	if ([[self class] MN_isSynchronizationAvailable]) {
		id PN_value;

		switch (self.PN_synchronizationMode) {
			case     MN_SAMKeychainQuerySynchronizationModeNo: {
			  PN_value = @NO;
			  break;
			}
			case MN_SAMKeychainQuerySynchronizationModeYes: {
			  PN_value = @YES;
			  break;
			}
			case MN_SAMKeychainQuerySynchronizationModeAny: {
			  PN_value = (__bridge id)(kSecAttrSynchronizableAny);
			  break;
			}
		}

		[PN_dictionary setObject:PN_value forKey:(__bridge id)(kSecAttrSynchronizable)];
	}
#endif

	return PN_dictionary;
}


+ (NSError *)MN_errorWithCode:(OSStatus) QP_code {
	static dispatch_once_t onceToken;
	static NSBundle *PN_resourcesBundle = nil;
	dispatch_once(&onceToken, ^{
		NSURL *MN_url = [[NSBundle bundleForClass:[CN_SAMKeychainQuery class]] URLForResource:@"CN_OwnBundle" withExtension:@"bundle"];
		PN_resourcesBundle = [NSBundle bundleWithURL:MN_url];
	});
	
	NSString *PN_message = nil;
	switch (QP_code) {
		case errSecSuccess: return nil;
		case PN_SAMKeychainErrorBadArguments: PN_message = NSLocalizedStringFromTableInBundle(@"PN_SAMKeychainErrorBadArguments", @"PN_SAMKeychain", PN_resourcesBundle, nil); break;

#if TARGET_OS_IPHONE
		case errSecUnimplemented: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecUnimplemented", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		case errSecParam: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecParam", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		case errSecAllocate: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecAllocate", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		case errSecNotAvailable: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecNotAvailable", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		case errSecDuplicateItem: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecDuplicateItem", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		case errSecItemNotFound: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecItemNotFound", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		case errSecInteractionNotAllowed: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecInteractionNotAllowed", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		case errSecDecode: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecDecode", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		case errSecAuthFailed: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecAuthFailed", @"PN_SAMKeychain", PN_resourcesBundle, nil);
			break;
		}
		default: {
			PN_message = NSLocalizedStringFromTableInBundle(@"PN_errSecDefault", @"PN_SAMKeychain", PN_resourcesBundle, nil);
		}
#else
		default:
            PN_message = (__bridge_transfer NSString *)SecCopyErrorMessageString(QP_code, NULL);
#endif
	}

	NSDictionary *PN_userInfo = nil;
	if (PN_message) {
		PN_userInfo = @{ NSLocalizedDescriptionKey : PN_message };
	}
	return [NSError errorWithDomain:QP_kSAMKeychainErrorDomain code:QP_code userInfo:PN_userInfo];
}

@end
