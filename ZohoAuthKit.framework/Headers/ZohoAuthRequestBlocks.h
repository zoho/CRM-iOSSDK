//
//  ZohoAuthRequestBlocks.h
//  IAM_ZohoAuth
//
//  Created by Kumareshwaran on 02/02/18.
//  Copyright © 2018 Dhanasekar K. All rights reserved.
//

#ifndef ZohoAuthRequestBlocks_h
#define ZohoAuthRequestBlocks_h

typedef void (^ZohoAuthAccessTokenHandler)(NSString *token,NSError *error);

typedef void (^ZohoAuthSignInHandler)(NSString *token,NSError *error);

typedef void (^ZohoAuthRevokeAccessTokenHandler)(NSError *error);

typedef void (^ZohoAuthUploadHandler)(NSError *error);

#endif /* ZohoAuthRequestBlocks_h */
