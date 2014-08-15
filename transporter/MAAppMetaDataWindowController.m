//
//  MAAppMetaDataWindowController.m
//  transporter
//
//  Created by Austin Younts on 7/30/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MAAppMetaDataWindowController.h"

#import "MAAppMetadataDocument.h"

#import "MALocaleViewController.h"

#import "MAAppMetadata.h"
#import "MAVersion.h"
#import "MALocale.h"

#import "MATextField.h"
#import "MALabel.h"

#import "CompactConstraint.h"

#import "MATransporter.h"
#import "MAAccountManager.h"

@interface MAAppMetaDataWindowController ()<NSWindowDelegate>

@property (nonatomic, strong, readonly) MAAppMetadataDocument *metaDataDocument;

@property (nonatomic, strong) MATextField *textFieldForProvider;
@property (nonatomic, strong) MATextField *textFieldForTeamID;
@property (nonatomic, strong) MATextField *textFieldForVendorID;
@property (nonatomic, strong) MATextField *textFieldForAppleID;
@property (nonatomic, strong) NSPopUpButton *popUpForVersions;
@property (nonatomic, strong) NSPopUpButton *popUpForLocales;

@property (nonatomic, strong) MALabel *labelForProvider;
@property (nonatomic, strong) MALabel *labelForTeamID;
@property (nonatomic, strong) MALabel *labelForVendorID;
@property (nonatomic, strong) MALabel *labelForAppleID;
@property (nonatomic, strong) MALabel *labelForVersions;
@property (nonatomic, strong) MALabel *labelForLocales;


@property (nonatomic, strong) NSArrayController *versionsController;
@property (nonatomic, strong) NSArrayController *localesController;

@property (nonatomic, strong) NSView *localeControllerContainerView;
@property (nonatomic, strong) MALocaleViewController *localeViewController;

@property (nonatomic) NSInteger selectedIndex;

@end

@implementation MAAppMetaDataWindowController
@dynamic metaDataDocument;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.localesController = [[NSArrayController alloc] init];
    
    // Window setup
    // TODO: Check current screen size for initial rect
    NSUInteger windowStyleMask = NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask;
    self.window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 500.0, 800.0) styleMask:windowStyleMask backing:NSBackingStoreBuffered defer:YES];
    
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:[NSColor whiteColor].CGColor];
    [self.window.contentView setWantsLayer:YES];
    [self.window.contentView setLayer:viewLayer];
    
    [self.window makeKeyAndOrderFront:self];
    
    
    // Autolayout
    NSDictionary *views = @{@"provider" : self.textFieldForProvider, @"appleID" : self.textFieldForAppleID, @"teamID" : self.textFieldForTeamID, @"vendorID" : self.textFieldForVendorID, @"versions" : self.popUpForVersions, @"locales" : self.popUpForLocales,
                            @"labelAppleID" : self.labelForAppleID, @"labelProvider" : self.labelForProvider, @"labelTeamID" : self.labelForTeamID, @"labelVendorID" : self.labelForVendorID, @"labelVersion" : self.labelForVersions, @"labelLocale" : self.labelForLocales, @"localeContainer" : self.localeControllerContainerView};
    
    [self.window.contentView addConstraintsWithVisualFormat:@"V:|-50-[labelAppleID]-20-[labelTeamID]-20-[labelVendorID]-20-[labelProvider]-20-[labelVersion]-20-[labelLocale]" options:NSLayoutFormatAlignAllRight metrics:nil views:views];
    [self.window.contentView addConstraintsWithVisualFormat:@"H:|-100-[appleID]" options:0 metrics:nil views:views];
    [self.window.contentView addConstraintsWithVisualFormat:@"H:|-50-[localeContainer]-50-|" options:0 metrics:nil views:views];
    [self.window.contentView addConstraintsWithVisualFormat:@"V:[labelLocale]-40-[localeContainer]-40-|" options:0 metrics:nil views:views];
    
    NSMapTable *labelsAndFields = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsObjectPointerPersonality];
    [labelsAndFields setObject:self.textFieldForAppleID forKey:self.labelForAppleID];
    [labelsAndFields setObject:self.textFieldForProvider forKey:self.labelForProvider];
    [labelsAndFields setObject:self.textFieldForTeamID forKey:self.labelForTeamID];
    [labelsAndFields setObject:self.textFieldForVendorID forKey:self.labelForVendorID];
    [labelsAndFields setObject:self.popUpForVersions forKey:self.labelForVersions];
    [labelsAndFields setObject:self.popUpForLocales forKey:self.labelForLocales];
    
    for (NSView *label in labelsAndFields) {
        NSView *field = [labelsAndFields objectForKey:label];
        NSDictionary *views = NSDictionaryOfVariableBindings(label, field);
        [self.window.contentView addConstraintsWithVisualFormat:@"H:[label]-10-[field]-50-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views];
    }

    return self;
}

- (void)setDocument:(id)document
{
    if (!document) return;
    
    [super setDocument:document];
    
    [self updateUIBindings];
}

- (MAAppMetadataDocument *)metaDataDocument
{
    return self.document;
}

- (void)updateUIBindings
{
    self.versionsController = [[NSArrayController alloc] initWithContent:self.metaDataDocument.changes.versions];
    [self.popUpForVersions bind:@"content" toObject:self.versionsController withKeyPath:@"arrangedObjects" options:nil];
    [self.popUpForVersions bind:@"contentValues" toObject:self.versionsController withKeyPath:@"arrangedObjects.versionString" options:nil];
    [self.popUpForVersions bind:@"selectedIndex" toObject:self.versionsController withKeyPath:@"selectionIndex" options:nil];
    
    [self.popUpForLocales bind:@"content" toObject:self.localesController withKeyPath:@"arrangedObjects" options:nil];
    [self.popUpForLocales bind:@"contentValues" toObject:self.localesController withKeyPath:@"arrangedObjects.name" options:nil];
    [self.popUpForLocales bind:@"selectedIndex" toObject:self.localesController withKeyPath:@"selectionIndex" options:nil];
    
    // TODO: Make these fields not editable.
    [self.textFieldForAppleID bind:@"value" toObject:self.metaDataDocument.original withKeyPath:@"appleID" options:nil];
    [self.textFieldForProvider bind:@"value" toObject:self.metaDataDocument.original withKeyPath:@"provider" options:nil];
    [self.textFieldForTeamID bind:@"value" toObject:self.metaDataDocument.original withKeyPath:@"teamID" options:nil];
    [self.textFieldForVendorID bind:@"value" toObject:self.metaDataDocument.original withKeyPath:@"vendorID" options:nil];
    
    if (self.popUpForVersions.itemArray.count > 0) {
        [self.popUpForVersions selectItemAtIndex:0];
        [self popUpMenuChanged:self.popUpForVersions];
    }
    
    if (self.popUpForLocales.itemArray.count > 0) {
        [self.popUpForLocales selectItemAtIndex:0];
        [self popUpMenuChanged:self.popUpForLocales];
        [self.localeViewController scrollToBeginningOfDocument:self];
    }
}

- (void)popUpMenuChanged:(NSPopUpButton *)popUp
{
    if (popUp == self.popUpForVersions) {
        MAVersion *version = self.versionsController.arrangedObjects[self.versionsController.selectionIndex];
        self.localesController.content = version.locales;
    }
    else if (popUp == self.popUpForLocales)
    {
        self.localeViewController.locale = self.localesController.arrangedObjects[self.localesController.selectionIndex];
    }
}

#pragma mark - Importing & Exporting

- (void)documentIsOpen
{
    // This method intentionally left blank
}

- (void)importFromFile
{
    // Pop up open file panel, select xml or itmsp
    NSOpenPanel* dlg =[NSOpenPanel openPanel];
    [dlg setTitle:@"Select an iTMS package or xml file"];
    [dlg setCanChooseFiles:YES];
    [dlg setCanChooseDirectories:NO];
    [dlg setAllowsMultipleSelection:NO];
    
    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"itmsp", @"ITMSP", @"xml", @"XML", nil];
    [dlg setAllowedFileTypes:fileTypes];
    
    NSInteger button = [dlg runModal];
    if (button != NSFileHandlingPanelOKButton){
        return;
    }
    
    NSURL *chosenURL = [[dlg URLs] objectAtIndex:0];
    
    if ([chosenURL.pathExtension isCaseInsensitiveLike:@"itmsp"]) {
        chosenURL = [chosenURL URLByAppendingPathComponent:@"metadata.xml"];
    }
    
    // Convert to AppMetadata
    MAAppMetadata *original = [[MAAppMetadata alloc] initWithXML:chosenURL];
    
    if (!original) {
        NSLog(@"import error!");
        return;
    }
    
    // Check to make sure provider name matches document (if it already has an original).
    if (self.metaDataDocument.original && ![self.metaDataDocument.original.appleID isEqualToString:original.appleID]) {
        // Pop up alert to let them know this file doesn't match the original
        NSAlert *alert = [NSAlert alertWithMessageText: @"The selected file's Apple ID does not match the app's Apple ID.  Are you sure you want to continue?"
                                         defaultButton:@"OK"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@""];
        
        NSInteger button = [alert runModal];
        if (button != NSAlertDefaultReturn) {
            return;
        }
    }
    
    // Save as the document's "original" metadata
    [self.metaDataDocument setOriginal:original];
    
    [self updateUIBindings];
}

- (void)importFromiTunesConnect
{
    NSLog(@"Import from iTunes Connect");
    
    NSAlert *alert = [NSAlert alertWithMessageText: @"Enter select account and SKU"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSView *contentView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 56)];
    
    NSComboBox *accountComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(0, 32, 300, 24)];
    [accountComboBox setUsesDataSource:NO];
    [accountComboBox addItemsWithObjectValues:[MAAccountManager allUsernames]];
    
    NSTextField *AppleIDTextBox = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
    [[AppleIDTextBox cell] setPlaceholderString:@"Apple ID"];
    
    [contentView addSubview:accountComboBox];
    [contentView addSubview:AppleIDTextBox];
    
    [alert setAccessoryView:contentView];
    NSInteger button = [alert runModal];
    if (button != NSAlertDefaultReturn) {
        return;
    }
    
    [AppleIDTextBox validateEditing];
    
    NSString *username = (NSString *)[accountComboBox objectValueOfSelectedItem];
    NSString *appleID = (NSString *)[AppleIDTextBox stringValue];
    
    NSLog(@"Account: %@, AppleID: %@", username, appleID);
    
    [MATransporter retrieveMetadataForAccount:[MAAccountManager accountWithUsername:username] appleID:appleID toDirectory:@"/tmp/" completion:^(BOOL success, NSDictionary *info, NSError *error) {
        NSLog(@"Info Dict: %@", info);
        if (success) {
            NSString *packagePath = info[@"packagePath"];
            NSURL *xmlURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/metadata.xml", packagePath]];
            
            MAAppMetadata *original = [[MAAppMetadata alloc] initWithXML:xmlURL];
            
            if (!original) {
                NSLog(@"import error!");
                return;
            }
            
            // Check to make sure provider name matches document (if it already has an original).
            if (self.metaDataDocument.original && ![self.metaDataDocument.original.appleID isEqualToString:original.appleID]) {
                // Pop up alert to let them know this file doesn't match the original
                NSAlert *alert = [NSAlert alertWithMessageText: @"The selected file's Apple ID does not match the app's Apple ID.  Are you sure you want to continue?"
                                                 defaultButton:@"OK"
                                               alternateButton:@"Cancel"
                                                   otherButton:nil
                                     informativeTextWithFormat:@""];
                
                NSInteger button = [alert runModal];
                if (button != NSAlertDefaultReturn) {
                    return;
                }
            }
            
            // Save as the document's "original" metadata
            [self.metaDataDocument setOriginal:original];
            
            [[NSFileManager defaultManager] removeItemAtPath:packagePath error:nil];
            
            [self updateUIBindings];
        }
        else {
            NSLog(@"transporter unsuccessful: %@", error);
        }
    }];
    
    
    
}

- (void)importChangesFromZip
{
    
    NSLog(@"Import changes from zip file");
}

- (void)exportToFile
{
    NSLog(@"%@", self.metaDataDocument);
}

- (void)verifyWithiTunesConnect
{
    
}

- (void)submitToiTunesConnect
{
    
}

#pragma mark - Accessors
- (MALocaleViewController *)localeViewController
{
    if (!_localeViewController) {
        
        _localeViewController = [[MALocaleViewController alloc] init];
        
        [self.localeControllerContainerView addSubview:_localeViewController.view];
        
        NSDictionary *views = @{@"controller" : _localeViewController.view};
        [self.localeControllerContainerView addConstraintsWithVisualFormat:@"H:|[controller]|" options:0 metrics:nil views:views];
        [self.localeControllerContainerView addConstraintsWithVisualFormat:@"V:|[controller]|" options:0 metrics:nil views:views];
    }
    return _localeViewController;
}

#pragma mark - Views
#pragma mark -- TextFields
- (MATextField *)textFieldForAppleID {
    if (!_textFieldForAppleID) {
        _textFieldForAppleID = [self newTextField];
        [_textFieldForAppleID setEditable:NO];
    }
    return _textFieldForAppleID;
}

- (MATextField *)textFieldForProvider {
    if (!_textFieldForProvider) {
        _textFieldForProvider = [self newTextField];
        [_textFieldForProvider setEditable:NO];
    }
    return _textFieldForProvider;
}

- (MATextField *)textFieldForTeamID {
    if (!_textFieldForTeamID) {
        _textFieldForTeamID = [self newTextField];
        [_textFieldForTeamID setEditable:NO];
    }
    return _textFieldForTeamID;
}

- (MATextField *)textFieldForVendorID {
    if (!_textFieldForVendorID) {
        _textFieldForVendorID = [self newTextField];
        [_textFieldForVendorID setEditable:NO];
    }
    return _textFieldForVendorID;
}

- (MATextField *)newTextField {
    MATextField *textField = [[MATextField alloc] init];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.window.contentView addSubview:textField];
    return textField;
}

#pragma mark -- Labels
- (MALabel *)labelForAppleID {
    if (!_labelForAppleID) {
        _labelForAppleID = [self newLabel];
        _labelForAppleID.stringValue = @"AppleID:";
    }
    return _labelForAppleID;
}

- (MALabel *)labelForProvider {
    if (!_labelForProvider) {
        _labelForProvider = [self newLabel];
        _labelForProvider.stringValue = @"Provider:";
    }
    return _labelForProvider;
}

- (MALabel *)labelForTeamID {
    if (!_labelForTeamID) {
        _labelForTeamID = [self newLabel];
        _labelForTeamID.stringValue = @"TeamID:";
    }
    return _labelForTeamID;
}

- (MALabel *)labelForVendorID {
    if (!_labelForVendorID) {
        _labelForVendorID = [self newLabel];
        _labelForVendorID.stringValue = @"VendorID:";
    }
    return _labelForVendorID;
}

- (MALabel *)labelForVersions {
    if (!_labelForVersions) {
        _labelForVersions = [self newLabel];
        _labelForVersions.stringValue = @"Version:";
    }
    return _labelForVersions;
}

- (MALabel *)labelForLocales {
    if (!_labelForLocales) {
        _labelForLocales = [self newLabel];
        _labelForLocales.stringValue = @"Locales:";
    }
    return _labelForLocales;
}

- (MALabel *)newLabel {
    MALabel *label = [[MALabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.window.contentView addSubview:label];
    return label;
}

#pragma mark -- PopUps
- (NSPopUpButton *)popUpForVersions {
    if (!_popUpForVersions) {
        _popUpForVersions = [self newPopUpButton];
    }
    return _popUpForVersions;
}

- (NSPopUpButton *)popUpForLocales {
    if (!_popUpForLocales) {
        _popUpForLocales = [self newPopUpButton];
    }
    return _popUpForLocales;
}

- (NSPopUpButton *)newPopUpButton {
    NSPopUpButton *button = [[NSPopUpButton alloc] initWithFrame:CGRectZero pullsDown:NO];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTarget:self];
    [button setAction:@selector(popUpMenuChanged:)];
    [self.window.contentView addSubview:button];
    return button;
}

#pragma mark -- Other

- (NSView *)localeControllerContainerView {
    if (!_localeControllerContainerView) {
        _localeControllerContainerView = [[NSView alloc] initWithFrame:CGRectZero];
        _localeControllerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.window.contentView addSubview:_localeControllerContainerView];
        
        CALayer *viewLayer = [CALayer layer];
        viewLayer.backgroundColor = [NSColor greenColor].CGColor;
        _localeControllerContainerView.wantsLayer = YES;
        _localeControllerContainerView.layer = viewLayer;
    }
    return _localeControllerContainerView;
}

@end
