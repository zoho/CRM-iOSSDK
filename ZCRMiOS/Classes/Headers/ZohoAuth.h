//
//  ZohoAuth.h
//  IAM_ZohoAuth
//
//  Created by Kumareshwaran on 02/02/18.
//  Copyright © 2018 Zoho. All rights reserved.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_WATCH
#import <UIKit/UIKit.h>
#endif
#include "ZohoAuthRequestBlocks.h"
#include "ZohoAuthConstants.h"

/**
 ZohoAuth is a hollistic SDK which provides easy to use methods. Using these methods you can achieve Zoho sign-in integration with your iOS Mobile Application.
 */
@interface ZohoAuth : NSObject

#if !TARGET_OS_WATCH

/**
 This method will initialize the parameters which are required by the ZohoAuth.
 Call this method at App Launch.
 
 @param clientID It is a unique identifier you receive when you register your application with Zoho
 @param clientSecret  A unique key generated when you register your application with Zoho. This must be kept confidential.
 @param scopearray The API scopes requested by the app, represented in an array of |NSString|s. The default value is |@[aaaserver.profile.READ,zohocontacts.userphoto.READ]|.(Get the list of scopes required for your app from the respective service teams. Each Scope String should follow the proper syntax. -> 'servicename'.'scopename'.'operation type' Example: AaaServer.profile.READ.
 
 @param urlScheme Your App's URL Scheme.
 @param mainWindow A UIWindow instance is required for presenting SFSafariViewController/AccountChooserViewController.
 @param accountsURL This is the Enum of your build type.
 */
+(void) initWithClientID: (NSString*)clientID
            ClientSecret: (NSString*)clientSecret
                   Scope:(NSArray*)scopearray
               URLScheme:(NSString*)urlScheme
              MainWindow:(UIWindow*)mainWindow
             AccountsURL:(NSString*)accountsURL;
#endif


/**
 This method will initialize the parameters which are required by the ZohoAuth.
 Call this method at App Launch in Extensions and iWatch.
 (Note: Add your main app's bundle id in your extensions info.plist for "ZohoAuthUSERKIT_MAIN_APP_BUNDLE_ID" key)
 
 
 @param clientID It is a unique identifier you receive when you register your application with Zoho
 @param clientSecret A unique key generated when you register your application with Zoho. This must be kept confidential.
 @param scopearray The API scopes requested by the app, represented in an array of |NSString|s. The default value is |@[aaaserver.profile.READ,zohocontacts.userphoto.READ]|.(Get the list of scopes required for your app from the respective service teams. Each Scope String should follow the proper syntax. -> 'servicename'.'scopename'.'operation type' Example: AaaServer.profile.READ.
 @param urlScheme Your App's URL Scheme.(!Please WhiteList the URL Scheme "ZOA"!)
 @param accountsURL This is the Enum of your build type.
 */
+(void) initExtensionWithClientID:(NSString*)clientID
                     ClientSecret: (NSString*)clientSecret
                            Scope:(NSArray*)scopearray
                        URLScheme:(NSString*)urlScheme
                      AccountsURL:(NSString*)accountsURL;

/**
 Method to clear the keychain items stored by ZohoAuth which would be persistant even after uninstalling the app. (Call this method if it is going to be your apps firt time launch.
 */
+(void)clearZohoAuthDetailsForFirstLaunch;

/**
 Method to handle OAuth redirection via URL Scheme.
 This method should be called from your |UIApplicationDelegate|'s
 |application:openURL:sourceApplication:annotation|.  Returns |YES| if |ZohoAuth handled this URL.
 
 
 @param url url opened.
 @param sourceApplication The application which opened this app.
 @param annotation annotation object.
 @return YES if SSOKit handled this URL.
 */
+(BOOL)handleURL:url sourceApplication:sourceApplication annotation:annotation;

/**
 Method for letting us know that your app has an App Extension, so that we will place the respective data in the keychain within the specified app group. Call this method in App Delegate launch after the above initializeWithClientID method. This should be called before you call clearZohoAuthDetailsForFirstLaunch method.
 
 @param appGroup appgroup string in which you want the keychain data to be available.
 
 */
+(void)setHavingAppExtensionWithAppGroup:(NSString *)appGroup;

/**
 Gets the access token. In case the access token has expired or is about to expire, this method get a new token.
 
 @param tokenBlock callback in which you will get the required access token.
 */
+(void)getOauth2Token:(ZohoAuthAccessTokenHandler)tokenBlock;

/**
 Method to get the OAuth details which will be required by the Watch App to refresh the expired access token.
 
 @return dictionary containing all the details which is required to fetch a new access token.
 */
+(NSDictionary *)giveOAuthDetailsForWatchApp;

/**
 Method to set the OAuth details obtained from iPhone to the keychain of watch app.
 
 @param oauthDetails dictionary containing the details required to fetch new access token.
 */
+(void)setOAuthDeteailsInKeychainForWatchApp:(NSDictionary *)OAuthDetails;

/**
 This method presents the Zoho Sign in page on SFSafariViewController.
 
 @param signinBlock handler block.
 */
+(void) presentZohoSignIn:(ZohoAuthSignInHandler)signinBlock;


/**
 This is a special method. If you are handling sign-in, you will send us a SAML response which we will process and generate an access token for you. Use this method to set a callback handler for us to send the access token back to you.
 
 @param signinBlock handler block.
 */
+(void)setSignInCallback:(ZohoAuthSignInHandler)signinBlock;

/**
This method presents the Zoho Sign in page with custom parameters on SFSafariViewController.
 
 @param urlParams custom urlparams to be passed to the sign-in page.
 @param signinBlock handler block.
 */
+(void) presentZohoSignInHavingCustomParams:(NSString *)urlParams signinHanlder:(ZohoAuthSignInHandler)signinBlock;

/**
 Call this method at Logout. This will revoke the access token from the server and clears the keychain items stored by ZohoAuth.
 
 @param revoke handler block.
 */
+(void)revokeAccessToken:(ZohoAuthRevokeAccessTokenHandler)revoke;

/**
 Call this method to update your profile photo.
 
 @param image UIImage object.
 @param uploadBlock handler block.
 */
+(void)updatePhoto:(UIImage*)image uploadHandler:(ZohoAuthUploadHandler)uploadBlock;

/**
 Call this method to get the api domain.

 @return api domain of current user.
 */
+(NSString *)getAPIDomain;


/**
 Method used for Scope Enhancements. Call this method once if you are introducing new scopes in your app update.

 @param tokenBlock callback in which you will get the required access token.
 */
+(void)enhanceScopes:(ZohoAuthAccessTokenHandler)tokenBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/// Method to set Network Delegate for On-Premise
/// @param delegate NSURLSessionDataDelegate
+(void)setNetworkDelegate:(id<NSURLSessionDataDelegate> )delegate;

///  Method to get the Signed-in status of user in your app. YES if there is already a user signed-in to your app or NO if there is no user signed in to your app.
+(BOOL)isUserSignedIn;
@end
