//
//  MATransporter.h
//  transporter
//
//  Created by Marcus Smith on 8/5/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAiTunesConnectAccount.h"

@interface MATransporter : NSObject

@property (nonatomic, strong) MAiTunesConnectAccount *account;

- (id)initWithAccount:(MAiTunesConnectAccount *)account;
+ (instancetype)transporterWithAccount:(MAiTunesConnectAccount *)account;

+ (BOOL)transporterInstalled;

@end
