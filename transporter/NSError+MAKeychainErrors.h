//
//  NSError+MAKeychainErrors.h
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MAKeychainErrorDomain;

typedef NS_ENUM(NSInteger, MAKeychainErrorCode) {
    MAKeychainErrorCodeUnknown = 0,
    MAKeychainErrorCodeNilKey,
    MAKeychainErrorCodeSecItemNotFound,
};

@interface NSError (MAKeychainErrors)

+ (NSError *)MAKeychainNilKeyError;
+ (NSError *)MAKeychainSecItemNotFoundError;

@end
