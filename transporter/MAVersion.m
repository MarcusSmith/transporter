//
//  MAVersion.m
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAVersion.h"

@implementation MAVersion

- (void)addLocale:(MALocale *)locale
{
    self.locales = [self.locales arrayByAddingObject:locale];
}

- (NSArray *)locales
{
    if (!_locales) {
        _locales = [NSArray array];
    }
    
    return _locales;
}

- (NSXMLElement *)NSXMLElementRepresentation
{
    // If there isn't a version string or locales the Version isn't valid, return nil
    if (!self.versionString || !self.locales || self.locales.count < 1) {
        return nil;
    }
    
    NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"version"];
    [root addAttribute:[NSXMLNode attributeWithName:@"string" stringValue:self.versionString]];
    
    NSXMLElement *locales = [[NSXMLElement alloc] initWithName:@"locales"];
    [self.locales.copy enumerateObjectsUsingBlock:^(MALocale *locale, NSUInteger idx, BOOL *stop) {
        NSXMLElement *element = [locale NSXMLElementRepresentation];
        if (element) {
            [locales addChild:element];
        }
    }];
    [root addChild:locales];
    
    return root;
}

@end
