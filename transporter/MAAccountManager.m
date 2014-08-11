//
//  MAAccountManager.m
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAAccountManager.h"

@implementation MAAccountManager

static NSMutableArray *_itunesConnectAccounts;
static NSString *iTunesConnectKey = @"iTunesConnectAccounts";

+ (NSMutableArray *)iTunesConnectAccounts
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:iTunesConnectKey];
        NSArray *accounts = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (!accounts) {
            _itunesConnectAccounts = [NSMutableArray array];
        }
        else {
            _itunesConnectAccounts = accounts.mutableCopy;
        }
        
    });
    
    return _itunesConnectAccounts;
}

+ (BOOL)saveAccounts
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_itunesConnectAccounts.copy];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:iTunesConnectKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSSet *)allUsernames
{
    NSArray *accounts = [self iTunesConnectAccounts];
    NSMutableArray *usernames = [NSMutableArray array];
    
    [accounts enumerateObjectsUsingBlock:^(MAiTunesConnectAccount *account, NSUInteger idx, BOOL *stop) {
        [usernames addObject:account.username];
    }];
    
    return usernames.copy;
}

+ (NSSet *)allProviderNames
{
    NSArray *accounts = [self iTunesConnectAccounts];
    NSMutableArray *providers = [NSMutableArray array];
    
    [accounts enumerateObjectsUsingBlock:^(MAiTunesConnectAccount *account, NSUInteger idx, BOOL *stop) {
        [providers addObject:account.providerName];
    }];
    
    return providers.copy;
}


+ (MAiTunesConnectAccount *)accountWithUsername:(NSString *)username
{
    NSArray *accounts = [self iTunesConnectAccounts];
    __block MAiTunesConnectAccount *foundAccount = nil;
    
    [accounts enumerateObjectsUsingBlock:^(MAiTunesConnectAccount *account, NSUInteger idx, BOOL *stop) {
        if ([account.username isEqualToString:username]) {
            foundAccount = account;
            *stop = YES;
        }
    }];
    
    return foundAccount;
}

+ (MAiTunesConnectAccount *)accountWithProviderName:(NSString *)provider
{
    NSArray *accounts = [self iTunesConnectAccounts];
    __block MAiTunesConnectAccount *foundAccount = nil;
    
    [accounts enumerateObjectsUsingBlock:^(MAiTunesConnectAccount *account, NSUInteger idx, BOOL *stop) {
        if ([account.providerName isEqualToString:provider]) {
            foundAccount = account;
            *stop = YES;
        }
    }];
    
    return foundAccount;
}

+ (BOOL)addAccount:(MAiTunesConnectAccount *)account
{
    if (!account) {
        return NO;
    }
    
    // If this account already exists, remove the previous one
    [self removeAccountWithUsername:account.username];
    
    [[self iTunesConnectAccounts] addObject:account];
    
    return [self saveAccounts];
}

+ (BOOL)removeAccountWithUsername:(NSString *)username
{
    if (!username) {
        return NO;
    }

    MAiTunesConnectAccount *matchingAccount = [self accountWithUsername:username];
    
    if (!matchingAccount) {
        return NO;
    }
    
    [[self iTunesConnectAccounts] removeObject:matchingAccount];
    
    BOOL keychainSuccess = [matchingAccount removePasswordWithError:nil];
    
    BOOL userDefaultsSuccess = [self saveAccounts];
    
    return keychainSuccess && userDefaultsSuccess;
}

+ (BOOL)removeAccountWithProviderName:(NSString *)provider
{
    if (!provider) {
        return NO;
    }
    
    MAiTunesConnectAccount *matchingAccount = [self accountWithProviderName:provider];
    
    if (!matchingAccount) {
        return NO;
    }
    
    [[self iTunesConnectAccounts] removeObject:matchingAccount];
    
    return [self saveAccounts];
}

+ (BOOL)removeAllAccounts
{
    NSSet *accounts = [self iTunesConnectAccounts].copy;
    
    [accounts enumerateObjectsUsingBlock:^(MAiTunesConnectAccount *account, BOOL *stop) {
        [account removePasswordWithError:nil];
    }];
    
    _itunesConnectAccounts = [NSMutableArray array];
    
    return [self saveAccounts];
}



@end
