//
//  BSQArchive.h
//  QuickLookBSQ
//
//  Created by mark lim on 10/6/17.
//  Copyright 2017 IncrementalInnovation.com All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FileWrapper;

@interface BSQArchive : NSObject {
	FileWrapper *fileWrapper;
}

@property (retain) FileWrapper *fileWrapper;

- (id) initWithURL:(NSURL *)url;
- (NSString *) fileName;
- (NSDictionary *) attributes;

@end
