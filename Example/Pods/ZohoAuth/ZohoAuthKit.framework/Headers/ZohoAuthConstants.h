//
//  ZohoAuthConstants.h
//  Pods
//
//  Created by Kumareshwaran on 24/03/17.
//  Copyright (c) 2018 Zoho. All rights reserved.
//

#ifndef ZohoAuthConstants_h
#define ZohoAuthConstants_h


/**
 * Unable to fetch token from server.
 */
static const int k_ZohoAuthTokenFetchError = 201;
/**
 * Fetches Access token
 * Response is nil.
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
 * Access token doesn't exist.
 */
static const int k_ZohoAuthNoAccessToken = 302;
/**
 * Unable to revoke token.
 */
static const int k_ZohoAuthRevokeTokenError = 801;
/**
 * Fetches Revoke token
 * Response is nil.
 */
static const int k_ZohoAuthRevokeTokenResultNil = 802;
/**
 * Fetches Revoke token.
 * Nothing was received.
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
 * Refresh token fetch.
 * Response is nil.
 */
static const int k_ZohoAuthRefreshTokenFetchNil = 902;
/**
 * Unable to fetch Refresh token. Nothing was received.
 */
static const int k_ZohoAuthRefreshTokenFetchNothingReceived = 904;
/**
 * OAuth Server Error occured during redirection.
 */
static const int k_ZohoAuthOAuthServerError = 905;
/**
 * Access token doesn't exist for the given scopes.
 */
static const int k_ZohoAuthScopeNotFound = 906;
/**
 * Unable to update photo.
 */
static const int k_ZohoAuthUpdatePhotoError = 1001;
/**
 * UpdatePhoto fetch.
 * Response is nil.
 */
static const int k_ZohoAuthUpdatePhotoResultNil = 1002;
/**
 * UpdatePhoto fetch. Nothing was received.
 */
static const int k_ZohoAuthUpdatePhotoNothingReceived = 1003;
/**
 * UpdatePhoto server error occured.
 */
static const int k_ZohoAuthUpdatePhotoServerError = 1004;
/**
 * Unable to Enhance Scope.
 */
static const int k_ZohoAuthEnhanceScopeError = 701;
/**
 * Fetches EnhanceScope
 * Response is nil.
 */
static const int k_ZohoAuthEnhanceScopeResultNil = 702;
/**
 * Fetches EnhanceScope
 * Response is nil.
 */
static const int k_ZohoAuthEnhanceScopeServerError = 703;
/**
 * Fetches EnhanceScope
 * Nothing was received.
 */
static const int k_ZohoAuthEnhanceScopeNothingReceived = 704;
/**
 * Network call failed with unknown error.
 */

#endif /* ZohoAuthConstants_h */
