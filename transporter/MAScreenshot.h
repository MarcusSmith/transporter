//
//  MAScreenshot.h
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const displayTargetiPhone4;
extern NSString * const displayTargetiPhone5;
extern NSString * const displayTargetiPad;

@interface MAScreenshot : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *displayTarget;
@property (nonatomic, readwrite) NSUInteger position;
@property (nonatomic, strong) NSNumber *size;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *checksum;
@property (nonatomic, strong) NSURL *fileURL;

- (id)initWithImageFile:(NSURL *)fileURL;
+ (instancetype)screenshotFromImageFile:(NSURL *)fileURL;

- (NSXMLElement *)NSXMLElementRepresentation;

@end
