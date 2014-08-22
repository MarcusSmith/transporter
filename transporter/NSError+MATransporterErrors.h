//
//  NSError+MATransporterErrors.h
//  transporter
//
//  Created by Marcus Smith on 8/8/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (MATransporterErrors)

extern NSString * const MATransporterErrorDomain;

typedef NS_ENUM(NSInteger, MATransporterErrorCode) {
    MATransporterErrorCodeUnknown = 0,
    MATransporterErrorCodeTransporterNotInstalled,
    MATransporterErrorCodeMissingPassword,
    MATransporterErrorCodeCouldntConnect,
    MATransporterErrorCodeInvalidProvider,
    MATransporterErrorCodeProvidersDontMatch,
    MATransporterErrorCodeInvalidVendorID,
    MATransporterErrorCodeInvalidPackage,
    MATransporterErrorCodeInvalidVersion,
};

+ (NSError *)MATransporterTransporterNotInstalledError;
+ (NSError *)MATransporterMissingPasswordError;
+ (NSError *)MATransporterConnectionError;
+ (NSError *)MATransporterInvalidProviderError;
+ (NSError *)MATransporterWrongProviderError;
+ (NSError *)MATransporterInvalidVendorIDError;
+ (NSError *)MATransporterInvalidPackageError;
+ (NSError *)MATransporterInvalidVersionError;

@end
