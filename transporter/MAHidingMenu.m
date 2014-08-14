//
//  MAHidingMenu.m
//  transporter
//
//  Created by Marcus Smith on 8/13/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAHidingMenu.h"

@implementation MAHidingMenu

- (void)setEnabled:(BOOL)flag
{
    // If the menu is disabled, hide it.  Otherwise show it.
    [super setHidden:!flag];
    [super setEnabled:flag];
}

@end
