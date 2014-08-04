//
//  Keychain.m
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "Keychain.h"

NSString * const kServiceName = @"transporter";

@implementation Keychain

# pragma mark - storage
+ (BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key error:(NSError *__autoreleasing *)error
{
    //Make sure the key is not nil
    if (!key) {
        if (error) {
            *error = [NSError KeychainNilKeyError];
        }
        
        return NO;
    }
    // Set up search dictionary and token data
    NSMutableDictionary *dictionary = [self searchDirectoryForKey:key];
    NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:object];
    [dictionary setObject:objectData forKey:(__bridge id)kSecValueData];
//    [dictionary setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    // Add.
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
	
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
    [updateDictionary setObject:objectData forKey:(__bridge id)kSecValueData];
//    [updateDictionary setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
	
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
            *error = [NSError KeychainNilKeyError];
        }
        
        return nil;
    }
    
    // Create Search Dictionary, with return type set to CFData/NSData and limiting search results to one
    NSMutableDictionary *searchDictionary = [self searchDirectoryForKey:key];
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
    // Search.
    CFTypeRef foundDict = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &foundDict);
    
    id retrievedObject = nil;
    
    if (status == noErr) {
        NSData *objectData = (__bridge_transfer NSData *)foundDict;
        retrievedObject = [NSKeyedUnarchiver unarchiveObjectWithData:objectData];
    } else if (error) {
        if (status == errSecItemNotFound) {
            *error = [NSError KeychainSecItemNotFoundError];
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
            *error = [NSError KeychainNilKeyError];
        }
        
        return NO;
    }
    
    NSMutableDictionary *searchDictionary = [self searchDirectoryForKey:key];
    
    return [self clearObjectsWithSearchDictionary:searchDictionary error:error];
}


+ (BOOL)clearKeychainWithError:(NSError *__autoreleasing *)error
{
    // Search for all Generic passwords in app's keychain (all tokens are stored as generic passwords)
    NSDictionary *searchDictionary = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword};
    
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
            *error = [NSError KeychainSecItemNotFoundError];
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
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    // Uniquely identify this keychain accessor.
    [searchDictionary setObject:kServiceName forKey:(__bridge id)kSecAttrService];
	
    // Uniquely identify the account who will be accessing the keychain.
    NSData *encodedIdentifier = [key dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
	
    return searchDictionary;
}

@end
