//
//  iTunesConnectAccountManager.m
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "iTunesConnectAccountManager.h"

@implementation iTunesConnectAccountManager

+ (NSSet *)iTunesConnectAccounts
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesConnectAccounts"];
    NSSet *accounts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (!accounts) {
        return [NSSet set];
    }
    
    return accounts;
}

+ (NSSet *)allUsernames
{
    NSSet *accounts = [self iTunesConnectAccounts];
    NSMutableSet *usernames = [NSMutableSet set];
    
    [accounts enumerateObjectsUsingBlock:^(iTunesConnectAccount *account, BOOL *stop) {
        [usernames addObject:account.username];
    }];
    
    return usernames.copy;
}

+ (NSSet *)allProviderNames
{
    NSSet *accounts = [self iTunesConnectAccounts];
    NSMutableSet *providers = [NSMutableSet set];
    
    [accounts enumerateObjectsUsingBlock:^(iTunesConnectAccount *account, BOOL *stop) {
        [providers addObject:account.providerName];
    }];
    
    return providers.copy;
}


+ (iTunesConnectAccount *)accountWithUsername:(NSString *)username
{
    NSSet *accounts = [self iTunesConnectAccounts];
    __block iTunesConnectAccount *foundAccount = nil;
    
    [accounts enumerateObjectsUsingBlock:^(iTunesConnectAccount *account, BOOL *stop) {
        if ([account.username isEqualToString:username]) {
            foundAccount = account.copy;
            *stop = YES;
        }
    }];
    
    return foundAccount;
}

+ (iTunesConnectAccount *)accountWithProviderName:(NSString *)provider
{
    NSSet *accounts = [self iTunesConnectAccounts];
    __block iTunesConnectAccount *foundAccount = nil;
    
    [accounts enumerateObjectsUsingBlock:^(iTunesConnectAccount *account, BOOL *stop) {
        if ([account.providerName isEqualToString:provider]) {
            foundAccount = account.copy;
            *stop = YES;
        }
    }];
    
    return foundAccount;
}

+ (BOOL)addAccount:(iTunesConnectAccount *)account
{
    NSMutableSet *mutableAccounts = [self iTunesConnectAccounts].mutableCopy;
    
    if (!account) {
        return NO;
    }
    
    [mutableAccounts addObject:account];
    return [self setAccounts:mutableAccounts.copy];
}

+ (BOOL)removeAccountWithUsername:(NSString *)username
{
    NSMutableSet *mutableAccounts = [self iTunesConnectAccounts].mutableCopy;
    
    if (!username) {
        return NO;
    }
    
    iTunesConnectAccount *matchingAccount = [self accountWithUsername:username];
    
    if (!matchingAccount) {
        return NO;
    }
    
    [mutableAccounts removeObject:matchingAccount];
    
    
    return [self setAccounts:mutableAccounts.copy];
}

+ (BOOL)removeAccountWithProviderName:(NSString *)provider
{
    NSMutableSet *mutableAccounts = [self iTunesConnectAccounts].mutableCopy;
    
    if (!provider) {
        return NO;
    }
    
    iTunesConnectAccount *matchingAccount = [self accountWithProviderName:provider];
    
    if (!matchingAccount) {
        return NO;
    }
    
    [mutableAccounts removeObject:matchingAccount];
    
    
    return [self setAccounts:mutableAccounts.copy];
}

+ (BOOL)removeAllAccounts
{
    NSSet *emptySet = [NSSet set];
    
    return [self setAccounts:emptySet];
}

+ (BOOL)setAccounts:(NSSet *)accounts
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accounts];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"iTunesConnectAccounts"];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
