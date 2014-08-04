//
//  iTunesConnectAccount.h
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iTunesConnectAccount : NSObject <NSCoding>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *providerName;
@property (nonatomic, strong) NSString *certificateName;

- (id)initWithUsername:(NSString *)username;
+ (instancetype)accountWithUsername:(NSString *)username;

- (NSString *)password;
- (void)setPassword:(NSString *)password;

@end
