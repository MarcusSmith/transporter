//
//  MAWebScraper.h
//  transporter
//
//  Created by Marcus Smith on 8/11/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAiTunesConnectAccount.h"

@interface MAWebScraper : NSObject

+ (NSArray *)appleIDsForAccount:(MAiTunesConnectAccount *)account;

@end
