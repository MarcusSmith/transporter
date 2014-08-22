//
//  Locale.m
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MALocale.h"

@implementation MALocale

- (void)addScreenshot:(MAScreenshot *)screenshot
{
    self.screenshots = [self.screenshots arrayByAddingObject:screenshot];
}

- (void)removeScreenshot:(MAScreenshot *)screenshot
{
    NSMutableArray *mutableScreenshots = self.screenshots.mutableCopy;
    
    [mutableScreenshots removeObject:screenshot];
    
    self.screenshots = mutableScreenshots.copy;
}

- (void)addKeyword:(NSString *)keyword
{
    self.keywords = [self.keywords arrayByAddingObject:keyword];
}

- (void)removeKeyword:(NSString *)keyword
{
    NSMutableArray *mutableKeywords = self.keywords.mutableCopy;
    
    [mutableKeywords removeObject:keyword];
    
    self.keywords = mutableKeywords.copy;
}

- (NSXMLElement *)NSXMLElementRepresentation
{
    // If a locale doesn't have a name it isn't valid, return nil
    if (!self.name) {
        return nil;
    }
    NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"locale"];
    [root addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:self.name]];
    
    if (self.title) {
        NSXMLElement *title = [[NSXMLElement alloc] initWithName:@"title" stringValue:self.title];
        [root addChild:title];
    }
    
    if (self.localDescription) {
        NSXMLElement *description = [[NSXMLElement alloc] initWithName:@"description" stringValue:self.localDescription];
        [root addChild:description];
    }
    
    if (self.keywords && self.keywords.count > 0) {
        NSXMLElement *keywords = [[NSXMLElement alloc] initWithName:@"keywords"];
        [self.keywords.copy enumerateObjectsUsingBlock:^(NSString *keywordString, NSUInteger idx, BOOL *stop) {
            if (keywordString) {
                NSXMLElement *keyword = [[NSXMLElement alloc] initWithName:@"keyword" stringValue:keywordString];
                [keywords addChild:keyword];
            }
        }];
        [root addChild:keywords];
    }
    
    if (self.whatsNew) {
        NSXMLElement *whatsNew = [[NSXMLElement alloc] initWithName:@"version_whats_new" stringValue:self.whatsNew];
        [root addChild:whatsNew];
    }
    
    if (self.softwareURL) {
        NSXMLElement *softwareURL = [[NSXMLElement alloc] initWithName:@"software_url" stringValue:self.softwareURL];
        [root addChild:softwareURL];
    }
    
    if (self.privacyURL) {
        NSXMLElement *privacyURL = [[NSXMLElement alloc] initWithName:@"privacy_url" stringValue:self.privacyURL];
        [root addChild:privacyURL];
    }
    
    if (self.supportURL) {
        NSXMLElement *supportURL = [[NSXMLElement alloc] initWithName:@"support_url" stringValue:self.supportURL];
        [root addChild:supportURL];
    }
    
    if (self.screenshots && self.screenshots.count > 0) {
        NSXMLElement *screenshots = [[NSXMLElement alloc] initWithName:@"software_screenshots"];
        [self.screenshots.copy enumerateObjectsUsingBlock:^(MAScreenshot *screenshot, NSUInteger idx, BOOL *stop) {
            NSXMLElement *element = [screenshot NSXMLElementRepresentation];
            if (element) {
                [screenshots addChild:element];
            }
        }];
        [root addChild:screenshots];
    }
    
    return root;
}

#pragma mark - ordered screenshots

- (NSArray *)orderedArrayOfScreenshotsForTarget:(NSString *)displayTarget
{
    NSMutableArray *screenshotsForTarget = [NSMutableArray array];
    
    [self.screenshots enumerateObjectsUsingBlock:^(MAScreenshot *screenshot, NSUInteger idx, BOOL *stop) {
        if ([screenshot.displayTarget isEqualToString:displayTarget]) {
            [screenshotsForTarget addObject:screenshot];
        }
    }];
    
    NSArray *returnArray = [screenshotsForTarget sortedArrayUsingComparator:^NSComparisonResult(MAScreenshot *screenshot1, MAScreenshot *screenshot2) {
        if (screenshot1.position < screenshot2.position) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (screenshot1.position > screenshot2.position) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            NSLog(@"Two screenshots have the same position, that's definitely not good");
            // Should I do something about it, or just ignore it and hope for the best?
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    
    return returnArray;
}

- (NSArray *)iPhone4Screenshots
{
    return [self orderedArrayOfScreenshotsForTarget:displayTargetiPhone4];
}

- (NSArray *)iPhone5Screenshots
{
    return [self orderedArrayOfScreenshotsForTarget:displayTargetiPhone5];
}

- (NSArray *)iPadScreenshots
{
    return [self orderedArrayOfScreenshotsForTarget:displayTargetiPad];
}

#pragma mark - properties

- (NSArray *)keywords
{
    if (!_keywords) {
        _keywords = [NSArray array];
    }
    
    return _keywords;
}

- (NSArray *)screenshots
{
    if (!_screenshots) {
        _screenshots = [NSArray array];
    }
    
    return _screenshots;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setName:[aDecoder decodeObjectForKey:@"name"]];
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setLocalDescription:[aDecoder decodeObjectForKey:@"localDescription"]];
        [self setKeywords:[aDecoder decodeObjectForKey:@"keywords"]];
        [self setWhatsNew:[aDecoder decodeObjectForKey:@"whatsNew"]];
        [self setSoftwareURL:[aDecoder decodeObjectForKey:@"softwareURL"]];
        [self setPrivacyURL:[aDecoder decodeObjectForKey:@"privacyURL"]];
        [self setSupportURL:[aDecoder decodeObjectForKey:@"supportURL"]];
        [self setScreenshots:[aDecoder decodeObjectForKey:@"screenshots"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.localDescription forKey:@"localDescription"];
    [aCoder encodeObject:self.keywords forKey:@"keywords"];
    [aCoder encodeObject:self.whatsNew forKey:@"whatsNew"];
    [aCoder encodeObject:self.softwareURL forKey:@"softwareURL"];
    [aCoder encodeObject:self.privacyURL forKey:@"privacyURL"];
    [aCoder encodeObject:self.supportURL forKey:@"supportURL"];
    [aCoder encodeObject:self.screenshots forKey:@"screenshots"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MALocale *copy = [[MALocale alloc] init];
    
    [copy setName:self.name.copy];
    [copy setTitle:self.title.copy];
    [copy setLocalDescription:self.localDescription.copy];
    
    NSArray *keywordsCopy = [[NSArray alloc] initWithArray:self.keywords copyItems:YES];
    [copy setKeywords:keywordsCopy];
    
    [copy setWhatsNew:self.whatsNew.copy];
    [copy setSoftwareURL:self.softwareURL.copy];
    [copy setPrivacyURL:self.privacyURL.copy];
    [copy setSupportURL:self.supportURL.copy];
    
    NSArray *screenshotsCopy = [[NSArray alloc] initWithArray:self.screenshots copyItems:YES];
    [copy setScreenshots:screenshotsCopy];
    
    return copy;
}

#pragma mark - Description
- (NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@ \nTitle: %@ \nDescription: %@ \nKeywords: %@ \nWhat's New: %@ \nSoftwareURL: %@ \nPrivacyURL: %@ \nSupportURL: %@ \nScreenshots: %@", self.name, self.title, self.localDescription, self.keywords, self.whatsNew, self.softwareURL, self.privacyURL, self.supportURL, self.screenshots];
}

@end
