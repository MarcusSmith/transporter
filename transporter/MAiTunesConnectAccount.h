//
//  MAiTunesConnectAccount.h
//  transporter
//
//  Created by Marcus Smith on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAiTunesConnectAccount : NSObject <NSCoding>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *providerName;
@property (nonatomic, strong) NSString *certificateName;
@property (nonatomic, strong) NSArray *AppleIDList;

- (id)initWithUsername:(NSString *)username;
+ (instancetype)accountWithUsername:(NSString *)username;

- (NSString *)password;
- (BOOL)setPassword:(NSString *)password error:(NSError **)error;
- (BOOL)removePasswordWithError:(NSError **)error;

@end
