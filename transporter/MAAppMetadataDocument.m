//
//  MAAppMetadataDocument.m
//  transporter
//
//  Created by Austin Younts on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAAppMetadataDocument.h"

#import "MAAppMetaDataWindowController.h"

#import "MAAppMetadata.h"

@interface MAAppMetadataDocument ()

@property (nonatomic, strong) MAAppMetaDataWindowController *windowController;

@end


@implementation MAAppMetadataDocument

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
    [self addWindowController:[[MAAppMetaDataWindowController alloc] init]];
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

//- (void)saveDocumentWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo
//{
//    NSSavePanel *savePanel = [NSSavePanel savePanel];
//    
//    [savePanel setTitle:@"Save changes as:"];
//    
//    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"matp", @"MATP", nil];
//    [savePanel setAllowedFileTypes:fileTypes];
//    [savePanel setAllowsOtherFileTypes:NO];
//    
//    NSInteger button = [savePanel runModal];
//    if (button == NSFileHandlingPanelOKButton){
//        NSURL *saveURL = [[savePanel directoryURL] URLByAppendingPathComponent:[savePanel nameFieldStringValue]];
//        if ([saveURL.pathExtension isCaseInsensitiveLike:@"matp"]) {
//            NSLog(@"Valid extension");
//        }
//        else {
//            NSLog(@"Invalid extension, adding .matp");
//            saveURL = [saveURL URLByAppendingPathExtension:@"matp"];
//        }
//        
//        NSLog(@"Should save as:%@", saveURL.path);
//        
//        //TODO: DO THIS!!
//    }
//}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if (fileWrapper.isDirectory) {
        [fileWrapper.fileWrappers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSFileWrapper *wrapper, BOOL *stop) {
            if (wrapper.isRegularFile && [wrapper.preferredFilename hasSuffix:@"xml"]) {
                self.original = [[MAAppMetadata alloc] initWithXMLData:wrapper.regularFileContents];
                if (self.original) {
                    *stop = YES;
                }
            }
        }];
        
        return (self.original) ? YES : NO;
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

#pragma mark - exporting

- (MAAppMetadata *)exportableMetadata
{
    MAAppMetadata *exportableMetadata = [[MAAppMetadata alloc] init];
    
    [exportableMetadata setPackageDictionary:self.original.packageDictionary];
    [exportableMetadata setProvider:self.original.provider];
    [exportableMetadata setTeamID:self.original.teamID];
    [exportableMetadata setVendorID:self.original.vendorID];
    [exportableMetadata setAppleID:self.original.appleID];
    [exportableMetadata setVersions:self.changes.versions];
    
    return exportableMetadata;
}

- (NSFileWrapper *)iTMSPackageFileWrapper
{
    // Set up iTMS package file wrapper
    __block NSFileWrapper *iTMSWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
    
    // Convert metadata into metadata.xml file wrapper
    MAAppMetadata *metadata = [self exportableMetadata];
    NSXMLDocument *metadataDocument = [metadata NSXMLDocumentRepresentation];
    NSData *xmlData = [metadataDocument XMLDataWithOptions:NSXMLNodePrettyPrint];
    NSFileWrapper *metadataWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:xmlData];
    [metadataWrapper setPreferredFilename:@"metadata.xml"];
    
    // Add metadata file wrapper to the iTMS Package file wrapper
    [iTMSWrapper addFileWrapper:metadataWrapper];
    
    NSMutableSet *screenshotNames = [NSMutableSet set];
    
    // Cycle through all of the screenshots, make a filewrapper for the screenshot, and add it to the ITMS wrapper
    [metadata.versions enumerateObjectsUsingBlock:^(MAVersion *version, NSUInteger idx, BOOL *stop) {
        [version.locales enumerateObjectsUsingBlock:^(MALocale *locale, NSUInteger idx, BOOL *stop) {
            [locale.screenshots enumerateObjectsUsingBlock:^(MAScreenshot *screenshot, NSUInteger idx, BOOL *stop) {
                NSURL *screenshotURL = screenshot.fileURL;
                NSData *screenshotData = [[NSFileManager defaultManager] contentsAtPath:screenshotURL.path];
                
                NSString *screenshotName = screenshot.fileName;
                
                // If the same screenshot is already being used, don't copy it over
                if ([screenshotNames containsObject:screenshotName]) {
                    return;
                }
                
                [screenshotNames addObject:screenshotName];
                
                if (!screenshotData || !screenshotName) {
                    return;
                }
                
                NSFileWrapper *screenshotWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:screenshotData];
                [screenshotWrapper setPreferredFilename:screenshotName];
                
                [iTMSWrapper addFileWrapper:screenshotWrapper];
            }];
        }];
    }];
    
    return iTMSWrapper;
}

#pragma mark - properties

- (void)setOriginal:(MAAppMetadata *)original
{
    _original = original;
    
    if (!self.changes) {
        NSLog(@"Copying original over to changes");
        [self setChanges:original.copy];
    }
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        [self setOriginal:[aDecoder decodeObjectForKey:@"original"]];
        [self setChanges:[aDecoder decodeObjectForKey:@"changes"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.original forKey:@"original"];
    [aCoder encodeObject:self.changes forKey:@"changes"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    MAAppMetadataDocument *copy = [[MAAppMetadataDocument alloc] init];
    
    [copy setOriginal:self.original];
    [copy setChanges:self.changes];
    
    return copy;
}

#pragma mark - Description
- (NSString *)description
{
    return [NSString stringWithFormat:@"\n******************************************************____CHANGES____******************************************************\n%@\n\n\n\n\n\n\n\n\n\n\n\n\n\n******************************************************____ORIGINAL____******************************************************\n%@", self.changes, self.original];
}

@end
