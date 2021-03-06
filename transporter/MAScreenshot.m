//
//  Screenshot.m
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAScreenshot.h"
#import "NSData+md5.h"

NSString * const displayTargetiPhone4 = @"iOS-3.5-in";
NSString * const displayTargetiPhone5 = @"iOS-4-in";
NSString * const displayTargetiPad = @"iOS-iPad";

@implementation MAScreenshot

- (id)initWithImageFile:(NSURL *)fileURL
{
    self = [super init];
    
    if (self) {
        [self setFileName:[fileURL lastPathComponent]];
        [self setSize:@([[[NSFileManager defaultManager] attributesOfItemAtPath:[fileURL path] error:nil] fileSize])];
        
        NSData *imageData = [NSData dataWithContentsOfFile:[fileURL path]];
        [self setChecksum:[imageData md5]];
        
        NSImage *imageForSize = [[NSImage alloc] initWithData:imageData];
        [self setDisplayTarget:[self displayTargetForSize:imageForSize.size]];
        
        [self setFileURL:fileURL];
        
        imageData = nil;
        imageForSize = nil;
    }
    
    return self;
}

+ (instancetype)screenshotFromImageFile:(NSURL *)fileURL
{
    return [[[self class] alloc] initWithImageFile:fileURL];
}

- (NSString *)displayTargetForSize:(CGSize)size
{
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if ((width == 640.0 && (height == 920.0 || height == 960.0)) || (width == 960.0 && (height == 600.0 || height == 640.0))) {
        return displayTargetiPhone4;
    }
    else if ((width == 640.0 && (height == 1096.0 || height == 1136.0)) || (width == 1136.0 && (height == 600.0 || height == 640.0))) {
        return displayTargetiPhone5;
    }
    else if ((width == 1024.0 && (height == 748.0 || height == 768.0)) || (width == 2048.0 && (height == 1496.0 || height == 1536.0)) || (width == 768.0 && (height == 1004.0 || height == 1024.0)) || (width == 1536.0 && (height == 2008.0 || height == 2048.0))) {
        return displayTargetiPad;
    }
    else {
        return nil;
    }
}

- (NSXMLElement *)NSXMLElementRepresentation
{
    // If any information is missing about a screenshot, return nil instead of an invalid screenshot
    if (!self.displayTarget || !self.position || !self.fileName || !self.size || !self.checksum) {
        return nil;
    }
    
    NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"software_screenshot"];
    [root addAttribute:[NSXMLNode attributeWithName:@"display_target" stringValue:self.displayTarget]];
    [root addAttribute:[NSXMLNode attributeWithName:@"position" stringValue:[NSString stringWithFormat:@"%lu", (unsigned long)self.position]]];
    
    NSXMLElement *fileName = [[NSXMLElement alloc] initWithName:@"file_name" stringValue:self.fileName];
    [root addChild:fileName];
    
    NSXMLElement *size = [[NSXMLElement alloc] initWithName:@"size" stringValue:[NSString stringWithFormat:@"%d", [self.size intValue]]];
    [root addChild:size];
    
    NSXMLElement *checksum = [[NSXMLElement alloc] initWithName:@"checksum" stringValue:self.checksum];
    [checksum addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:@"md5"]];
    [root addChild:checksum];
    
    return root;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<MAScreenshot: %@, %@, position: %lu", self.fileName, self.displayTarget, (unsigned long)self.position];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setDisplayTarget:[aDecoder decodeObjectForKey:@"displayTarget"]];
        [self setPosition:[aDecoder decodeIntegerForKey:@"position"]];
        [self setSize:[aDecoder decodeObjectForKey:@"size"]];
        [self setFileName:[aDecoder decodeObjectForKey:@"fileName"]];
        [self setChecksum:[aDecoder decodeObjectForKey:@"checksum"]];
        [self setFileURL:[aDecoder decodeObjectForKey:@"fileURL"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.displayTarget forKey:@"displayTarget"];
    [aCoder encodeInteger:self.position forKey:@"position"];
    [aCoder encodeObject:self.size forKey:@"size"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.checksum forKey:@"checksum"];
    [aCoder encodeObject:self.fileURL forKey:@"fileURL"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAScreenshot *copy = [[MAScreenshot alloc] init];
    
    [copy setDisplayTarget:self.displayTarget.copy];
    [copy setPosition:self.position];
    [copy setSize:self.size.copy];
    [copy setFileName:self.fileName.copy];
    [copy setChecksum:self.checksum.copy];
    [copy setFileURL:self.fileURL.copy];
    
    return copy;
}

@end
