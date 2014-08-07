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

@interface AppDelegate ()

@property (nonatomic, strong) NSDocumentController *documentController;

@end

@implementation AppDelegate

@dynamic documentController;



-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [self documentController];
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    
    NSMenuItem *testMenu = [[NSMenuItem alloc] initWithTitle:@"Test Menu" action:nil keyEquivalent:@""];
    
    NSMenu *testSubmenu = [[NSMenu alloc] initWithTitle:@"Tests"];
    
    [testMenu setSubmenu:testSubmenu];
    
    NSMenuItem *accountItem = [[NSMenuItem alloc] initWithTitle:@"Accounts" action:nil keyEquivalent:@""];
    
    NSMenu *accountSubmenu = [[NSMenu alloc] init];
    
    [accountItem setSubmenu:accountSubmenu];
    
    NSMenuItem *addAccountItem = [[NSMenuItem alloc] initWithTitle:@"Add Account" action:@selector(addAccount) keyEquivalent:@""];
    
    [accountSubmenu addItem:addAccountItem];
    
    NSMenuItem *checkAccountItem = [[NSMenuItem alloc] initWithTitle:@"Check Account" action:@selector(checkAccount) keyEquivalent:@""];
    
    [accountSubmenu addItem:checkAccountItem];
    
    NSMenuItem *removeAccountItem = [[NSMenuItem alloc] initWithTitle:@"Remove Account" action:@selector(removeAccount) keyEquivalent:@""];
    
    [accountSubmenu addItem:removeAccountItem];
    
    NSMenuItem *allAccountsItem = [[NSMenuItem alloc] initWithTitle:@"All Accounts" action:@selector(listAllAccounts) keyEquivalent:@""];
    
    [accountSubmenu addItem:allAccountsItem];
    
    NSMenuItem *removeAllAccountsItem = [[NSMenuItem alloc] initWithTitle:@"Remove All Accounts" action:@selector(removeAllAccounts) keyEquivalent:@""];
    
    [accountSubmenu addItem:removeAllAccountsItem];
    
    [testSubmenu addItem:accountItem];
    
    [mainMenu insertItem:testMenu atIndex:2];
}

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
//    BOOL success = [MAKeychain storePassword:[passwordInput stringValue] forUser:[usernameInput stringValue] error:&error];
    
    NSLog(@"Password input: %@", [passwordInput stringValue]);
    
    MAiTunesConnectAccount *newAccount = [MAiTunesConnectAccount accountWithUsername:[usernameInput stringValue]];
    
    NSLog(@"Added account with password: %@", newAccount.password);
    
    [MAAccountManager addAccount:newAccount];
    
    BOOL success = [newAccount setPassword:[passwordInput stringValue] error:&error];

    NSLog(@"Save %@, error: %@", success ? @"successful" : @"unsuccessful", error);
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
//    NSLog(@"username: %@, password: %@", username, [MAKeychain passwordForUser:username error:nil]);
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
    
//    NSError *error;
//    BOOL success = [MAKeychain clearPasswordForUser:username error:&error];
    
    NSLog(@"Remove Account %@", success ? @"successful" : @"unsuccessful");
}

#pragma mark - Accessors
- (NSDocumentController *)documentController
{
    return [NSDocumentController sharedDocumentController];
}


@end

