//
//  AppDelegate.m
//  SampleLoadingApp
//
//  Created by Anand on 24/05/16.
//  Copyright © 2016 Test. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AppRecord.h"

// the http URL used for fetching the top iOS paid apps on the App Store
static NSString *const TopPaidAppsFeed = @"https://dl.dropboxusercontent.com/u/746330/facts.json";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:TopPaidAppsFeed]];
    
    // create an session data task to obtain and the XML feed
    NSURLSessionDataTask *sessionTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                            // in case we want to know the response status code
                                                                            //NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
                                                                            
                                                                            __weak AppDelegate *weakSelf = self;

                                                                            
                                                                            if (error != nil)
                                                                            {
                                                                                [[NSOperationQueue mainQueue] addOperationWithBlock: ^{
                                                                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                                    
                                                                                    if ([error code] == NSURLErrorAppTransportSecurityRequiresSecureConnection)
                                                                                    {
                                                                                        // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
                                                                                        // then your Info.plist has not been properly configured to match the target server.
                                                                                        //
                                                                                        abort();
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        [self handleError:error];
                                                                                    }
                                                                                }];
                                                                            }
                                                                            else
                                                                            {
                                                                                NSString * myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                                                                                
                                                                                NSData *data1 = [myString dataUsingEncoding:NSUTF8StringEncoding];
                                                                                
                                                                                if (!error)
                                                                                {
                                                                                    NSError *JSONError = nil;
                                                                                    
                                                                                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data1
                                                                                                                                               options:0
                                                                                                                                                 error:&JSONError];
                                                                                    if (JSONError)
                                                                                    {
                                                                                        NSLog(@"Serialization error: %@", JSONError.localizedDescription);
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        NSLog(@"Response: %@", dictionary);
                                                                                        NSArray *arr = [dictionary objectForKey:@"rows"];
                                                                                        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
                                                                                        
                                                                                        for(int i=0;i<[arr count];i++){
                                                                                            NSDictionary *productData = [arr objectAtIndex:i];
                                                                                            AppRecord *dataEntry = [[AppRecord alloc] init];
                                                                                            dataEntry.imageURLString = [productData objectForKey:@"imageHref"];
                                                                                            dataEntry.title = [productData objectForKey:@"title"];
                                                                                            dataEntry.descriptionData = [productData objectForKey:@"description"];
                                                                                            NSString *description = [productData objectForKey:@"description"];
                                                                                            NSString *imageUrlStr = [productData objectForKey:@"imageHref"];
                                                                                            if(description != (NSString *)[NSNull null] && imageUrlStr != (NSString *)[NSNull null]){
                                                                                                   [dataArray addObject:dataEntry];
                                                                                            }
                                                                                        }
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            
                                                                                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                                                                                            ViewController *rootViewController =
                                                                                            (ViewController*)[(UINavigationController*)weakSelf.window.rootViewController topViewController];
                                                                                            
                                                                                            
                                                                                            rootViewController.entries = dataArray;
                                                                                            
                                                                                            // tell our table view to reload its data, now that parsing has completed
                                                                                            [rootViewController.dataTableview reloadData];

                                                                                        });
                                                                                    }
                                                                                }
                                                                                else
                                                                                {
                                                                                    NSLog(@"Error: %@", error.localizedDescription);
                                                                                }
                                                                            }
                                                                        }];
    
    [sessionTask resume];
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    
    // alert user that our current record was deleted, and then we leave this view controller
    //
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Show Data"
                                                                   message:errorMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         // dissmissal of alert completed
                                                     }];
    
    [alert addAction:OKAction];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}


@end
