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

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setVersionString:[aDecoder decodeObjectForKey:@"versionString"]];
        [self setLocales:[aDecoder decodeObjectForKey:@"locales"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.versionString forKey:@"versionString"];
    [aCoder encodeObject:self.locales forKey:@"locales"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAVersion *copy = [[MAVersion alloc] init];
    
    [copy setVersionString:self.versionString.copy];
    
    NSArray *localesCopy = [[NSArray alloc] initWithArray:self.locales copyItems:YES];
    [copy setLocales:localesCopy];
    
    return copy;
}

#pragma mark - Description
- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:@"\n Version: %@", self.versionString];
    for (MALocale *locale in self.locales) {
        descriptionString = [descriptionString stringByAppendingString:[NSString stringWithFormat:@"\n%@", locale]];
    }
    return descriptionString;
}

@end
