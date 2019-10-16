# ZCRMiOS

Zoho CRM's Mobile SDK is a technology that helps developers build mobile applications to interact with their Zoho CRM data.

Currently, the mobile app for Zoho CRM acts as a mobile interface to the Zoho CRM's web interface. But in case you need the mobile app to serve a specific purpose that conforms to your business needs, you might want to have an app which has only that specific function. For example, an app for a team that only approves leads or an app for a field team where one could upload photographs and client's documents on the fly.

[![CI Status](http://img.shields.io/travis/boopathyparamasivan/ZCRMiOS.svg?style=flat)](https://travis-ci.org/boopathyparamasivan/ZCRMiOS)
[![Version](https://img.shields.io/cocoapods/v/ZCRMiOS.svg?style=flat)](http://cocoapods.org/pods/ZCRMiOS)
[![License](https://img.shields.io/cocoapods/l/ZCRMiOS.svg?style=flat)](http://cocoapods.org/pods/ZCRMiOS)
[![Platform](https://img.shields.io/cocoapods/p/ZCRMiOS.svg?style=flat)](http://cocoapods.org/pods/ZCRMiOS)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Xcode 10 and Above

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

1. Download the AppConfiguration.plist file from this link [AppConfiguration property list file](https://github.com/zoho/CRM-iOSSDK/blob/V2_ALPHA/AppConfiguration.plist)

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
            try ZCRMSDKClient.shared.initSDK(window: window)
        }
        catch {
            print("unable to init ZCRMiOS SDK : \(error)")
        }
        return true
    }
```

## Handle Sign in/ Sign out

In the ViewController class of your custom launch screen, add this code as the sign in button's action
```ruby
ZCRMSDKClient.shared.showLogin { ( success ) in
            if( success == true )
            {
                print( "Login successful" )
            }
            else{
                print( "unable to show login")
            }
        }
```
Add this code as the sign out button's action
```ruby
ZCRMSDKClient.shared.logout { ( success ) in
            if success {
                print("logout successful")
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
  * us - www.zohoapis.com
  * eu - www.zohoapis.eu
  * cn - www.zohoapis.com.cn
  
4. **PortalID** (optional) - Mention your CRM PortalID (Ex : 65468393). No need to mention "PortalID" within properties file, if you do not have one.

5. **ShowSignUp** (optional) - Give the value as true if you provide signup facility in your app, else give false.
This file contains values of certain configurations that are needed to run the app. Please do not change the property names or values that already exist, as they are needed for the smooth functioning of the SDK and the app

## Author

Zohocorp

## License

ZCRMiOS is available under the MIT license. See the LICENSE file for more info.
