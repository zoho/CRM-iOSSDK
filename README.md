# ZCRMiOS

Zoho CRM is a cloud-based business collaboration application which helps to manage customer relationships. To access the CRM data efficiently and in time, a mobile app is built based on the CRM website. While building an iOS app on the CRM, you may need to do additional tasks like data extraction, creating an instance for data and more.
With the advent of the CRM iOS SDK, these additional tasks are managed by SDK and it facilitates you to concentrate more on the design of the app. This document guides you to integrate the CRM SDK to the app and customize it according to business requirements.

[![CI Status](http://img.shields.io/travis/boopathyparamasivan/ZCRMiOS.svg?style=flat)](https://travis-ci.org/boopathyparamasivan/ZCRMiOS)
[![Version](https://img.shields.io/cocoapods/v/ZCRMiOS.svg?style=flat)](http://cocoapods.org/pods/ZCRMiOS)
[![License](https://img.shields.io/cocoapods/l/ZCRMiOS.svg?style=flat)](http://cocoapods.org/pods/ZCRMiOS)
[![Platform](https://img.shields.io/cocoapods/p/ZCRMiOS.svg?style=flat)](http://cocoapods.org/pods/ZCRMiOS)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Xcode 10.2 and Above

Swift 4.2

## SDK Responsibilities

Scaffolding - Zoho CRM dependencies inclusion and base project creation.

Authentication - User login and logout.

API wrapping & version upgrades - API requests wrapped as method calls.

Data modeling - CRM entities modeled as language objects.

Metadata caching - Essential metadata are cached to avoid unnecessary API calls.

The mobile SDK takes care of the above, so that the developers can focus only on the UI components of the mobile app.

## Installation

ZCRMiOS is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZCRMiOS', :git => 'https://github.com/zoho/CRM-iOSSDK.git', :branch =>  'V2_ALPHA'
```

## Register a Zoho Client

Since Zoho CRM APIs are authenticated with OAuth2 standards, it is necessary to register your app with Zoho.

1. Visit https://accounts.zoho.com/developerconsole.

2. Click “Add Client ID”.

3. Enter the Client Name, Client Domain & Redirect URI
    > Sample Redirect URI : zohoapp://
    
4. Select the Client Type as Mobile.
Your client app is now registered. The Client ID and Client Secret of the newly registered app will be found under Options > Edit in the above mentioned website.
5. Click Create

## Configuration 

1. Download the AppConfiguration.plist file from this link [AppConfiguration](https://github.com/zoho/CRM-iOSSDK/blob/V2_ALPHA/AppConfiguration.plist)

2. Add downloaded AppConfiguration.plist file into your project

3. Edit AppConfiguration.plist file with created Client ID, Client Secret ID and Redirect URI(The Redirect URI must be your application’s custom URL Scheme)

4. Add the Redirect URI Scheme into your app Info.plist too

## Initialise the SDK
Add the following code in your project AppDelegate.swift file
```ruby
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            let window = UIApplication.shared.windows.first
            try ZCRMSDKClient.shared.initSDK(window: window, appConfiguration : appConfiguration)
        }
        catch {
            print("unable to init ZCRMiOS SDK : \(error)")
        }
        return true
    }
```

Here appConfiguration refers to the ZCRMSDKConfigs object which you need to pass to the SDK before consuming it.

For detailed list of ZCRMSDKConfigs, refer this [link](https://www.zoho.com/crm/developer/docs/mobile-sdk/ios-initialize.html)

## Handle Sign in/ Sign out

In the ViewController class of your custom launch screen, add this code as the sign in button's action
```ruby
ZCRMSDKClient.shared.showLogin { ( err ) in
            if let error = err
            {
                print( "unable to show login.. Error >> \( error )")
            }
            else{
                print( "Login successful" )
            }
        }
```
Add this code as the sign out button's action
```ruby
ZCRMSDKClient.shared.logout { ( err ) in
            if let error = err {
                print("Error occurred >>> \( error )")
            }
            else{
                print( "Logout successful" )
            }
        }
```

## In the AppConfiguration.plist file

1. **OAuthscopes** (mandatory) - Samples scopes are already mentioned in the created property file, you can change the scopes as per your need.[Learn more](https://www.zoho.com/crm/developer/docs/api/v1-overview.html#OAuth2_0).

2. **AccessType** (optional) - Type of environment in CRM
  * Production - Environment that have active paying users accessing critical business data.
  * Development - Environments where you can extend, integrate and develop without affecting your production environments.
  * Sandbox - Environments specifically used for testing application functionality before deploying to production or releasing to customers.
  
3. **DomainSuffix** (optional) - Multi DC support.
  * eu - www.zohoapis.eu
  * in - www.zohoapis.in
  * com - www.zohoapis.com
  * cn - www.zohoapis.com.cn
  * au - www.zohoapis.au
  * jp - www.zohoapis.jp
  
4. **PortalID** (optional) - Mention your CRM PortalID (Ex : 65468393). No need to mention "PortalID" within properties file, if you do not have one.

5. **ShowSignUp** (optional) - Give the value as true if you provide signup facility in your app, else give false.
This file contains values of certain configurations that are needed to run the app. Please do not change the property names or values that already exist, as they are needed for the smooth functioning of the SDK and the app

## Author

Zohocorp

## License

ZCRMiOS is available under the MIT license. See the LICENSE file for more info.
