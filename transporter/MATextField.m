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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setStringValue:(NSString *)aString
{
    if (aString) {
        [super setStringValue:aString];
        
        [self invalidateIntrinsicContentSize];
        NSLog(@"%@: %@", NSStringFromSelector(_cmd), aString);
    }
}

- (NSSize)intrinsicContentSize
{
    if (self.attributedStringValue.length < 1) return CGSizeMake(0, 0);
    
    CGSize size = [self.stringValue sizeWithAttributes:[self.attributedStringValue attributesAtIndex:0 effectiveRange:nil]];
    
    size.height += 10.0;
    size.width += 12.0;
    
    NSLog(@"%@, %@", self, NSStringFromSize(size));
    
    return size;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@", [super description], NSStringFromRect(self.frame)];
}

@end
