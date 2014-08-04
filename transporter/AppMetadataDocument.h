//
//  AppMetadataDocument.h
//  transporter
//
//  Created by Austin Younts on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppMetadata;

@interface AppMetadataDocument : NSDocument

@property (nonatomic, strong, readonly) AppMetadata *model;

@end
