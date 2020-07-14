//
//  ZohoAuth.h
//  IAM_ZohoAuth
//
//  Created by Kumareshwaran on 02/02/18.
//  Copyright © 2018 Dhanasekar K. All rights reserved.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_WATCH
#import <UIKit/UIKit.h>
#endif
#include "ZohoAuthRequestBlocks.h"

@interface ZohoAuth : NSObject

#if !TARGET_OS_WATCH
+(void) initWithClientID: (NSString*)clientID
             ClientSecret: (NSString*)clientSecret
                    Scope:(NSArray*)scopearray
                URLScheme:(NSString*)urlScheme
               MainWindow:(UIWindow*)mainWindow
              AccountsURL:(NSString*)accountsURL;
#endif

+(void) initExtensionWithClientID:(NSString*)clientID
                      ClientSecret: (NSString*)clientSecret
                             Scope:(NSArray*)scopearray
                         URLScheme:(NSString*)urlScheme
                       AccountsURL:(NSString*)accountsURL;

+(void)clearZohoAuthDetailsForFirstLaunch;

+(BOOL)handleURL:url sourceApplication:sourceApplication annotation:annotation;

+(void)setHavingAppExtensionWithAppGroup:(NSString *)appGroup;

+(void)getOauth2Token:(ZohoAuthAccessTokenHandler)tokenBlock;

+(NSDictionary *)giveOAuthDetailsForWatchApp;

+(void)setOAuthDeteailsInKeychainForWatchApp:(NSDictionary *)OAuthDetails;

+(void) presentZohoSignIn:(ZohoAuthSignInHandler)signinBlock;

+(void) presentZohoSignInHavingCustomParams:(NSString *)urlParams signinHanlder:(ZohoAuthSignInHandler)signinBlock;

+(void)revokeAccessToken:(ZohoAuthRevokeAccessTokenHandler)revoke;

+(void)updatePhoto:(UIImage*)image uploadHandler:(ZohoAuthUploadHandler)uploadBlock;

+(NSString *)getAPIDomain;

@end
