//
//  NSError+KeychainErrors.h
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const KeychainErrorDomain;

typedef NS_ENUM(NSInteger, KeychainErrorCode) {
    KeychainErrorCodeUnknown = 0,
    KeychainErrorCodeNilKey,
    KeychainErrorCodeSecItemNotFound,
};

@interface NSError (KeychainErrors)

+ (NSError *)KeychainNilKeyError;
+ (NSError *)KeychainSecItemNotFoundError;

@end
