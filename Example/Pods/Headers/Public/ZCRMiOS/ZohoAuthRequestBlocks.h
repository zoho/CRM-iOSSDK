//
//  ZohoAuthRequestBlocks.h
//  IAM_ZohoAuth
//
//  Created by Kumareshwaran on 02/02/18.
//  Copyright © 2018 Zoho. All rights reserved.
//

#ifndef ZohoAuthRequestBlocks_h
#define ZohoAuthRequestBlocks_h

/**
 The callback handler gives an access token or an error. The error occurs if an attempt to
 refresh the access token is unsuccessful.
 
 @param token This token should be sent in the Authorization Header.(Header Value should be @"Zoho-oauthtoken<space>TOKEN"  forHTTPHeaderField:@"Authorization" where TOKEN is the NSString accessToken obtained in this block)
 @param error Respective error object if the attempt to refresh the access token is unsuccessful.
 */
typedef void (^ZohoAuthAccessTokenHandler)(NSString *token,NSError *error);
/**
 The callblack handler at Sign-in that gives the access token if there is no error. Using this handler, you can redirect to your app's signed-in state and present your respective screens if the error is nil.
 
 @param token OAuth access token of the signed-in user.
 @param error Respective error object.
 */
typedef void (^ZohoAuthSignInHandler)(NSString *token,NSError *error);
/**
 The callback handler for revoking the access token at logout. Nil error means that the access token was revoked successfully. You can handle your apps logout logic in this handler if there is no error.
 
 @param error Respective error object of revoke network call.
 */
typedef void (^ZohoAuthRevokeAccessTokenHandler)(NSError *error);

/**
 The callback handler for uploading a profile picture. Nil error means that the photo has been successfully uploaded.
 
 @param error Respective error object of failed profile photo upload.
 */
typedef void (^ZohoAuthUploadHandler)(NSError *error);

#endif /* ZohoAuthRequestBlocks_h */
