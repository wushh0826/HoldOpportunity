//
//  SAMKeychain.h
//  SAMKeychain
//
//  Created by Sam Soffes on 5/19/10.
//  Copyright (c) 2010-2014 Sam Soffes. All rights reserved.
//

#if __has_feature(modules)
	@import Foundation;
#else
	#import <Foundation/Foundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Error code specific to SAMKeychain that can be returned in NSError objects.
 For codes returned by the operating system, refer to SecBase.h for your
 platform.
 */
typedef NS_ENUM(OSStatus, SAMKeychainErrorCode) {
	/** Some of the arguments were invalid. */
	PN_SAMKeychainErrorBadArguments = -1001,
};

/** SAMKeychain error domain */
extern NSString *const QP_kSAMKeychainErrorDomain;

/** Account name. */
extern NSString *const QP_kSAMKeychainAccountKey;

/**
 Time the item was created.

 The value will be a string.
 */
extern NSString *const QP_kSAMKeychainCreatedAtKey;

/** Item class. */
extern NSString *const QP_kSAMKeychainClassKey;

/** Item description. */
extern NSString *const QP_kSAMKeychainDescriptionKey;

/** Item label. */
extern NSString *const QP_kSAMKeychainLabelKey;

/** Time the item was last modified.

 The value will be a string.
 */
extern NSString *const QP_kSAMKeychainLastModifiedKey;

/** Where the item was created. */
extern NSString *const QP_kSAMKeychainWhereKey;

/**
 Simple wrapper for accessing accounts, getting passwords, setting passwords, and deleting passwords using the system
 Keychain on Mac OS X and iOS.

 This was originally inspired by EMKeychain and SDKeychain (both of which are now gone). Thanks to the authors.
 SAMKeychain has since switched to a simpler implementation that was abstracted from [SSToolkit](http://sstoolk.it).
 */
@interface CN_SAMKeychain : NSObject

#pragma mark - Classic methods

/**
 Returns a string containing the password for a given account and service, or `nil` if the Keychain doesn't have a
 password for the given parameters.

 @param QP_serviceName The service for which to return the corresponding password.

 @param QP_account The account for which to return the corresponding password.

 @return Returns a string containing the password for a given account and service, or `nil` if the Keychain doesn't
 have a password for the given parameters.
 */
+ (nullable NSString *)MN_passwordForService:(NSString *)QP_serviceName MN_account:(NSString *)QP_account;
+ (nullable NSString *)MN_passwordForService:(NSString *)QP_serviceName MN_account:(NSString *)QP_account MN_error:(NSError **)QP_error __attribute__((swift_error(none)));

/**
 Returns a nsdata containing the password for a given account and service, or `nil` if the Keychain doesn't have a
 password for the given parameters.

 @param QP_serviceName The service for which to return the corresponding password.

 @param QP_account The account for which to return the corresponding password.

 @return Returns a nsdata containing the password for a given account and service, or `nil` if the Keychain doesn't
 have a password for the given parameters.
 */
+ (nullable NSData *)MN_passwordDataForService:(NSString *)QP_serviceName MN_account:(NSString *)QP_account;
+ (nullable NSData *)MN_passwordDataForService:(NSString *)QP_serviceName MN_account:(NSString *)QP_ccount MN_error:(NSError **)QP_error __attribute__((swift_error(none)));


/**
 Deletes a password from the Keychain.

 @param PN_serviceName The service for which to delete the corresponding password.

 @param PN_account The account for which to delete the corresponding password.

 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)MN_deletePasswordForService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account;
+ (BOOL)MN_deletePasswordForService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account MN_error:(NSError **)QP_error __attribute__((swift_error(none)));


/**
 Sets a password in the Keychain.

 @param PN_password The password to store in the Keychain.

 @param PN_serviceName The service for which to set the corresponding password.

 @param PN_account The account for which to set the corresponding password.

 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)setMN_Password:(NSString *)PN_password MN_forService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account;
+ (BOOL)setMN_Password:(NSString *)PN_password MN_forService:(NSString *)serviceName MN_account:(NSString *)PN_account error:(NSError **)PN_error __attribute__((swift_error(none)));

/**
 Sets a password in the Keychain.

 @param PN_password The password to store in the Keychain.

 @param PN_serviceName The service for which to set the corresponding password.

 @param PN_account The account for which to set the corresponding password.

 @return Returns `YES` on success, or `NO` on failure.
 */
+ (BOOL)setMN_PasswordData:(NSData *)PN_password MN_forService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account;
+ (BOOL)setMN_PasswordData:(NSData *)PN_password MN_forService:(NSString *)PN_serviceName MN_account:(NSString *)PN_account MN_error:(NSError **)PN_error __attribute__((swift_error(none)));

/**
 Returns an array containing the Keychain's accounts, or `nil` if the Keychain has no accounts.

 See the `NSString` constants declared in SAMKeychain.h for a list of keys that can be used when accessing the
 dictionaries returned by this method.

 @return An array of dictionaries containing the Keychain's accounts, or `nil` if the Keychain doesn't have any
 accounts. The order of the objects in the array isn't defined.
 */
+ (nullable NSArray<NSDictionary<NSString *, id> *> *)MN_allAccounts;
+ (nullable NSArray<NSDictionary<NSString *, id> *> *)MN_allAccounts:(NSError *__autoreleasing *)MN_error __attribute__((swift_error(none)));


/**
 Returns an array containing the Keychain's accounts for a given service, or `nil` if the Keychain doesn't have any
 accounts for the given service.

 See the `NSString` constants declared in SAMKeychain.h for a list of keys that can be used when accessing the
 dictionaries returned by this method.

 @param PN_serviceName The service for which to return the corresponding accounts.

 @return An array of dictionaries containing the Keychain's accounts for a given `serviceName`, or `nil` if the Keychain
 doesn't have any accounts for the given `serviceName`. The order of the objects in the array isn't defined.
 */
+ (nullable NSArray<NSDictionary<NSString *, id> *> *)MN_accountsForService:(nullable NSString *)PN_serviceName;
+ (nullable NSArray<NSDictionary<NSString *, id> *> *)MN_accountsForService:(nullable NSString *)QP_sserviceName MN_error:(NSError *__autoreleasing *)QP_serror __attribute__((swift_error(none)));


#pragma mark - Configuration

#if __IPHONE_4_0 && TARGET_OS_IPHONE
/**
 Returns the accessibility type for all future passwords saved to the Keychain.

 @return Returns the accessibility type.

 The return value will be `NULL` or one of the "Keychain Item Accessibility
 Constants" used for determining when a keychain item should be readable.

 @see setAccessibilityType
 */
+ (CFTypeRef)MN_accessibilityType;

/**
 Sets the accessibility type for all future passwords saved to the Keychain.

 @param PN_accessibilityType One of the "Keychain Item Accessibility Constants"
 used for determining when a keychain item should be readable.

 If the value is `NULL` (the default), the Keychain default will be used which
 is highly insecure. You really should use at least `kSecAttrAccessibleAfterFirstUnlock`
 for background applications or `kSecAttrAccessibleWhenUnlocked` for all
 other applications.

 @see accessibilityType
 */
+ (void)MN_setAccessibilityType:(CFTypeRef)PN_accessibilityType;
#endif

@end

NS_ASSUME_NONNULL_END

#import "CN_SAMKeychainQuery.h"
