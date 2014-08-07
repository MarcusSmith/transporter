//
//  MAVersionViewController.m
//  transporter
//
//  Created by Austin Younts on 8/1/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MALocaleViewController.h"

#import "MALabel.h"
#import "MATextField.h"

#import "Locale.h"

#import "MAScreenshotsViewController.h"

@interface MALocaleViewController ()

@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSView *documentView;

@property (nonatomic, strong) MALabel *labelForTitle;
@property (nonatomic, strong) MALabel *labelForLocalDescription;
@property (nonatomic, strong) MALabel *labelForWhatsNew;
@property (nonatomic, strong) MALabel *labelForSoftwareURL;
@property (nonatomic, strong) MALabel *labelForPrivacyURL;
@property (nonatomic, strong) MALabel *labelForSupportURL;

@property (nonatomic, strong) MATextField *textFieldForTitle;
@property (nonatomic, strong) MATextField *textFieldForLocalDescription;
@property (nonatomic, strong) MATextField *textFieldForWhatsNew;
@property (nonatomic, strong) MATextField *textFieldForSoftwareURL;
@property (nonatomic, strong) MATextField *textFieldForPrivacyURL;
@property (nonatomic, strong) MATextField *textFieldForSupportURL;

@property (nonatomic, strong) MAScreenshotsViewController *screenshotController;
@property (nonatomic, strong) NSView *containerForScreenshotController;

@end

@implementation MALocaleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
#pragma mark - Autolayout
    NSDictionary *views = @{@"scrollView" : self.scrollView, @"documentView" : self.documentView, @"titleL" : self.labelForTitle, @"localDescriptionL" : self.labelForLocalDescription, @"whatsNewL" : self.labelForWhatsNew, @"softwareURLL" : self.labelForSoftwareURL, @"privacyURLL" : self.labelForPrivacyURL, @"supportURLL" : self.labelForSupportURL, @"titleT" : self.textFieldForTitle, @"localDescriptionT" : self.textFieldForLocalDescription, @"whatsNewT" : self.textFieldForWhatsNew, @"softwareURLT" : self.textFieldForSoftwareURL, @"privacyURLT" : self.textFieldForPrivacyURL, @"supportURLT" : self.textFieldForSupportURL, @"screenshots" : self.containerForScreenshotController};
    
    [self.view addConstraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:views];
    [self.view addConstraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:views];
    
    
    NSString *lh = @"22";   // Label Height
    NSString *slfh = @"22"; // Single Line Field Height
    NSString *ltp = @"2";   // Label-TextField Padding
    NSString *gp = @"20";   // Group Padding
    
    
    NSString *verticalFormatString = [NSString stringWithFormat:@"V:|-10-[titleL(==%@)]-%@-[titleT(==%@)]-%@-[localDescriptionL(==%@)]-%@-[localDescriptionT(==300)]-%@-[whatsNewL(==%@)]-%@-[whatsNewT(==150)]-%@-[softwareURLL(==%@)]-%@-[softwareURLT(==%@)]-%@-[privacyURLL(==%@)]-%@-[privacyURLT(==%@)]-%@-[supportURLL(==%@)]-%@-[supportURLT(==%@)]-20-[screenshots]-20-|", lh, ltp, slfh, gp, lh, ltp, gp, lh, ltp, gp, lh, ltp, slfh, gp, lh, ltp, slfh, gp, lh, ltp, slfh];
    [self.documentView addConstraintsWithVisualFormat:verticalFormatString
                                              options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                              metrics:nil views:views];
    
    
    [self.scrollView addCompactConstraints:@[@"documentView.left == localDescriptionT.left", @"documentView.right == localDescriptionT.right"] metrics:nil views:views];
    [self.scrollView addCompactConstraints:@[@"scrollView.left == documentView.left", @"scrollView.right == documentView.right", @"scrollView.top == documentView.top"] metrics:nil views:views];
    
    [self.view layoutSubtreeIfNeeded];
    
    return self;
}

- (void)loadView
{
    self.view = [[NSView alloc] initWithFrame:CGRectZero];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}

#pragma mark - Visual Control
- (void)scrollToBeginningOfDocument:(id)sender
{
    NSRect frame = [self.scrollView.documentView frame];
    CGFloat y = NSMinY(frame);
    y = ABS(y);
    [self.scrollView.documentView scrollPoint:NSMakePoint(0.0, y)];
}

- (void)scrollToEndOfDocument:(id)sender
{
    
}

#pragma mark - Accessors
- (void)setLocale:(Locale *)locale
{
    _locale = locale;

    [self.textFieldForTitle bind:@"stringValue" toObject:locale withKeyPath:@"title" options:nil];
    [self.textFieldForLocalDescription bind:@"stringValue" toObject:locale withKeyPath:@"localDescription" options:nil];
    [self.textFieldForWhatsNew bind:@"stringValue" toObject:locale withKeyPath:@"whatsNew" options:nil];
    [self.textFieldForSoftwareURL bind:@"stringValue" toObject:locale withKeyPath:@"softwareURL" options:nil];
    [self.textFieldForPrivacyURL bind:@"stringValue" toObject:locale withKeyPath:@"privacyURL" options:nil];
    [self.textFieldForSupportURL bind:@"stringValue" toObject:locale withKeyPath:@"supportURL" options:nil];
}

#pragma mark - Views
#pragma mark -- Labels

- (MALabel *)labelForTitle {
    if (!_labelForTitle) {
        _labelForTitle = [self newLabel];
        _labelForTitle.stringValue = @"App Title:";
    }
    return _labelForTitle;
}

- (MALabel *)labelForLocalDescription {
    if (!_labelForLocalDescription) {
        _labelForLocalDescription = [self newLabel];
        _labelForLocalDescription.stringValue = @"Description";
    }
    return _labelForLocalDescription;
}

- (MALabel *)labelForWhatsNew {
    if (!_labelForWhatsNew) {
        _labelForWhatsNew = [self newLabel];
        _labelForWhatsNew.stringValue = @"What's New";
    }
    return _labelForWhatsNew;
}

- (MALabel *)labelForSoftwareURL {
    if (!_labelForSoftwareURL) {
        _labelForSoftwareURL = [self newLabel];
        _labelForSoftwareURL.stringValue = @"Software URL:";
    }
    return _labelForSoftwareURL;
}

- (MALabel *)labelForPrivacyURL {
    if (!_labelForPrivacyURL) {
        _labelForPrivacyURL = [self newLabel];
        _labelForPrivacyURL.stringValue = @"Privacy URL:";
    }
    return _labelForPrivacyURL;
}

- (MALabel *)labelForSupportURL {
    if (!_labelForSupportURL) {
        _labelForSupportURL = [self newLabel];
        _labelForSupportURL.stringValue = @"Support URL:";
    }
    return _labelForSupportURL;
}

-(MALabel *)newLabel {
    MALabel *label = [[MALabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.documentView addSubview:label];
    return label;
}

#pragma mark -- TextFields

- (MATextField *)textFieldForTitle {
    if (!_textFieldForTitle) _textFieldForTitle = [self newTextField];
    return _textFieldForTitle;
}

- (MATextField *)textFieldForLocalDescription {
    if (!_textFieldForLocalDescription) _textFieldForLocalDescription = [self newTextField];
    return _textFieldForLocalDescription;
}

- (MATextField *)textFieldForWhatsNew {
    if (!_textFieldForWhatsNew) _textFieldForWhatsNew = [self newTextField];
    return _textFieldForWhatsNew;
}

- (MATextField *)textFieldForSoftwareURL {
    if (!_textFieldForSoftwareURL) _textFieldForSoftwareURL = [self newTextField];
    return _textFieldForSoftwareURL;
}

- (MATextField *)textFieldForPrivacyURL {
    if (!_textFieldForPrivacyURL) _textFieldForPrivacyURL = [self newTextField];
    return _textFieldForPrivacyURL;
}

- (MATextField *)textFieldForSupportURL {
    if (!_textFieldForSupportURL) _textFieldForSupportURL = [self newTextField];
    return _textFieldForSupportURL;
}

- (MATextField *)newTextField {
    MATextField *textField = [[MATextField alloc] initWithFrame:CGRectZero];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.documentView addSubview:textField];
    return textField;
}

#pragma mark -- Other
- (NSView *)containerForScreenshotController
{
    if (!_containerForScreenshotController) {
        _containerForScreenshotController = [[NSView alloc] initWithFrame:CGRectZero];
        _containerForScreenshotController.translatesAutoresizingMaskIntoConstraints = NO;
        [self.documentView addSubview:_containerForScreenshotController];
    }
    return _containerForScreenshotController;
}

- (NSScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[NSScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSView *)documentView
{
    if (!_documentView) {
        _documentView = [[NSView alloc] initWithFrame:CGRectZero];
        _documentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.scrollView.documentView = _documentView;
    }
    return _documentView;
}

@end
