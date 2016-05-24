//
//  IconDownloader.h
//  SampleLoadingApp
//
//  Created by Anand on 24/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppRecord.h"

@interface IconDownloader : NSObject

@property (nonatomic, strong) AppRecord *appRecord;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload;
- (void)cancelDownload;

@end
