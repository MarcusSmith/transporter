//
//  Locale.h
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Screenshot.h"

@interface Locale : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSArray *keywords; // Should be an array of strings only
@property (nonatomic, strong) NSString *whatsNew;
@property (nonatomic, strong) NSString *softwareURL;
@property (nonatomic, strong) NSString *privacyURL;
@property (nonatomic, strong) NSString *supportURL;
@property (nonatomic, strong) NSArray *screenshots; // Should be an array of screenshots only

- (void)addKeyword:(NSString *)keyword;
- (void)addScreenshot:(Screenshot *)screenshot;
- (NSXMLElement *)NSXMLElementRepresentation;

@end
