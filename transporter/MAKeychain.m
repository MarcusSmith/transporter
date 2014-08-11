//
//  Keychain.m
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAKeychain.h"
#import <Security/Security.h>

NSString * const kServiceName = @"com.MAtransporter";

@implementation MAKeychain

//iOS
# pragma mark - storage
+ (BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    //Make sure the key is not nil
    if (!key) {
        if (error) {
            *error = [NSError MAKeychainNilKeyError];
        }
        
        return NO;
    }
    NSLog(@"Setting up dictionary to store object: %@ for key: %@", object, key);
    // Set up search dictionary and token data
    NSMutableDictionary *dictionary = [self searchDirectoryForKey:key];
    NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
    [dictionary setObject:objectData forKey:(id)kSecValueData];
    
    // Add.
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    NSLog(@"%@", [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
	
    // If the addition was successful, return. Otherwise, attempt to update existing key or quit (return NO).
    if (status == errSecSuccess) {
        return YES;
    } else if (status == errSecDuplicateItem){
        return [self updateObject:object forKey:key error:error];
    } else {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        return NO;
    }
}

+ (BOOL)updateObject:(id<NSCoding>)object forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    // Set up search and update dictionaries and token data
    NSMutableDictionary *searchDictionary = [self searchDirectoryForKey:key];
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
    [updateDictionary setObject:objectData forKey:(id)kSecValueData];
	
    // Update.
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary,
                                    (__bridge CFDictionaryRef)updateDictionary);
	
    if (status == errSecSuccess) {
        return YES;
    } else {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        return NO;
    }
}

#pragma mark - retrieval
+ (id)objectForKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    //Make sure the key is not nil
    if (!key) {
        if (error) {
            *error = [NSError MAKeychainNilKeyError];
        }
        
        return nil;
    }
    
    // Create Search Dictionary, with return type set to CFData/NSData and limiting search results to one
    NSMutableDictionary *searchDictionary = [self searchDirectoryForKey:key];
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
    // Search.
    CFTypeRef foundDict = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &foundDict);
    
    id retrievedObject = nil;
    
    if (status == noErr) {
        NSData *objectData = (__bridge_transfer NSData *)foundDict;
        retrievedObject = [NSKeyedUnarchiver unarchiveObjectWithData:objectData];
    } else if (error) {
        if (status == errSecItemNotFound) {
            *error = [NSError MAKeychainSecItemNotFoundError];
        }
        else {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
    }
    
    return retrievedObject;
}

#pragma mark - clearance
+ (BOOL)clearObjectForKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    //Make sure the key is not nil
    if (!key) {
        if (error) {
            *error = [NSError MAKeychainNilKeyError];
        }
        
        return NO;
    }
    
    NSMutableDictionary *searchDictionary = [self searchDirectoryForKey:key];
    
    return [self clearObjectsWithSearchDictionary:searchDictionary error:error];
}


+ (BOOL)clearKeychainWithError:(NSError *__autoreleasing *)error
{
    // Search for all Generic passwords in app's keychain (all tokens are stored as generic passwords)
    NSDictionary *searchDictionary = @{(id)kSecClass:(id)kSecClassGenericPassword};
    
    return [self clearObjectsWithSearchDictionary:searchDictionary error:error];
}


+ (BOOL)clearObjectsWithSearchDictionary:(NSDictionary *)searchDictionary error:(NSError *__autoreleasing *)error
{
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
    
    // If no errors, return YES
    if (status == noErr) {
        return YES;
    }
    
    // If an error pointer was passed in, assign an error to it with the OSStatus code
    // If the error was because there was nothing to delete, still return YES as this is still successful, otherwise return NO
    if (status == errSecItemNotFound) {
        if (error) {
            *error = [NSError MAKeychainSecItemNotFoundError];
        }
        
        return YES;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        return NO;
    }
}

#pragma mark - Convenience Methods

+ (NSMutableDictionary *)searchDirectoryForKey:(NSString *)key {

    // Setup dictionary to access keychain.
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    // Specify we are using a password (rather than a certificate, internet password, etc).
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
//    NSString *uniqueID = [NSString stringWithFormat:@"%@:%@", kServiceName, key];
    
    // Uniquely identify the account who will be accessing the keychain.
    NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    // Uniquely identify this keychain accessor.
    [searchDictionary setObject:kServiceName forKey:(id)kSecAttrService];
	
    return searchDictionary;
}


// OS X
#pragma mark - storage

+ (BOOL)storePassword:(NSString *)password forUser:(NSString *)user error:(NSError *__autoreleasing *)error
{
    //Make sure the key is not nil
    if (!password || !user) {
        if (error) {
            *error = [NSError MAKeychainNilKeyError];
        }
        
        return NO;
    }
    
    const char *passwordChar = [password UTF8String];
    UInt32 passwordLength = (UInt32)strlen(passwordChar);
    
    const char *userChar = [user UTF8String];
    UInt32 userLength = (UInt32)strlen(userChar);
    
    OSStatus status = SecKeychainAddGenericPassword(NULL, 13, "MATransporter", userLength, userChar, passwordLength, passwordChar, NULL);
    
//    NSLog(@"Store Status: %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    
    if (status == errSecSuccess) {
        return YES;
    }
    else if (status == errSecDuplicateItem){
        return [self updatePassword:password forUser:user error:error];
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        return NO;
    }
}

+ (BOOL)updatePassword:(NSString *)password forUser:(NSString *)user error:(NSError *__autoreleasing *)error
{
    SecKeychainItemRef itemRef = [self itemRefForUser:user error:error];
    
    const char *passwordChar = [password UTF8String];
    UInt32 passwordLength = (UInt32)strlen(passwordChar);
    
    OSStatus status = SecKeychainItemModifyAttributesAndData (itemRef, NULL, passwordLength, passwordChar);
    
    CFRelease(itemRef);
    
//    NSLog(@"Update Status: %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    
    if (status == errSecSuccess) {
        return YES;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        return NO;
    }
}

#pragma mark - retrieval

+ (NSString *)passwordForUser:(NSString *)user error:(NSError *__autoreleasing *)error
{
    if (!user) {
        if (error) {
            *error = [NSError MAKeychainNilKeyError];
        }
        
        return nil;
    }
    
    const char *userChar = [user UTF8String];
    UInt32 userLength = (UInt32)strlen(userChar);
    
    //Data to be filled in by keychain
    void *passwordData = NULL;
    UInt32 passwordLength = 0;
    
    OSStatus status = SecKeychainFindGenericPassword(NULL, 13, "MATransporter", userLength, userChar, &passwordLength, &passwordData, NULL);
    
//    NSLog(@"Retrieval Status: %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    
    NSString *passwordString = [[NSString alloc] initWithBytes:passwordData length:passwordLength encoding:NSStringEncodingConversionAllowLossy];
    
    SecKeychainItemFreeContent(NULL, passwordData);
    
    return passwordString;
}

+ (SecKeychainItemRef)itemRefForUser:(NSString *)user error:(NSError *__autoreleasing *)error
{
    const char *userChar = [user UTF8String];
    UInt32 userLength = (UInt32)strlen(userChar);
    
    SecKeychainItemRef itemRef;
    
    OSStatus status = SecKeychainFindGenericPassword(NULL, 13, "MATransporter", userLength, userChar, NULL, NULL, &itemRef);
    
//    NSLog(@"item ref status: %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
    
    if (status != errSecSuccess) {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        return NULL;
    }
    
    return itemRef;
}

#pragma mark - clearance

+ (BOOL)clearPasswordForUser:(NSString *)user error:(NSError *__autoreleasing *)error
{
    if (!user) {
        if (error) {
            *error = [NSError MAKeychainNilKeyError];
        }
        
        return NO;
    }
    
    SecKeychainItemRef itemRef = [self itemRefForUser:user error:nil];
    
    if (itemRef == NULL) {
        if (error) {
            *error = [NSError MAKeychainSecItemNotFoundError];
        }
        
        return NO;
    }
    
    OSStatus status = SecKeychainItemDelete(itemRef);
    
    CFRelease(itemRef);
    
    if (status == errSecSuccess) {
        return YES;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        return NO;
    }
}

@end
