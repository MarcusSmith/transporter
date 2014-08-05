//
//  MAVersion.h
//  transporter
//
//  Created by Marcus Smith on 7/25/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MALocale.h"

@interface MAVersion : NSObject

@property (nonatomic, strong) NSString *versionString;
@property (nonatomic, strong) NSArray *locales;

- (void)addLocale:(MALocale *)locale;
- (NSXMLElement *)NSXMLElementRepresentation;

@end
