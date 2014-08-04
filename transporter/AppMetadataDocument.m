//
//  AppMetadataDocument.m
//  transporter
//
//  Created by Austin Younts on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "AppMetadataDocument.h"

#import "AppMetaDataWindowController.h"

#import "AppMetadata.h"

@interface AppMetadataDocument ()

@property (nonatomic, strong) AppMetaDataWindowController *windowController;

@property (nonatomic, strong) AppMetadata *model;

@end



@implementation AppMetadataDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

/*
- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return <#nibName#>;
}
*/

- (void)makeWindowControllers
{
    [self addWindowController:[[AppMetaDataWindowController alloc] init]];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return nil;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if (fileWrapper.isDirectory) {
        [fileWrapper.fileWrappers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSFileWrapper *wrapper, BOOL *stop) {
            if (wrapper.isRegularFile && [wrapper.preferredFilename hasSuffix:@"xml"]) {
                self.model = [[AppMetadata alloc] initWithXMLData:wrapper.regularFileContents];
                if (self.model) {
                    *stop = YES;
                }
            }
        }];
        
        return (self.model) ? YES : NO;
    }
    
    return NO;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:nil];
    }
    return YES;
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

@end
