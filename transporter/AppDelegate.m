//
//  AppDelegate.m
//  transporter
//
//  Created by Marcus Smith on 7/11/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "AppDelegate.h"
#import <AppKit/AppKit.h>
#import "MainViewController.h"

@interface AppDelegate ()
{
    NSWindow *mainWindow;
//    NSView *view;
    MainViewController *viewController;
}


@end

@implementation AppDelegate

-(id)init
{
    if(self = [super init]) {
        NSRect contentSize = NSMakeRect(500.0, 200.0, 1000.0, 1000.0);
        NSUInteger windowStyleMask = NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask;
        mainWindow = [[NSWindow alloc] initWithContentRect:contentSize styleMask:windowStyleMask backing:NSBackingStoreBuffered defer:YES];
        mainWindow.backgroundColor = [NSColor whiteColor];
        mainWindow.title = @"Transporter";
        viewController = [[MainViewController alloc] initWithSize:contentSize.size];
        
    }
    return self;
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [mainWindow setContentView:viewController.view];           // Hook the view up to the window
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [mainWindow makeKeyAndOrderFront:self];     // Show the window
    
}


@end
