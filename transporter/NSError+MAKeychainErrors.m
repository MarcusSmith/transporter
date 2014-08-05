//
//  NSError+MAKeychainErrors.m
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "NSError+MAKeychainErrors.h"

NSString * const MAKeychainErrorDomain = @"keychain.ErrorDomain";

@implementation NSError (MAKeychainErrors)

+ (NSError *)MAKeychainNilKeyError
{
    return [NSError errorWithDomain:MAKeychainErrorDomain
                               code:MAKeychainErrorCodeNilKey
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MAKeychainNilKeyDescription", @"Attemped to store a keychain item with a nil key."),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)MAKeychainSecItemNotFoundError
{
    return [NSError errorWithDomain:MAKeychainErrorDomain
                               code:MAKeychainErrorCodeSecItemNotFound
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MAKeychainSecItemNotFoundDescription", @"Keychain item not found."),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

@end
