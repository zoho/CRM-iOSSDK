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

Xcode 8 and Above

Swift 3.2

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
pod 'ZCRMiOS', :git => 'https://github.com/zoho/CRM-iOSSDK.git'
```

## Author

Zohocorp

## License

ZCRMiOS is available under the MIT license. See the LICENSE file for more info.
