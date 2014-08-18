//
//  MAAppMetaDataWindowController.h
//  transporter
//
//  Created by Austin Younts on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MAAppMetaDataWindowController : NSWindowController

// This method exists just to see if a document is open or not
- (void)documentIsOpen;

// Import options
- (void)importFromFile;
- (void)importFromiTunesConnect;
- (void)importChangesFromDirectory;

// Export options
- (void)exportToFile;
- (void)submitToiTunesConnect;
- (void)verifyWithiTunesConnect;

@end
