//
//  MATransporter.h
//  transporter
//
//  Created by Marcus Smith on 8/5/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAiTunesConnectAccount.h"
#import "NSError+MATransporterErrors.h"

typedef void(^MATransporterCompletion)(BOOL success, NSDictionary *info, NSError *error);

extern NSString * const MATransporterNotificationTransporterConnected;
extern NSString * const MATransporterNotificationTransporterDisconnected;

@interface MATransporter : NSObject

@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, readwrite) BOOL sendsConnectionNotifications;

+ (instancetype)sharedTransporter;

+ (BOOL)transporterInstalled;

- (void)updateIsConnected;

- (void)retrieveMetadataForAccount:(MAiTunesConnectAccount *)account appleID:(NSString *)appleID toDirectory:(NSString *)directoryPath completion:(MATransporterCompletion)completion;
- (void)retrieveMetadataForAccount:(MAiTunesConnectAccount *)account SKU:(NSString *)sku toDirectory:(NSString *)directoryPath completion:(MATransporterCompletion)completion;
- (void)verifyPackage:(NSString *)packagePath forAccount:(MAiTunesConnectAccount *)account completion:(MATransporterCompletion)completion;
- (void)uploadPackage:(NSString *)packagePath forAccount:(MAiTunesConnectAccount *)account completion:(MATransporterCompletion)completion;

@end
