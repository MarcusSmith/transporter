//
//  AppMetadata.h
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Version.h"

@interface AppMetadata : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSDictionary *packageDictionary;
@property (nonatomic, strong) NSString *provider;
@property (nonatomic, strong) NSString *teamID;
@property (nonatomic, strong) NSString *vendorID;
@property (nonatomic, strong) NSString *appleID;
@property (nonatomic, strong) NSArray *versions;

- (id)initWithXML:(NSURL *)xmlURL;
- (NSXMLDocument *)NSXMLDocumentRepresentation;

- (id)initWithXMLData:(NSData *)data;

@end
