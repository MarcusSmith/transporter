//
//  MAiTunesConnectAccount.m
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAiTunesConnectAccount.h"
#import "MAKeychain.h"

@implementation MAiTunesConnectAccount

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
    NSString *password = [MAKeychain passwordForUser:self.username error:&error];
    
    //TODO: Error handling!?
    return password;
}

- (BOOL)setPassword:(NSString *)password error:(NSError *__autoreleasing *)error
{
    return [MAKeychain storePassword:password forUser:self.username error:error];
}

- (BOOL)removePasswordWithError:(NSError *__autoreleasing *)error
{
    return [MAKeychain clearPasswordForUser:self.username error:error];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"u:%@,p:%@,c:%@,m:%@",self.username, self.providerName, self.certificateName, [super description]];
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setUsername:[aDecoder decodeObjectForKey:@"username"]];
        [self setProviderName:[aDecoder decodeObjectForKey:@"providerName"]];
        [self setCertificateName:[aDecoder decodeObjectForKey:@"certificateName"]];
        [self setAppleIDList:[aDecoder decodeObjectForKey:@"AppleIDList"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.providerName forKey:@"providerName"];
    [aCoder encodeObject:self.certificateName forKey:@"certificateName"];
    [aCoder encodeObject:self.AppleIDList forKey:@"AppleIDList"];
}

@end
