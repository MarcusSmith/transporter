//
//  MainViewController.m
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import "MainViewController.h"
#import "AppMetadata.h"
#import "iTunesConnectManager.h"

@interface MainViewController ()

@property (nonatomic, strong) NSButton *button;

@end

@implementation MainViewController

- (id)initWithSize:(NSSize)size
{
    self = [super init];
    
    if (self) {
        // Create a view
        NSView *view = [[NSView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        CALayer *viewLayer = [CALayer layer];
        [viewLayer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 1.0, 1.0)];
        [view setWantsLayer:YES];
        [view setLayer:viewLayer];
        
        [view addSubview:self.button];
        
        [self.button setFrame:NSMakeRect((size.width / 2) - 100.0, (size.height / 2) - 40.0, 200.0, 80.0)];
        
        [self setView:view];
    }
    
    return self;
}

- (void)buttonClicked
{
    NSOpenPanel* dlg =[NSOpenPanel openPanel];
    [dlg setCanChooseFiles:YES];
    [dlg setCanChooseDirectories:NO];
    
    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"itmsp", @"ITMSP", nil];
    [dlg setAllowedFileTypes:fileTypes];
    
    NSInteger button = [dlg runModal];
    if (button == NSFileHandlingPanelOKButton){
        NSURL *chosenURL = [[dlg URLs] objectAtIndex:0];
        NSLog(@"Path: %@", [chosenURL path]);
        NSURL *xmlURL = [chosenURL URLByAppendingPathComponent:@"metadata.xml"];
        
        AppMetadata *testMetadata = [[AppMetadata alloc] initWithXML:xmlURL];
        Version *aVersion = [[testMetadata versions] objectAtIndex:0];
        Locale *aLocale = [[aVersion locales] objectAtIndex:0];
        NSMutableArray *keywords = aLocale.keywords.mutableCopy;
        NSString *testKeyword = @"tst";
        [keywords insertObject:testKeyword atIndex:2];
        [keywords removeObjectAtIndex:1];
        [aLocale setKeywords:keywords.copy];
        
        NSXMLDocument *document = testMetadata.NSXMLDocumentRepresentation;
        NSData *xmlData = [document XMLDataWithOptions:NSXMLNodePrettyPrint];
        
        NSString *path = [@"~/Desktop/test.itmsp" stringByExpandingTildeInPath];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        
        [xmlData writeToFile:[path stringByAppendingPathComponent:@"metadata.xml"] atomically:YES];
        
        iTunesConnectManager *manager = [[iTunesConnectManager alloc] init];
        
        [manager getListOfAllApps];
        
//        [manager verifyPackage:path];
    }
    
    
}

#pragma mark - properties

- (NSButton *)button
{
    if (!_button) {
        _button = [[NSButton alloc] init];
        [_button setTitle:@"Get XML file"];
        [_button setAction:@selector(buttonClicked)];
        [_button setTarget:self];
    }
    
    return _button;
}

@end
