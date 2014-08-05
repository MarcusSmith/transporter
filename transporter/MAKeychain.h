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

+ (BOOL)setObject:(id<NSCoding>)object forKey:(NSString *)key error:(NSError **)error;

+ (id)objectForKey:(NSString *)key error:(NSError **)error;

+ (BOOL)clearObjectForKey:(NSString *)key error:(NSError **)error;
+ (BOOL)clearKeychainWithError:(NSError **)error;

@end
