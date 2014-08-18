//
//  AppMetadata.m
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAAppMetadata.h"

id MANilNullCheck(id object) {
    if (object == [NSNull null] || [object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return object;
}

@interface MAAppMetadata ()
{
    NSString *xmlString;
    NSMutableArray *mutableVersions;
    MAVersion *currentVersion;
    MALocale *currentLocale;
    MAScreenshot *currentScreenshot;
}

@end

@implementation MAAppMetadata

- (id)initWithXML:(NSURL *)xmlURL
{
    if (![[xmlURL pathExtension] isCaseInsensitiveLike:@"xml"]) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
        [parser setDelegate:self];
        BOOL success = [parser parse];
        
        NSLog(@"%@", success ? @"XML Success!" : [NSString stringWithFormat:@"XMfaiL: %@", parser.parserError]);
        if (!success) {
            return nil;
        }
    }
    
    return self;
}

- (id)initWithXMLData:(NSData *)data
{
    self = [super init];
    
    if (self) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        BOOL success = [parser parse];
        
        NSLog(@"%@", success ? @"XML Success!" : [NSString stringWithFormat:@"XMfaiL: %@", parser.parserError]);
        if (!success) {
            return nil;
        }
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        __block MAVersion *version = [[MAVersion alloc] init];
        
        NSString *versionString = dictionary[@"version"];
        NSString *screenshotDirectory = dictionary[@"screenshotDirectory"];
        
        if (!versionString) {
            return nil;
        }
        
        [version setVersionString:versionString];
        
        NSDictionary *localizations = dictionary[@"localizations"];
        
        NSDictionary *languageCodes = [self languageDictionary];
        
        [localizations enumerateKeysAndObjectsUsingBlock:^(NSString *language, NSDictionary *localeMetadata, BOOL *stop) {
            NSString *localeName = MANilNullCheck(languageCodes[language]);
            
            if (!localeName) {
                return;
            }
            
            __block MALocale *newLocale = [[MALocale alloc] init];
            
            [newLocale setName:localeName];
            [newLocale setTitle:MANilNullCheck(localeMetadata[@"local_app_name"])];
            [newLocale setLocalDescription:MANilNullCheck(localeMetadata[@"description"])];
            
            //Keywords
            NSString *keywordString = MANilNullCheck(localeMetadata[@"keywords"]);
            NSArray *keywordArray = [keywordString componentsSeparatedByString:@","];
            
            [keywordArray enumerateObjectsUsingBlock:^(NSString *keyword, NSUInteger idx, BOOL *stop) {
                NSString *trimmedKeyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [newLocale addKeyword:trimmedKeyword];
            }];
            
            [newLocale setWhatsNew:MANilNullCheck(localeMetadata[@"new_in_version"])];
            // Ignore Software URL
            [newLocale setPrivacyURL:MANilNullCheck(localeMetadata[@"privacy_policy_url"])];
            [newLocale setSupportURL:MANilNullCheck(localeMetadata[@"support_url"])];
            
            // Screenshots
            // make dictionary of only the screenshot arrays
            NSArray *iPadScreenshots = MANilNullCheck(localeMetadata[@"ipad"]);
            NSArray *iPhone35Screenshots = MANilNullCheck(localeMetadata[@"iphone_35"]);
            NSArray *iPhone4Screenshots = MANilNullCheck(localeMetadata[@"iphone_4"]);
            
            NSDictionary *screenshots = @{@"ipad": iPadScreenshots,
                                          @"iphone_35": iPhone35Screenshots,
                                          @"iphone_4": iPhone4Screenshots,
                                          };
            
            // Cycle through each screenshot and add it to the model
            [screenshots enumerateKeysAndObjectsUsingBlock:^(NSString *screenshotType, NSArray *screenshots, BOOL *stop) {
                [screenshots enumerateObjectsUsingBlock:^(NSDictionary *screenshotInfo, NSUInteger idx, BOOL *stop) {
                    NSString *fileName = screenshotInfo[@"file_name"];
                    
                    if (!fileName) {
                        return;
                    }
                    
                    NSString *pathToScreenshot = [NSString stringWithFormat:@"%@/%@|%@", screenshotDirectory, screenshotType, fileName];
                    
                    MAScreenshot *screenshot = [MAScreenshot screenshotFromImageFile:[NSURL fileURLWithPath:pathToScreenshot]];
                    [screenshot setPosition:idx + 1];
                    
                    [newLocale addScreenshot:screenshot];
                }];
            }];
            
            // Add the locale to the version
            [version addLocale:newLocale];
        }];
        
        //Add the version to the metadata
        [self setVersions:@[version]];
    }
    
    return self;
}

#pragma mark - XML Delegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
//    NSLog(@"Did Start Element: %@ with namespaceURI: %@ qualified name: %@ attributes: %@", elementName, namespaceURI, qName, attributeDict);
    xmlString = @"";
    if ([elementName isEqualToString:@"package"]) {
        [self setPackageDictionary:attributeDict];
    }
    else if ([elementName isEqualToString:@"versions"]) {
        mutableVersions = [NSMutableArray array];
    }
    else if ([elementName isEqualToString:@"version"]) {
        currentVersion = [[MAVersion alloc] init];
        [currentVersion setVersionString:attributeDict[@"string"]];
    }
    else if ([elementName isEqualToString:@"locale"]) {
        currentLocale = [[MALocale alloc] init];
        [currentLocale setName:attributeDict[@"name"]];
    }
    else if ([elementName isEqualToString:@"software_screenshot"]) {
        currentScreenshot = [[MAScreenshot alloc] init];
        [currentScreenshot setDisplayTarget:attributeDict[@"display_target"]];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        [currentScreenshot setPosition:[[f numberFromString:attributeDict[@"position"]] unsignedIntegerValue]];
        f = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//    NSLog(@"Found characters: %@", string);
    xmlString = [xmlString stringByAppendingString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
//    NSLog(@"Did End Element: %@ with namespaceURI: %@ qualified name: %@", elementName, namespaceURI, qName);
    NSString *trimmedString = [xmlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![trimmedString isEqualToString:@""]) {
        if ([elementName isEqualToString:@"provider"]) {
            [self setProvider:trimmedString];
        }
        else if ([elementName isEqualToString:@"team_id"]) {
            [self setTeamID:trimmedString];
        }
        else if ([elementName isEqualToString:@"vendor_id"]) {
            [self setVendorID:trimmedString];
        }
        else if ([elementName isEqualToString:@"read_only_value"]) {
            [self setAppleID:trimmedString];
        }
        else if ([elementName isEqualToString:@"title"]) {
            [currentLocale setTitle:trimmedString];
        }
        else if ([elementName isEqualToString:@"description"]) {
            [currentLocale setLocalDescription:trimmedString];
        }
        else if ([elementName isEqualToString:@"keyword"]) {
            [currentLocale addKeyword:trimmedString];
        }
        else if ([elementName isEqualToString:@"support_url"]) {
            [currentLocale setSupportURL:trimmedString];
        }
        else if ([elementName isEqualToString:@"version_whats_new"]) {
            [currentLocale setWhatsNew:trimmedString];
        }
        else if ([elementName isEqualToString:@"software_url"]) {
            [currentLocale setSoftwareURL:trimmedString];
        }
        else if ([elementName isEqualToString:@"privacy_url"]) {
            [currentLocale setPrivacyURL:trimmedString];
        }
        else if ([elementName isEqualToString:@"file_name"]) {
            [currentScreenshot setFileName:trimmedString];
        }
        else if ([elementName isEqualToString:@"size"]) {
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            [currentScreenshot setSize:[f numberFromString:trimmedString]];
            f = nil;
        }
        else if ([elementName isEqualToString:@"checksum"]) {
            [currentScreenshot setChecksum:trimmedString];
        }
    }
    if ([elementName isEqualToString:@"version"]) {
        [mutableVersions addObject:currentVersion];
        currentVersion = nil;
    }
    else if ([elementName isEqualToString:@"versions"]) {
        [self setVersions:mutableVersions.copy];
        mutableVersions = nil;
    }
    else if ([elementName isEqualToString:@"locale"]) {
        [currentVersion addLocale:currentLocale];
        currentLocale = nil;
    }
    else if ([elementName isEqualToString:@"software_screenshot"]) {
        [currentLocale addScreenshot:currentScreenshot];
        currentScreenshot = nil;
    }
    
    xmlString = @"";
}

- (NSXMLDocument *)NSXMLDocumentRepresentation
{
    NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"package"];
    [self.packageDictionary.copy enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSString *value, BOOL *stop) {
        NSXMLNode *attribute = [NSXMLNode attributeWithName:name stringValue:value];
        [root addAttribute:attribute];
    }];
    
    //TODO: Add metadata token?
    
    NSXMLElement *provider = [[NSXMLElement alloc] initWithName:@"provider" stringValue:self.provider];
    [root addChild:provider];
    
    NSXMLElement *teamID = [[NSXMLElement alloc] initWithName:@"team_id" stringValue:self.teamID];
    [root addChild:teamID];
    
    NSXMLElement *software = [[NSXMLElement alloc] initWithName:@"software"];
    [root addChild:software];
    
    NSXMLElement *vendorID = [[NSXMLElement alloc] initWithName:@"vendor_id" stringValue:self.vendorID];
    [software addChild:vendorID];
    
    //TODO: Add Apple ID?
    
    NSXMLElement *softwareMetadata = [[NSXMLElement alloc] initWithName:@"software_metadata"];
    [software addChild:softwareMetadata];
    
    NSXMLElement *versions = [[NSXMLElement alloc] initWithName:@"versions"];
    [softwareMetadata addChild:versions];
    
    [self.versions.copy enumerateObjectsUsingBlock:^(MAVersion *version, NSUInteger idx, BOOL *stop) {
        NSXMLElement *element = [version NSXMLElementRepresentation];
        if (element) {
            [versions addChild:element];
        }
    }];
    
    NSXMLDocument *document = [NSXMLDocument documentWithRootElement:root];
    [document setVersion:@"1.0"];
    [document setCharacterEncoding:@"UTF-8"];
    
    return document;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setPackageDictionary:[aDecoder decodeObjectForKey:@"packageDictionary"]];
        [self setProvider:[aDecoder decodeObjectForKey:@"provider"]];
        [self setTeamID:[aDecoder decodeObjectForKey:@"teamID"]];
        [self setVendorID:[aDecoder decodeObjectForKey:@"vendorID"]];
        [self setAppleID:[aDecoder decodeObjectForKey:@"appleID"]];
        [self setVersions:[aDecoder decodeObjectForKey:@"versions"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.packageDictionary forKey:@"packageDictionary"];
    [aCoder encodeObject:self.provider forKey:@"provider"];
    [aCoder encodeObject:self.teamID forKey:@"teamID"];
    [aCoder encodeObject:self.vendorID forKey:@"vendorID"];
    [aCoder encodeObject:self.appleID forKey:@"appleID"];
    [aCoder encodeObject:self.versions forKey:@"versions"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAAppMetadata *copy = [[MAAppMetadata alloc] init];
    
    [copy setPackageDictionary:self.packageDictionary.copy];
    [copy setProvider:self.provider.copy];
    [copy setTeamID:self.teamID.copy];
    [copy setVendorID:self.vendorID.copy];
    [copy setAppleID:self.appleID.copy];
    NSArray *versionsCopy = [[NSArray alloc] initWithArray:self.versions copyItems:YES];
    [copy setVersions:versionsCopy];
    
    return copy;
}

#pragma mark - Description
- (NSString *)description
{
    NSString *descriptionString = [NSString stringWithFormat:@"\nProvider: %@, \nteamID: %@, \nvendorID: %@, \nappleID: %@", self.provider, self.teamID, self.vendorID, self.appleID];
    
    for (MAVersion *version in self.versions) {
        descriptionString = [descriptionString stringByAppendingString:[NSString stringWithFormat:@"\n%@", version]];
    }
    
    return descriptionString;
}

#pragma mark - Language Dictionary

- (NSDictionary *)languageDictionary
{
    return  @{@"English":@"en-US",
              @"German":@"de-DE",
              @"UK English":@"en-GB",
              @"Australian English":@"en-AU",
              @"Brazilian Portuguese":@"pt-BR",
              @"Canadian English":@"en-CA",
              @"Canadian French":@"fr-CA",
              @"Danish":@"da-DK",
              @"Dutch":@"nl-NL",
              @"Finnish":@"fi-FI",
              @"French":@"fr-FR",
              @"Greek":@"el-GR",
              @"Indonesian":@"id-ID",
              @"Italian":@"it-IT",
              @"Japanese":@"ja-JP",
              @"Korean":@"ko-KR",
              @"Latin American Spanish":@"es-MX",
              @"Malay":@"ms-MY",
              @"Norwegian":@"no-NO",
              @"Portuguese":@"pt-PT",
              @"Russian":@"ru-RU",
              @"Simplified Chinese":@"cmn-Hans",
              @"Spanish":@"es-ES",
              @"Swedish":@"sv-SE",
              @"Thai":@"th-TH",
              @"Traditional Chinese":@"cmn-Hant",
              @"Turkish":@"tr-TR",
              @"Vietnamese":@"vi-VI",
              };
}

@end
