//
//  main.m
//  transporter
//
//  Created by Marcus Smith on 7/11/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[])
{
    NSArray *tl;
    NSApplication * application = [NSApplication sharedApplication];
    [[NSBundle mainBundle] loadNibNamed:@"MainMenu" owner:application topLevelObjects:&tl];
    
    AppDelegate *applicationDelegate = [[AppDelegate alloc] init];     // Instantiate App  delegate
    [application setDelegate:applicationDelegate];                      // Assign delegate to the NSApplication
    [application run];                                                  // Call the Apps Run method
    
    return 0;       // App Never gets here.
}