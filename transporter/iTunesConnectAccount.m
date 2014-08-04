//
//  iTunesConnectAccount.m
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "iTunesConnectAccount.h"
#import "Keychain.h"

@implementation iTunesConnectAccount

- (id)initWithUsername:(NSString *)username
{
    self = [super init];
    
    if (self) {
        [self setUsername:username];
    }
    
    return self;
}

+ (instancetype)accountWithUsername:(NSString *)username
{
    return [[[self class] alloc] initWithUsername:username];
}

- (NSString *)password
{
    NSError *error;
    NSString *password = [Keychain objectForKey:self.username error:&error];
    
    //TODO: Error handling!
    return password;
}

- (void)setPassword:(NSString *)password
{
    NSError *error;
    [Keychain setObject:password forKey:self.username error:&error];
    
    //TODO: Error handling!!
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setUsername:[aDecoder decodeObjectForKey:@"username"]];
        [self setProviderName:[aDecoder decodeObjectForKey:@"providerName"]];
        [self setCertificateName:[aDecoder decodeObjectForKey:@"certificateName"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.providerName forKey:@"providerName"];
    [aCoder encodeObject:self.certificateName forKey:@"certificateName"];
}



@end
