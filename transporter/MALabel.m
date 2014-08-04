//
//  LabelView.m
//  transporter
//
//  Created by Austin Younts on 7/28/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MALabel.h"

@implementation MALabel

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (!self) return nil;
    
    [self setBezeled:NO];
    [self setDrawsBackground:NO];
    [self setEditable:NO];
    [self setSelectable:NO];
    
    return self;
}

@end
