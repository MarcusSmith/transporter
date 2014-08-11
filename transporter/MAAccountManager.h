//
//  MAAccountManager.h
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAiTunesConnectAccount.h"

@interface MAAccountManager : NSObject

+ (NSMutableArray *)iTunesConnectAccounts;
+ (NSArray *)allUsernames;
+ (NSArray *)allProviderNames;

+ (MAiTunesConnectAccount *)accountWithUsername:(NSString *)username;
+ (MAiTunesConnectAccount *)accountWithProviderName:(NSString *)provider;

+ (BOOL)addAccount:(MAiTunesConnectAccount *)account;
+ (BOOL)saveAccounts;

+ (BOOL)removeAccountWithUsername:(NSString *)username;
+ (BOOL)removeAccountWithProviderName:(NSString *)provider;
+ (BOOL)removeAllAccounts;

@end
