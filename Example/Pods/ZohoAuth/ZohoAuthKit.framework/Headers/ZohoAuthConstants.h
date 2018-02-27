//
//  ZohoAuthConstants.h
//  Pods
//
//  Created by Kumareshwaran on 24/03/17.
//
//

#ifndef ZohoAuthConstants_h
#define ZohoAuthConstants_h


/**
 * Unable to fetch token from server.
 */
static const int k_ZohoAuthTokenFetchError = 201;
/**
 * Access token fetch:Response is nil.
 */
static const int k_ZohoAuthTokenFetchNil = 202;
/**
 * Unable to fetch token. Nothing was received.
 */
static const int k_ZohoAuthTokenFetchNothingReceived = 204;
/**
 * SFSafari Dismissed.
 */
static const int k_ZohoAuthSFSafariDismissed = 205;
/**
 * There is no access token.
 */
static const int k_ZohoAuthNoAccessToken = 302;
/**
 * Unable to revoke token.
 */
static const int k_ZohoAuthRevokeTokenError = 801;
/**
 * Revoke token fetch:Response is nil.
 */
static const int k_ZohoAuthRevokeTokenResultNil = 802;
/**
 * Revoke token fetch. Nothing was received.
 */
static const int k_ZohoAuthRevokeTokenNothingReceived = 804;
/**
 * Network call failed with unknown error.
 */
static const int k_ZohoAuthGenericError = 901;
/**
 * Unable to fetch Refresh token from server.
 */
static const int k_ZohoAuthRefreshTokenFetchError = 901;
/**
 * Refresh token fetch:Response is nil.
 */
static const int k_ZohoAuthRefreshTokenFetchNil = 902;
/**
 * Unable to fetch Refresh token. Nothing was received.
 */
static const int k_ZohoAuthRefreshTokenFetchNothingReceived = 904;
/**
 * OAuth Server Error Occured during redirection
 */
static const int k_ZohoAuthOAuthServerError = 905;
/**
 * There is no access token for the given scopes.
 */
static const int k_ZohoAuthScopeNotFound = 906;
/**
 * Unable to UpdatePhoto.
 */
static const int k_ZohoAuthUpdatePhotoError = 1001;
/**
 * UpdatePhoto fetch:Response is nil.
 */
static const int k_ZohoAuthUpdatePhotoResultNil = 1002;
/**
 * UpdatePhoto fetch. Nothing was received.
 */
static const int k_ZohoAuthUpdatePhotoNothingReceived = 1003;
/**
 * UpdatePhoto Server Error Occured.
 */
static const int k_ZohoAuthUpdatePhotoServerError = 1004;


#endif /* ZohoAuthConstants_h */
