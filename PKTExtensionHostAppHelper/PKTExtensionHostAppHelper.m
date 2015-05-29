//
//  PKTExtensionHostAppHelper.m
//  PKTExtensionHostAppHelper
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

#import "PKTExtensionHostAppHelper.h"

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC, add -fobjc-arc to its compiler flags in the Compile Sources build phase.
#endif

NSString * const PKTExtensionActivityType = @"com.ideashower.ReadItLaterPro.AddToPocketExtension";
NSString * const PKTExtensionHostAppHelperParameterAppName = @"app_name";
NSString * const PKTExtensionHostAppHelperParameterURL = @"url";
NSString * const PKTExtensionHostAppHelperParameterTweetId = @"tweet_id";
NSString * const PKTExtensionHostAppHelperParameterAttributionDetail = @"attribution_detail";

static NSString *PKTExtensionHostAppHelperURLHost = @"extensionsave";


#pragma mark - Helper Categories

@interface NSString (PKTExtensionHostAppHelper)
- (NSString *)stringByEscapingForURLQuery;
- (NSString *)stringByUnescapingFromURLQuery;
@end

@implementation NSString (PKTExtensionHostAppHelper)

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


- (NSString *)stringByUnescapingFromURLQuery
{
	NSString *deplussed = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [deplussed stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end


@interface NSDictionary (PKTExtensionHostAppHelper)
+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString;
- (NSString *)stringWithFormEncodedComponents;
@end

@implementation NSDictionary (PKTExtensionHostAppHelper)

+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString
{
	if (!encodedString) {
		return nil;
	}
	
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSArray *pairs = [encodedString componentsSeparatedByString:@"&"];
	
	for (NSString *kvp in pairs) {
		if ([kvp length] == 0) {
			continue;
		}
		
		NSRange pos = [kvp rangeOfString:@"="];
		NSString *key;
		NSString *val;
		
		if (pos.location == NSNotFound) {
			key = [kvp stringByUnescapingFromURLQuery];
			val = @"";
		} else {
			key = [[kvp substringToIndex:pos.location] stringByUnescapingFromURLQuery];
			val = [[kvp substringFromIndex:pos.location + pos.length] stringByUnescapingFromURLQuery];
		}
		
		if (!key || !val) {
			continue; // I'm sure this will bite my arse one day
		}
		
		[result setObject:val forKey:key];
	}
	return result;
}


- (NSString *)stringWithFormEncodedComponents
{
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:[self count]];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		[arguments addObject:[NSString stringWithFormat:@"%@=%@",
							  [key stringByEscapingForURLQuery],
							  [[object description] stringByEscapingForURLQuery]]];
	}];
	
	return [arguments componentsJoinedByString:@"&"];
}

@end


#pragma mark - PKTExtensionHostAppHelper

@implementation PKTExtensionHostAppHelper

#pragma mark - Convert original URL to share to Extension host app URL

+ (BOOL)canUseHelperForActivityType:(NSString *)activityType
{
    return [activityType isEqualToString:PKTExtensionActivityType];
}

+ (NSURL *)extensionURLForHostApp:(NSString *)hostAppName originalURL:(NSURL *)url parameters:(NSDictionary *)parameters
{
    // URL needs to be provided
    if (url == nil) { return nil; }
    
    // Add the url to the parameters
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    mutableParameters[PKTExtensionHostAppHelperParameterURL] = url.absoluteString;
    return [self extensionURLForHostApp:hostAppName parameters:mutableParameters];
}


#pragma mark - Convert Extension host app URL to original URL to share

+ (NSURL *)extensionURLForHostApp:(NSString *)hostAppName parameters:(NSDictionary *)parameters
{
    // At leat host app name needs to be provided
    if (hostAppName == nil) { return nil; }

    // Create Extension host app URL
    NSString *urlString = [NSString stringWithFormat:@"%@://%@?%@", hostAppName, PKTExtensionHostAppHelperURLHost, [parameters stringWithFormEncodedComponents]];
    return [NSURL URLWithString:urlString];
}

+ (BOOL)URLIsExtensionHostAppURL:(NSURL *)url
{
    // URL needs to be provided
    if (url == nil) { return NO; }

    // The url scheme should identify a host app
    NSString *urlScheme = url.scheme;
    NSString *urlString = url.absoluteString;
    if (urlScheme == nil ||
        [urlScheme isEqualToString:@"http"] || [urlScheme isEqualToString:@"https"] ||
        [urlScheme isEqualToString:@"file"] || [urlScheme isEqualToString:@"ftp"] ||
        [urlString rangeOfString:@"url="].location == NSNotFound)
    {
        return NO;
    }
    
    return YES;
}

+ (NSDictionary *)extensionDataFromHostAppURL:(NSURL *)url
{
    if (![self URLIsExtensionHostAppURL:url]) { return nil; }

    NSString *appName = url.scheme;

    NSMutableDictionary *extensionData = [[NSDictionary dictionaryWithFormEncodedString:url.query] mutableCopy];
    extensionData[PKTExtensionHostAppHelperParameterAppName] = appName;
    return extensionData;
}

@end
