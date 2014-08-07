//
//  MAKeychain.h
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+MAKeychainErrors.h"

@interface MAKeychain : NSObject

// iOS Keychain
+ (BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key error:(NSError **)error;

+ (id)objectForKey:(NSString *)key error:(NSError **)error;

+ (BOOL)clearObjectForKey:(NSString *)key error:(NSError **)error;
+ (BOOL)clearKeychainWithError:(NSError **)error;

// OS X Keychain
+ (BOOL)storePassword:(NSString *)password forUser:(NSString *)user error:(NSError **)error;
+ (NSString *)passwordForUser:(NSString *)user error:(NSError **)error;
+ (BOOL)clearPasswordForUser:(NSString *)user error:(NSError **)error;

@end
