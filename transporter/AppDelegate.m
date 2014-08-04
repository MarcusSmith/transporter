//
//  AppDelegate.m
//  transporter
//
//  Created by Marcus Smith on 7/11/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "AppDelegate.h"
#import <AppKit/AppKit.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSDocumentController *documentController;

@end

@implementation AppDelegate

@dynamic documentController;



-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [self documentController];
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    
}


#pragma mark - Accessors
- (NSDocumentController *)documentController
{
    return [NSDocumentController sharedDocumentController];
}


@end

