//
//  MATextField.m
//  transporter
//
//  Created by Austin Younts on 7/31/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MATextField.h"

@implementation MATextField

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        [self setBackgroundColor:[NSColor lightGrayColor]];
        [self setTextColor:[NSColor blackColor]];
        [self setBezeled:NO];
        
        [self setDrawsBackground:YES];
    }
    return self;
}

- (void)setStringValue:(NSString *)aString
{
    if (aString) {
        [super setStringValue:aString];
        
        [self invalidateIntrinsicContentSize];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@", [super description], NSStringFromRect(self.frame)];
}

@end
