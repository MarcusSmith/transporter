//
//  NSError+KeychainErrors.m
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "NSError+KeychainErrors.h"

NSString * const KeychainErrorDomain = @"keychain.ErrorDomain";

@implementation NSError (KeychainErrors)

+ (NSError *)KeychainNilKeyError
{
    return [NSError errorWithDomain:KeychainErrorDomain
                               code:KeychainErrorCodeNilKey
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"KeychainNilKeyDescription", @"Attemped to store a keychain item with a nil key."),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)KeychainSecItemNotFoundError
{
    return [NSError errorWithDomain:KeychainErrorDomain
                               code:KeychainErrorCodeSecItemNotFound
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"KeychainSecItemNotFoundDescription", @"Keychain item not found."),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

@end
