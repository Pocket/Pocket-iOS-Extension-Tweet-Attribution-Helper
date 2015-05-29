## Sending Tweet Attribution via Pocket iOS Extension

### What to use this for

Tweet Attribution is a feature inside of Pocket that enables attaching the original tweet to a saved link from Twitter. For a Twitter application that includes the ability to save to Pocket, it's a critical feature.

This helper code allows you to pass tweet attribution to Pocket's API even when a user saves with through the native iOS share sheet and Pocket's share extension.

### How to pass tweet attribution to Pocket through the extension

For a working example of this implementation, see the Sample app included in this repo. Specifically you can see the implementation in the sample ViewController:
https://github.com/Pocket/iOS-Extension-Host-App-Helper/blob/master/Sample/PKTExtensionHostAppHelperSample/ViewController.m

**1. Use a delegate when initializing your UIActivityViewController**


If you already use a delegate, you can skip to step 2.

Instead of passing a NSURL or NSString in the UIActivityViewController init method: _initWithActivityItems:applicationActivities:_ update your host app to pass in one (or multiple) objects that conforms to the UIActivityItemSource protocol.

So creating your UIActivityViewController would look something like:

```objective-c
var controller = [[UIActivityViewController alloc] initWithActivityItems:@[self] applicationActivities:nil];
```

Where _self_ in this example is a delegate that conforms to UIActivityItemSource.

In your delegate, you'll want to add two methods to conform to the protocal:

```objective-c
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	/* return the NSURL to share. For example, if you have the url captured in a variable:
	return self._urlToShare;
	*/
}
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	/* return the NSURL to share. For example, if you have the url captured in a variable:
	return self._urlToShare;
	*/
}
```

**2. Include the Pocket Helper Code on Your Delegate**


At the top of your .m file for your delegate, include Pocket's helper class:
```objective-c
#import "PKTExtensionHostAppHelper.h"
```

**3. Update your delegate method to pass the attribution when sharing to Pocket**

Inside of your _activityViewController:itemForActivityType:_ delegate method, you'll want include the code below. This code will use the Pocket helper to add the tweet attribution to the share for Pocket

In the example below, the url that is trying to be shared to extensions is stored in _self.urlToShare_.

```objective-c
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{

	// When sharing to Pocket, pass a special url for Pocket that will be passed to the extension
    if ([PKTExtensionHostAppHelper canUseHelperForActivityType:activityType]) {
		
		NSURL *urlToShareToPocket = self.urlToShare;
		NSString *tweetId = @"123456789"; // The Twitter status id of the tweet where the link came from
		
        // User PKTExtensionHostAppHelper. Look into the header of the PKTExtensionHostAppHelper for more predefined parameter keys
        NSDictionary *parameters = @{PKTExtensionHostAppHelperParameterTweetId : tweetId};
        NSURL *urlForExtension = [PKTExtensionHostAppHelper extensionURLForHostApp:[[NSBundle mainBundle] bundleIdentifier] originalURL:urlToShareToPocket parameters:parameters];

        return urlForExtension;
    }
    
    return self.urlToShare;
}
```

**4. That's it!**

Now your application should include tweet attribution when sharing to Pocket's share extension.

### Need help?

First take a look at the sample project that is included in this repo. It will show you a working implementation of the helper code.

If you are having any problems or have any questions, please reach out to us at api@getpocket.com.

### How this library works

**Using a Delegate with UIActivityViewController**

Instead of passing a NSURL or NSString in the UIActivityViewController init method: _initWithActivityItems:applicationActivities:_ the host app passes in one (or multiple) objects that conforms to the UIActivityItemSource protocol. 

The protocol requires to implement two delegate methods: -activityViewControllerPlaceholderItem: here, the host app just return the type of objects the host app wants to return in the next delegate method. In the -activityViewController:itemForActivityType: the host app returns the right value for the activity type. In the second delegate method is the activityType parameter again. 

There the host app can check for the Pocket extension activity type and if it's the Pocket extension, the host app returns the URL with further tweet information parameters to the Pocket extension that send's this url to our API and the Pocket parses out the tweet information in the backend.

**Passing a Special URL to Pocket When Sharing**

The app sharing the URL, should wrap it in a special URL that it passes to the extension. Doing it this way allows us to pass additional data to the extension.

The general format looks like the following:

`bundlename://extensionsave?parameter1=PARA1_URL_ENC&parameter2=PARA2_URL_ENC`

If we use a Twitter client for an example the format to send a tweet_id and an url would look like the follow:

`bundlename://extensionsave?tweet_id=TWEET_ID&url=URL_ENCODED_URL`

The end result if we would use the Pocket app as an example and some data would be something like:

`com.ideashower.ReadItLaterPro://extensionsave?tweet_id=123456789&url=http%3A%2F%2Fgoogle.com`


Then on Pocket's side, we look for a string that matches the xxxx://extensionsave format and extract:

* name of app
* tweet id
* url

And then save that via the API normally with that information.
