//
//  AppDelegate.m
//  transporter
//
//  Created by Marcus Smith on 7/11/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "AppDelegate.h"
#import <AppKit/AppKit.h>
#import "MAAccountManager.h"
#import "MAKeychain.h"
#import "MATransporter.h"
#import "MAAppMetadata.h"
#import "MAAppMetaDataWindowController.h"
#import "MAHidingMenu.h"

@interface AppDelegate ()
{
    NSStatusItem *statusItem;
}

@property (nonatomic, strong) NSDocumentController *documentController;
@property (nonatomic, strong) MAHidingMenu *importMenu;
@property (nonatomic, strong) MAHidingMenu *exportMenu;
@property (nonatomic, strong) NSMenu *statusDropdownMenu;

@property (nonatomic, strong) NSMenuItem *testMenu;

@property (nonatomic, readwrite) BOOL transporterIsConnected;

@end

@implementation AppDelegate

@dynamic documentController;

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [self documentController];
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    
    // Add import and export menus to the File menu
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    
    NSMenu *fileMenu = [[mainMenu itemAtIndex:1] submenu];
    
    [fileMenu insertItem:self.importMenu atIndex:3];
    [fileMenu insertItem:self.exportMenu atIndex:4];
    
//    [fileMenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
//        NSLog(@"%@", item.title);
//    }];
//
//    [fileMenu removeItemAtIndex:1];
    
    // Add test menu
    [mainMenu insertItem:self.testMenu atIndex:2];
    
    // Set up notifications from transporter
    [[MATransporter sharedTransporter] setSendsConnectionNotifications:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transporterConnected) name:MATransporterNotificationTransporterConnected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transporterDisconnected) name:MATransporterNotificationTransporterDisconnected object:nil];
    
    // Set up connection icon in status bar
    statusItem = [[NSStatusBar systemStatusBar]
                   statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"blackT"]];
    [statusItem setEnabled:NO];
    [statusItem setAction:@selector(updateTransporterConnection)];

    self.transporterIsConnected = [[MATransporter sharedTransporter] isConnected];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Accessors
- (NSDocumentController *)documentController
{
    return [NSDocumentController sharedDocumentController];
}

#pragma mark - Menus

- (MAHidingMenu *)importMenu
{
    if (!_importMenu) {
        _importMenu = [[MAHidingMenu alloc] initWithTitle:@"Import" action:@selector(documentIsOpen) keyEquivalent:@""];
        NSMenu *importSubmenu = [[NSMenu alloc] init];
        [_importMenu setSubmenu:importSubmenu];
        
        NSMenuItem *fromFileItem = [[NSMenuItem alloc] initWithTitle:@"From File..." action:@selector(importFromFile) keyEquivalent:@""];
        [importSubmenu addItem:fromFileItem];
        
        NSMenuItem *iTCItem = [[NSMenuItem alloc] initWithTitle:@"Metadata from iTunesConnect..." action:@selector(importFromiTunesConnect) keyEquivalent:@""];
        [importSubmenu addItem:iTCItem];
        
        NSMenuItem *changeItem = [[NSMenuItem alloc] initWithTitle:@"Changes from Directory..." action:@selector(importChangesFromDirectory) keyEquivalent:@""];
        [importSubmenu addItem:changeItem];
    }
    
    return _importMenu;
}

- (MAHidingMenu *)exportMenu
{
    if (!_exportMenu) {
        _exportMenu = [[MAHidingMenu alloc] initWithTitle:@"Export" action:@selector(documentIsOpen) keyEquivalent:@""];
        NSMenu *exportSubmenu = [[NSMenu alloc] init];
        [_exportMenu setSubmenu:exportSubmenu];
        
        NSMenuItem *toFileItem = [[NSMenuItem alloc] initWithTitle:@"To File..." action:@selector(exportToFile) keyEquivalent:@""];
        [exportSubmenu addItem:toFileItem];
        
        NSMenuItem *verifyItem = [[NSMenuItem alloc] initWithTitle:@"Validate with iTunesConnect" action:@selector(verifyWithiTunesConnect) keyEquivalent:@""];
        [exportSubmenu addItem:verifyItem];
        
        NSMenuItem *submitItem = [[NSMenuItem alloc] initWithTitle:@"Submit to iTunesConnect" action:@selector(submitToiTunesConnect) keyEquivalent:@""];
        [exportSubmenu addItem:submitItem];
    }
    
    return _exportMenu;
}

- (NSMenu *)statusDropdownMenu
{
    if (!_statusDropdownMenu) {
        _statusDropdownMenu = [[NSMenu alloc] init];
    }
    
    return _statusDropdownMenu;
}

#pragma mark - connection

- (void)transporterConnected
{
    NSLog(@"transporter connected method called");
    [self setTransporterIsConnected:YES];
}

- (void)transporterDisconnected
{
    NSLog(@"transporter disconnected method called");
    [self setTransporterIsConnected:NO];
}

- (void)setTransporterIsConnected:(BOOL)transporterIsConnected
{
    _transporterIsConnected = transporterIsConnected;
    
    if (transporterIsConnected) {
        [statusItem setEnabled:YES];
    }
    else {
        [statusItem setEnabled:NO];
    }
}

- (void)updateTransporterConnection
{
    [[MATransporter sharedTransporter] updateIsConnected];
}

#pragma mark - Marcus tests

- (NSMenuItem *)testMenu
{
    if (!_testMenu) {
        _testMenu = [[NSMenuItem alloc] initWithTitle:@"Test Menu" action:nil keyEquivalent:@""];
        
        NSMenu *testSubmenu = [[NSMenu alloc] initWithTitle:@"Tests"];
        [_testMenu setSubmenu:testSubmenu];
        
        // ACCOUNTS
        NSMenuItem *accountItem = [[NSMenuItem alloc] initWithTitle:@"Accounts" action:nil keyEquivalent:@""];
        NSMenu *accountSubmenu = [[NSMenu alloc] init];
        [accountItem setSubmenu:accountSubmenu];
        
        NSMenuItem *addAccountItem = [[NSMenuItem alloc] initWithTitle:@"Add Account" action:@selector(addAccount) keyEquivalent:@""];
        [accountSubmenu addItem:addAccountItem];
        
        NSMenuItem *checkAccountItem = [[NSMenuItem alloc] initWithTitle:@"Check Account" action:@selector(checkAccount) keyEquivalent:@""];
        [accountSubmenu addItem:checkAccountItem];
        
        NSMenuItem *updateAccountItem = [[NSMenuItem alloc] initWithTitle:@"Update Account" action:@selector(updateAccount) keyEquivalent:@""];
        [accountSubmenu addItem:updateAccountItem];
        
        NSMenuItem *removeAccountItem = [[NSMenuItem alloc] initWithTitle:@"Remove Account" action:@selector(removeAccount) keyEquivalent:@""];
        [accountSubmenu addItem:removeAccountItem];
        
        NSMenuItem *allAccountsItem = [[NSMenuItem alloc] initWithTitle:@"All Accounts" action:@selector(listAllAccounts) keyEquivalent:@""];
        [accountSubmenu addItem:allAccountsItem];
        
        NSMenuItem *removeAllAccountsItem = [[NSMenuItem alloc] initWithTitle:@"Remove All Accounts" action:@selector(removeAllAccounts) keyEquivalent:@""];
        [accountSubmenu addItem:removeAllAccountsItem];
        
        // iTMS TRANSPORTER
        NSMenuItem *iTMSItem = [[NSMenuItem alloc] initWithTitle:@"iTMS Transporter" action:nil keyEquivalent:@""];
        NSMenu *iTMSSubmenu = [[NSMenu alloc] init];
        [iTMSItem setSubmenu:iTMSSubmenu];
        
        NSMenuItem *retrieveMetadataItem = [[NSMenuItem alloc] initWithTitle:@"Retrieve Metadata" action:@selector(retrieveMetadata) keyEquivalent:@""];
        [iTMSSubmenu addItem:retrieveMetadataItem];
        
        NSMenuItem *validatePackageItem = [[NSMenuItem alloc] initWithTitle:@"Validate Package" action:@selector(validatePackage) keyEquivalent:@""];
        [iTMSSubmenu addItem:validatePackageItem];
        
        NSMenuItem *submitPackageItem = [[NSMenuItem alloc] initWithTitle:@"Submit Package" action:@selector(submitPackage) keyEquivalent:@""];
        [iTMSSubmenu addItem:submitPackageItem];
        
        [testSubmenu addItem:accountItem];
        
        [testSubmenu addItem:iTMSItem];
    }
    
    return _testMenu;
}

#pragma mark - Accounts

- (void)listAllAccounts
{
    NSLog(@"All Accounts:\n%@", [MAAccountManager iTunesConnectAccounts]);
}

- (void)removeAllAccounts
{
    [MAAccountManager removeAllAccounts];
}

- (void)addAccount
{
    NSAlert *alert = [NSAlert alertWithMessageText: @"Enter account username and password"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSView *viewForTextFields = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 56)];
    
    NSTextField *usernameInput = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 32, 200, 24)];
    [[usernameInput cell] setPlaceholderString:@"username"];
    
    NSTextField *passwordInput = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [[passwordInput cell] setPlaceholderString:@"password"];
    
    [viewForTextFields addSubview:usernameInput];
    [viewForTextFields addSubview:passwordInput];
    
    [alert setAccessoryView:viewForTextFields];
    NSInteger button = [alert runModal];
    if (button != NSAlertDefaultReturn) {
        return;
    }
    
    [usernameInput validateEditing];
    [passwordInput validateEditing];
    
    NSError *error;
    
    MAiTunesConnectAccount *newAccount = [MAiTunesConnectAccount accountWithUsername:[usernameInput stringValue]];
    
    [MAAccountManager addAccount:newAccount];
    
    BOOL success = [newAccount setPassword:[passwordInput stringValue] error:&error];
    
    NSLog(@"Save %@", success ? @"successful" : [NSString stringWithFormat:@"unsuccessful with error: %@", error]);
}

- (void)checkAccount
{
    NSAlert *alert = [NSAlert alertWithMessageText: @"Enter account username"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [[input cell] setPlaceholderString:@"username"];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button != NSAlertDefaultReturn) {
        return;
    }
    
    [input validateEditing];
    NSString *username = [input stringValue];
    
    NSLog(@"username: %@, password: %@", username, [[MAAccountManager accountWithUsername:username] password]);
}

- (void)updateAccount
{
    NSLog(@"Update Account");
    
    NSAlert *alert = [NSAlert alertWithMessageText: @"Select Account"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSComboBox *accountComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(0, 32, 300, 24)];
    [accountComboBox setUsesDataSource:NO];
    [accountComboBox addItemsWithObjectValues:[MAAccountManager allUsernames]];
    
    [alert setAccessoryView:accountComboBox];
    NSInteger button = [alert runModal];
    if (button != NSAlertDefaultReturn) {
        return;
    }
    
    NSString *username = (NSString *)[accountComboBox objectValueOfSelectedItem];
    MAiTunesConnectAccount *account = [MAAccountManager accountWithUsername:username];
    
    [MAAccountManager updateAccount:account];
}

- (void)removeAccount
{
    NSAlert *alert = [NSAlert alertWithMessageText: @"Enter account username to remove"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [[input cell] setPlaceholderString:@"username"];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button != NSAlertDefaultReturn) {
        return;
    }
    
    [input validateEditing];
    NSString *username = [input stringValue];
    
    BOOL success = [MAAccountManager removeAccountWithUsername:username];
    
    NSLog(@"Remove Account %@", success ? @"successful" : @"unsuccessful");
}

#pragma mark - iTMS Transporter

- (void)retrieveMetadata
{
    NSLog(@"Retrieve Metadata");
    
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
    
    [[MATransporter sharedTransporter] retrieveMetadataForAccount:[MAAccountManager accountWithUsername:username] appleID:appleID toDirectory:[@"~/Desktop" stringByExpandingTildeInPath] completion:^(BOOL success, NSDictionary *info, NSError *error) {
        NSLog(@"Info Dict: %@", info);
        if (success) {
            // If there was a package successfully downloaded and the account doesn't have a provider, get the provider from the package and add it to the account
            MAiTunesConnectAccount *account = info[@"account"];
            if (!account.providerName) {
                NSString *packagePath = info[@"packagePath"];
                NSURL *xmlURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/metadata.xml", packagePath]];
                
                MAAppMetadata *appMetadata = [[MAAppMetadata alloc] initWithXML:xmlURL];
                [account setProviderName:appMetadata.provider];
                [MAAccountManager saveAccounts];
            }
        }
        else {
            NSLog(@"transporter unsuccessful: %@", error);
        }
    }];
    
    NSLog(@"End of retrieve metadata method");
}

- (void)validatePackage
{
    NSLog(@"Validate Package");
    
    NSAlert *alert = [NSAlert alertWithMessageText: @"Select Account"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSComboBox *accountComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(0, 32, 300, 24)];
    [accountComboBox setUsesDataSource:NO];
    [accountComboBox addItemsWithObjectValues:[MAAccountManager allUsernames]];
    
    [alert setAccessoryView:accountComboBox];
    NSInteger button = [alert runModal];
    if (button != NSAlertDefaultReturn) {
        return;
    }
    
    NSString *username = (NSString *)[accountComboBox objectValueOfSelectedItem];
    MAiTunesConnectAccount *account = [MAAccountManager accountWithUsername:username];
    
    NSOpenPanel* dlg =[NSOpenPanel openPanel];
    [dlg setTitle:@"Select an iTMS package"];
    [dlg setCanChooseFiles:YES];
    [dlg setAllowsMultipleSelection:NO];
    [dlg setCanChooseDirectories:NO];
    
    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"itmsp", @"ITMSP", nil];
    [dlg setAllowedFileTypes:fileTypes];
    
    button = [dlg runModal];
    if (button == NSFileHandlingPanelOKButton){
        NSURL *chosenURL = [[dlg URLs] objectAtIndex:0];
        NSString *packagePath = [chosenURL path];
        
        [[MATransporter sharedTransporter] verifyPackage:packagePath forAccount:account completion:^(BOOL success, NSDictionary *info, NSError *error) {
            if (success) {
                NSLog(@"Success! Info:\n%@", info);
            }
            else {
                if ([error isEqual:[NSError MATransporterWrongProviderError]] && !account.providerName) {
                    NSLog(@"Chance to get provider name for account");
                }
                
                NSLog(@"Unsuccessful with error:\n%@\ninfo:\n%@", error, info);
            }
        }];
    }
}

- (void)submitPackage
{
    NSLog(@"Submit Package");
    
    NSAlert *alert = [NSAlert alertWithMessageText: @"Select Account"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSComboBox *accountComboBox = [[NSComboBox alloc] initWithFrame:NSMakeRect(0, 32, 300, 24)];
    [accountComboBox setUsesDataSource:NO];
    [accountComboBox addItemsWithObjectValues:[MAAccountManager allUsernames]];
    
    [alert setAccessoryView:accountComboBox];
    NSInteger button = [alert runModal];
    if (button != NSAlertDefaultReturn) {
        return;
    }
    
    NSString *username = (NSString *)[accountComboBox objectValueOfSelectedItem];
    MAiTunesConnectAccount *account = [MAAccountManager accountWithUsername:username];
    
    NSOpenPanel* dlg =[NSOpenPanel openPanel];
    [dlg setTitle:@"Select an iTMS package"];
    [dlg setCanChooseFiles:YES];
    [dlg setAllowsMultipleSelection:NO];
    [dlg setCanChooseDirectories:NO];
    
    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"itmsp", @"ITMSP", nil];
    [dlg setAllowedFileTypes:fileTypes];
    
    button = [dlg runModal];
    if (button == NSFileHandlingPanelOKButton){
        NSURL *chosenURL = [[dlg URLs] objectAtIndex:0];
        NSString *packagePath = [chosenURL path];
        
        [[MATransporter sharedTransporter] uploadPackage:packagePath forAccount:account completion:^(BOOL success, NSDictionary *info, NSError *error) {
            if (success) {
                NSLog(@"Success! Info:\n%@", info);
            }
            else {
                NSLog(@"Unsuccessful with error:\n%@", error);
            }
        }];
    }
}

@end

