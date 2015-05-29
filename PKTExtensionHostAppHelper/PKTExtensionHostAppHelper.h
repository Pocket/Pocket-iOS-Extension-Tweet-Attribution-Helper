//
//  PKTExtensionHostAppHelper.h
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

#import <Foundation/Foundation.h>

extern NSString * const PKTExtensionActivityType;
extern NSString * const PKTExtensionHostAppHelperParameterAppName;
extern NSString * const PKTExtensionHostAppHelperParameterURL;
extern NSString * const PKTExtensionHostAppHelperParameterTweetId;
extern NSString * const PKTExtensionHostAppHelperParameterAttributionDetail;

@interface PKTExtensionHostAppHelper : NSObject

/// Returns a Boolean indicating whether the the helper is able to handle the activityType
+ (BOOL)canUseHelperForActivityType:(NSString *)activityType;

/**
 *  Creates URL to hand over to the Pocket extension. Example: com.ideashower.ReadItLaterPro3://extensionsave?tweet_id=123456789&url=http://google.com
 *
 *  @param hostAppName App name of the host app
 *  @param originalURL         URL to be shared
 *  @param parameters  Further parameters to send to the Pocket extension
 *
 *  @return URL to hand over to the Pocket extension
 */
+ (NSURL *)extensionURLForHostApp:(NSString *)hostAppName originalURL:(NSURL *)url parameters:(NSDictionary *)parameters;

/**
 *  Creates URL to hand over to the Pocket extension. Example: com.ideashower.ReadItLaterPro3://extensionsave?tweet_id=123456789&url=http://google.com
 *
 *  @param hostAppName App name of the host app
 *  @param parameters  Parameters to send to the Pocket extension
 *
 *  @return URL to hand over to the Pocket extension
 */
+ (NSURL *)extensionURLForHostApp:(NSString *)hostAppName parameters:(NSDictionary *)parameters;

/// Returns a Boolean indicating whether the given URL is a extension host app URL
+ (BOOL)URLIsExtensionHostAppURL:(NSURL *)url;

/// Returns the parsed extension data from the given host app URL
+ (NSDictionary *)extensionDataFromHostAppURL:(NSURL *)url;

@end
