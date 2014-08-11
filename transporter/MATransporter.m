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

+ (BOOL)transporterInstalled
{
    return (iTMSTransporterPath() != nil);
}

+ (void)launchTransporterWithArguments:(NSArray *)arguments info:(NSDictionary *)info completion:(MATransporterCompletion)completion
{
    __block NSDictionary *blockSafeInfo = info;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^(void) {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:iTMSTransporterPath()];
        [task setArguments:arguments];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        [task setStandardInput:[NSPipe pipe]];
        
        NSPipe *errorPipe = [NSPipe pipe];
        [task setStandardError:errorPipe];
        
        NSFileHandle *file;
        file = [pipe fileHandleForReading];
        
        NSFileHandle *errorFile;
        errorFile = [errorPipe fileHandleForReading];
        
        [task launch];
        
        NSData *data;
        data = [file readDataToEndOfFile];
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataString = [dataString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSData *errorData;
        errorData = [errorFile readDataToEndOfFile];
        NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
//        NSLog(@"Data:\n%@\nError:\n%@", dataString, errorString);
        BOOL success = [errorString hasSuffix:@"0"];
        
        // Clean up iTMSTransporter Std Err mess, and convert it into easy to understand NSErrors if possible.
        NSError *error;
        
        if (!success) {
            if ([errorString rangeOfString:@"Could not connect to Apple's web service" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                error = [NSError MATransporterConnectionError];
            }
            else if ([errorString rangeOfString:@"ERROR ITMS-4160" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                if ([errorString rangeOfString:@"No provider record found" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    error = [NSError MATransporterInvalidProviderError];
                }
                else {
                    error = [NSError MATransporterWrongProviderError];
                    
                    NSArray *lines = [errorString componentsSeparatedByString:@"\n"];
                    __block NSString *providerErrorText;
                    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
                        if ([line rangeOfString:@"ERROR ITMS-4160" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                            providerErrorText = line;
                            *stop = YES;
                        }
                    }];
                    
                    // Only add the provider info if it can be parsed out of the error text
                    if (providerErrorText) {
                        providerErrorText = [providerErrorText componentsSeparatedByString:@"\""][1];
                        NSArray *providers = [providerErrorText componentsSeparatedByString:@"'"];
                        if (providers.count > 3) {
                            NSString *metadataProvider = providers[1];
                            NSString *uploadProvider = providers[3];
                            NSMutableDictionary *mutableInfo = info.mutableCopy;
                            [mutableInfo addEntriesFromDictionary:@{@"metadataProvider": metadataProvider,
                                                                    @"uploadProvider": uploadProvider,
                                                                    }];
                            blockSafeInfo = mutableInfo.copy;
                        }
                    }
                }
            }
            else if ([errorString rangeOfString:@"will NOT be"].location != NSNotFound) {
                error = [NSError MATransporterInvalidPackageError];
            }
            else if ([errorString rangeOfString:@"No software found with vendor_id"].location != NSNotFound) {
                error = [NSError MATransporterInvalidVendorIDError];
            }
            // More else if error checks to go here later
            else {
                error = [NSError errorWithDomain:MATransporterErrorDomain code:0 userInfo:@{@"NSLocalizedDescription":errorString}];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, blockSafeInfo, error);
        });
    });
}

+ (void)retrieveMetadataForAccount:(MAiTunesConnectAccount *)account appleID:(NSString *)appleID toDirectory:(NSString *)directoryPath completion:(MATransporterCompletion)completion
{
    NSDictionary *info = @{@"account": account,
                           @"packagePath": [NSString stringWithFormat:@"%@/%@.itmsp", directoryPath, appleID],
                           };
    
    NSString *password = account.password;
    
    if (!password) {
        completion(NO, info, [NSError MATransporterMissingPasswordError]);
        return;
    }
    
    NSArray *taskArray = @[@"-m",@"lookupMetadata",@"-u",account.username,@"-p",password,@"-destination",directoryPath,@"-apple_id",appleID];
    
    [self launchTransporterWithArguments:taskArray info:info completion:completion];
}

+ (void)retrieveMetadataForAccount:(MAiTunesConnectAccount *)account SKU:(NSString *)sku toDirectory:(NSString *)directoryPath completion:(MATransporterCompletion)completion
{
    NSDictionary *info = @{@"account": account,
                           @"packagePath": [NSString stringWithFormat:@"%@/%@.itmsp", directoryPath, sku],
                           };
    
    NSString *password = account.password;
    
    if (!password) {
        completion(NO, info, [NSError MATransporterMissingPasswordError]);
        return;
    }
    
    NSArray *taskArray = @[@"-m",@"lookupMetadata",@"-u",account.username,@"-p",password,@"-destination",directoryPath,@"-vendor_id",sku];
    
    [self launchTransporterWithArguments:taskArray info:info completion:completion];
}

+ (void)verifyPackage:(NSString *)packagePath forAccount:(MAiTunesConnectAccount *)account completion:(MATransporterCompletion)completion
{
    NSDictionary *info = @{@"account": account,
                           @"packagePath": packagePath,
                           };
    
    NSString *password = account.password;
    
    if (!password) {
        completion(NO, info, [NSError MATransporterMissingPasswordError]);
        return;
    }
    
    NSArray *taskArray = @[@"-m",@"verify",@"-u",account.username,@"-p",password,@"-f",packagePath];

    [self launchTransporterWithArguments:taskArray info:info completion:completion];
}

+ (void)uploadPackage:(NSString *)packagePath forAccount:(MAiTunesConnectAccount *)account completion:(MATransporterCompletion)completion
{
    NSDictionary *info = @{@"account": account,
                           @"packagePath": packagePath,
                           };
    
    NSString *password = account.password;
    
    if (!password) {
        completion(NO, info,[NSError MATransporterMissingPasswordError]);
        return;
    }
    
    NSArray *taskArray = @[@"-m",@"upload",@"-u",account.username,@"-p",password,@"-f",packagePath];
    
    [self launchTransporterWithArguments:taskArray info:info completion:completion];
}

@end
