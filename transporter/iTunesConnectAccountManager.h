//
//  iTunesConnectAccountManager.h
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iTunesConnectAccount.h"

@interface iTunesConnectAccountManager : NSObject

+ (NSSet *)iTunesConnectAccounts;
+ (NSSet *)allUsernames;
+ (NSSet *)allProviderNames;

+ (iTunesConnectAccount *)accountWithUsername:(NSString *)username;
+ (iTunesConnectAccount *)accountWithProviderName:(NSString *)provider;

+ (BOOL)addAccount:(iTunesConnectAccount *)account;

+ (BOOL)removeAccountWithUsername:(NSString *)username;
+ (BOOL)removeAccountWithProviderName:(NSString *)provider;
+ (BOOL)removeAllAccounts;

@end
