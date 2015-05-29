//
//  ViewController.m
//  PKTExtensionHostAppHelperSample
//
//  Created by Michael Schneider on 9/14/14.
//  Copyright (c) 2014 Read It Later Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify,
//  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
//  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ViewController.h"
#import "PKTExtensionHostAppHelper.h"

static NSString *encodeString(NSString *string)
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$&'()*+,;=\""), kCFStringEncodingUTF8));
}

@interface ViewController () <UIActivityItemSource>
@property (strong, nonatomic) NSURL *urlToShare;
@property (copy, nonatomic) NSString *tweetId;
@property (strong, nonatomic) UIActivityViewController *activityViewController;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Some stuff to share
    self.urlToShare = [NSURL URLWithString:@"http://www.hodinkee.com/blog/hodinkee-apple-watch-review"];
    self.tweetId = @"512211932431261696";
}

- (IBAction)openActivityViewController:(id)sender
{
    // Add self (or any other object that conforms to the UIActivityItemSource Protocol) in the
    // initializer and implement the UIActivityItemSource Protocol
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
    
    // Pre iOS 8
    /*self.activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {

    };*/
    
    // Starting iOS 8
    self.activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
        
    };
    
    // Show the activity view controller
    [self presentViewController:self.activityViewController animated:YES completion:nil];
}


#pragma mark - UIActivityItemSource Protocol

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return self.urlToShare;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    // Create special url for Pocket that will be passed to the extension
    if ([PKTExtensionHostAppHelper canUseHelperForActivityType:activityType]) {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        // User PKTExtensionHostAppHelper. Look into the header of the PKTExtensionHostAppHelper for more predefined parameter keys
        NSDictionary *parameters = @{PKTExtensionHostAppHelperParameterTweetId : self.tweetId};
        NSURL *urlForExtension = [PKTExtensionHostAppHelper extensionURLForHostApp:bundleIdentifier originalURL:self.urlToShare parameters:parameters];
        
        // Use plain url
        //NSURL *urlForExtension = [NSURL URLWithString:[NSString stringWithFormat:@"%@://extensionsave?tweet_id=123456&url=%@", bundleIdentifier, encodeString(self.urlToShare.absoluteString)]];

        return urlForExtension;
    }
    
    return self.urlToShare;
}

@end
