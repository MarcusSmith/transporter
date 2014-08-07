//
//  MATransporter.m
//  transporter
//
//  Created by Marcus Smith on 8/5/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MATransporter.h"

@implementation MATransporter

static NSString *iTMSTransporterPath(void)
{
	static NSString * const MAApplicationLoaderName = @"Application Loader";
	
	NSString *applicationLoaderPath = [[NSWorkspace sharedWorkspace] fullPathForApplication:MAApplicationLoaderName];
	if (applicationLoaderPath == nil) {
		return nil;
	}
	
	return [applicationLoaderPath stringByAppendingPathComponent:@"Contents/MacOS/itms/bin/iTMSTransporter"];
}

- (id)initWithAccount:(MAiTunesConnectAccount *)account
{
    self = [super init];
    
    if (self) {
        [self setAccount:account];
    }
    
    return self;
}

+ (instancetype)transporterWithAccount:(MAiTunesConnectAccount *)account
{
    return [[[self class] alloc] initWithAccount:account];
}

+ (BOOL)transporterInstalled
{
    return (iTMSTransporterPath() != nil);
}

- (void)authenticateAndLaunchTransporterWithArguments:(NSArray *)arguments
{
    
}

- (void)launchTransporterWithArguments:(NSArray *)arguments
{
    
}

@end
