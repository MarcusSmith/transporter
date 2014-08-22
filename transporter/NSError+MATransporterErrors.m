//
//  NSError+MATransporterErrors.m
//  transporter
//
//  Created by Marcus Smith on 8/8/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "NSError+MATransporterErrors.h"

@implementation NSError (MATransporterErrors)

NSString * const MATransporterErrorDomain = @"MATransporter.ErrorDomain";

+ (NSError *)MATransporterTransporterNotInstalledError
{
    return [NSError errorWithDomain:MATransporterErrorDomain
                               code:MATransporterErrorCodeTransporterNotInstalled
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MATranspoterNotInstalledDescription", @"iTMSTransporter is not installed."),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)MATransporterMissingPasswordError
{
    return [NSError errorWithDomain:MATransporterErrorDomain
                               code:MATransporterErrorCodeMissingPassword
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MATransporterErrorCodeMissingPasswordDescription", @"Password not stored in keychain for this account"),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)MATransporterConnectionError
{
    return [NSError errorWithDomain:MATransporterErrorDomain
                               code:MATransporterErrorCodeCouldntConnect
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MATransporterErrorCodeCouldntConnectDescription", @"Could not connect to Apple's web service."),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)MATransporterWrongProviderError
{
    return [NSError errorWithDomain:MATransporterErrorDomain
                               code:MATransporterErrorCodeProvidersDontMatch
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MATransporterErrorCodeProvidersDontMatchDescription", @"Provider specified in metadata does not match the upload provider"),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)MATransporterInvalidProviderError
{
    return [NSError errorWithDomain:MATransporterErrorDomain
                               code:MATransporterErrorCodeInvalidProvider
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MATransporterErrorCodeInvalidProviderDescription", @"No provider record found"),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)MATransporterInvalidVendorIDError
{
    return [NSError errorWithDomain:MATransporterErrorDomain
                               code:MATransporterErrorCodeInvalidVendorID
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MATransporterErrorCodeInvalidVendorIDDescription", @"No software found with provided vendor ID"),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)MATransporterInvalidPackageError
{
    return [NSError errorWithDomain:MATransporterErrorDomain
                               code:MATransporterErrorCodeInvalidPackage
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MATransporterErrorCodeInvalidPackageDescription", @"Provided package is not a valid iTMS package"),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

+ (NSError *)MATransporterInvalidVersionError
{
    return [NSError errorWithDomain:MATransporterErrorDomain
                               code:MATransporterErrorCodeInvalidVersion
                           userInfo:@{
                                      NSLocalizedDescriptionKey: NSLocalizedString(@"MATransporterErrorCodeInvalidVersionDescription", @"Version is not valid for update or doesn't exist"),
                                      NSLocalizedRecoveryOptionsErrorKey: @[
                                              NSLocalizedString(@"Cancel", @"Cancel Button"),
                                              ]
                                      }];
}

@end
