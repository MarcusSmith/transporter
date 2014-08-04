//
//  Locale.m
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "Locale.h"

@implementation Locale

- (void)addScreenshot:(Screenshot *)screenshot
{
    self.screenshots = [self.screenshots arrayByAddingObject:screenshot];
}

- (void)addKeyword:(NSString *)keyword
{
    self.keywords = [self.keywords arrayByAddingObject:keyword];
}

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
        [self.screenshots.copy enumerateObjectsUsingBlock:^(Screenshot *screenshot, NSUInteger idx, BOOL *stop) {
            NSXMLElement *element = [screenshot NSXMLElementRepresentation];
            if (element) {
                [screenshots addChild:element];
            }
        }];
        [root addChild:screenshots];
    }
    
    return root;
}

@end
