//
//  PKTExtensionHostAppHelperSampleTests.m
//  PKTExtensionHostAppHelperSampleTests
//
//  Created by Michael Schneider on 9/14/14.
//  Copyright (c) 2014 Read It Later Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PKTExtensionHostAppHelper.h"

#pragma mark - Helper Categories

@interface NSString (PKTExtensionHostAppHelperSampleTests)
- (NSString *)stringByEscapingForURLQuery;
@end

@implementation NSString (PKTExtensionHostAppHelperSampleTests)

#pragma mark - URL Escaping and Unescaping

- (NSString *)stringByEscapingForURLQuery
{
	NSString *result = self;

	static CFStringRef leaveAlone = CFSTR(" ");
	static CFStringRef toEscape = CFSTR("\n\r:/=,!$&'()*+;[]@#?%");

	CFStringRef escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, leaveAlone,
																	 toEscape, kCFStringEncodingUTF8);

	if (escapedStr) {
		NSMutableString *mutable = [NSMutableString stringWithString:(__bridge NSString *)escapedStr];
		CFRelease(escapedStr);

		[mutable replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutable length])];
		result = mutable;
	}
	return result;
}

@end

@interface PKTExtensionHostAppHelperSampleTests : XCTestCase
@property (strong, nonatomic) NSURL *urlToShare;
@property (strong, nonatomic) NSURL *extensionHostAppURL;
@property (strong, nonatomic) NSString *hostAppName;
@property (strong, nonatomic) NSString *tweetId;
@end

@implementation PKTExtensionHostAppHelperSampleTests

- (void)setUp
{
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.urlToShare = [NSURL URLWithString:@"http://www.hodinkee.com/blog/hodinkee-apple-watch-review"];
    self.extensionHostAppURL = [NSURL URLWithString:@"com.ideashower.ReadItLaterPro3://extensionsave?tweet_id=123456&url=http%3A%2F%2Fwww.hodinkee.com%2Fblog%2Fhodinkee-apple-watch-review"];

    self.hostAppName = @"com.ideashower.ReadItLaterPro";
    self.tweetId = @"123456";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCheckIfCanUseExtensionHostAppHelperu
{
    BOOL canUseAppHelper = [PKTExtensionHostAppHelper canUseHelperForActivityType:PKTExtensionActivityType];
    XCTAssertTrue(canUseAppHelper);

    canUseAppHelper = [PKTExtensionHostAppHelper canUseHelperForActivityType:UIActivityTypePostToTwitter];
    XCTAssertFalse(canUseAppHelper);
}

- (void)testCreatingExtensionHostAppURL
{
    NSString *tweetIdParameter = [NSString stringWithFormat:@"tweet_id=%@", self.tweetId];
    NSString *urlParameter = [NSString stringWithFormat:@"url=%@", [self.urlToShare.absoluteString stringByEscapingForURLQuery]];

    NSDictionary *parameters = @{PKTExtensionHostAppHelperParameterTweetId : self.tweetId};
    NSURL *extensionURL = [PKTExtensionHostAppHelper extensionURLForHostApp:self.hostAppName originalURL:self.urlToShare parameters:parameters];
    XCTAssertEqualObjects(extensionURL.scheme, self.hostAppName);
    XCTAssertTrue([extensionURL.absoluteString rangeOfString:tweetIdParameter].location != NSNotFound);
    XCTAssertTrue([extensionURL.absoluteString rangeOfString:urlParameter].location != NSNotFound);

    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    mutableParameters[PKTExtensionHostAppHelperParameterURL] = self.urlToShare.absoluteString;
    extensionURL = [PKTExtensionHostAppHelper extensionURLForHostApp:self.hostAppName parameters:mutableParameters];
    XCTAssertEqualObjects(extensionURL.scheme, self.hostAppName);
    XCTAssertTrue([extensionURL.absoluteString rangeOfString:tweetIdParameter].location != NSNotFound);
    XCTAssertTrue([extensionURL.absoluteString rangeOfString:urlParameter].location != NSNotFound);

    extensionURL = [PKTExtensionHostAppHelper extensionURLForHostApp:nil originalURL :self.urlToShare parameters:nil];
    XCTAssertNil(extensionURL);
}

- (void)testCheckIfURLIsExtensionHostAppURL
{
    BOOL isExtensionHostAppURL = [PKTExtensionHostAppHelper URLIsExtensionHostAppURL:self.extensionHostAppURL];
    XCTAssertTrue(isExtensionHostAppURL);

    isExtensionHostAppURL = [PKTExtensionHostAppHelper URLIsExtensionHostAppURL:self.urlToShare];
    XCTAssertFalse(isExtensionHostAppURL);
}

- (void)testParsingExtensionHostAppURL
{
    NSDictionary *extensionData = [PKTExtensionHostAppHelper extensionDataFromHostAppURL:self.extensionHostAppURL];
    XCTAssertEqualObjects(extensionData[PKTExtensionHostAppHelperParameterAppName], self.hostAppName);
    XCTAssertEqualObjects(extensionData[PKTExtensionHostAppHelperParameterURL], self.urlToShare.absoluteString);
    XCTAssertEqualObjects(extensionData[PKTExtensionHostAppHelperParameterTweetId], self.tweetId);

    extensionData = [PKTExtensionHostAppHelper extensionDataFromHostAppURL:self.urlToShare];
    XCTAssertNil(extensionData);
}

@end
