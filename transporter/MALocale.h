//
//  Locale.h
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAScreenshot.h"

@interface MALocale : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *localDescription;
@property (nonatomic, strong) NSArray *keywords; // Should be an array of strings only
@property (nonatomic, strong) NSString *whatsNew;
@property (nonatomic, strong) NSString *softwareURL;
@property (nonatomic, strong) NSString *privacyURL;
@property (nonatomic, strong) NSString *supportURL;
@property (nonatomic, strong) NSArray *screenshots; // Should be an array of screenshots only

- (void)addKeyword:(NSString *)keyword;
- (void)removeKeyword:(NSString *)keyword;

- (void)addScreenshot:(MAScreenshot *)screenshot;
- (void)removeScreenshot:(MAScreenshot *)screenshot;

- (NSXMLElement *)NSXMLElementRepresentation;

- (NSArray *)iPhone4Screenshots;
- (NSArray *)iPhone5Screenshots;
- (NSArray *)iPadScreenshots;

@end
