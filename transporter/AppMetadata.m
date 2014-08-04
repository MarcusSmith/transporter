//
//  AppMetadata.m
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "AppMetadata.h"

@interface AppMetadata ()
{
    NSString *xmlString;
    NSMutableArray *mutableVersions;
    Version *currentVersion;
    Locale *currentLocale;
    Screenshot *currentScreenshot;
}

@end

@implementation AppMetadata

- (id)initWithXML:(NSURL *)xmlURL
{
    NSAssert([[xmlURL pathExtension] isEqualToString:@"xml"], @"initWithXML method can only be called on an xml file");
    
    self = [super init];
    
    if (self) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
        [parser setDelegate:self];
        BOOL success = [parser parse];
        NSLog(@"%@", success ? @"XML Success!" : @"XMfaiL");
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
        currentVersion = [[Version alloc] init];
        [currentVersion setVersionString:attributeDict[@"string"]];
    }
    else if ([elementName isEqualToString:@"locale"]) {
        currentLocale = [[Locale alloc] init];
        [currentLocale setName:attributeDict[@"name"]];
    }
    else if ([elementName isEqualToString:@"software_screenshot"]) {
        currentScreenshot = [[Screenshot alloc] init];
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
            [currentLocale setDescription:trimmedString];
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
    
    [self.versions.copy enumerateObjectsUsingBlock:^(Version *version, NSUInteger idx, BOOL *stop) {
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

@end
