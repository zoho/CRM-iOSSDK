![ZohoAuth Header](resources/images/banner_zohoauth.png)
# <span style="color:green">ZohoAuth</span>


## Integrate Zoho sign-in to your iOS application.

**ZohoAuth** is a hollistic SDK which provides easy to use methods. Using these methods you can achieve Zoho sign-in integration with your iOS Mobile Application.

## 1.Register 
Register your mobile application at the Zoho Accounts [Developer Console](https://accounts.zoho.com/developerconsole) to receive your Client ID and Client Secret. You must enter the client name, client domain, valid authorized redirect URI. Make sure you use the drop-down to change the client type to **Mobile Applications**.

**Note**: The authorized redirect URI is the **URLScheme** (Example: MyDemoApp://) of your application.


## 2. Set up Your Development Environment
### Using Cocoapods

* Navigate to your project folder in a terminal window.
2. Make sure you have the [CocoaPods](https://cocoapods.org/) gem installed on your machine before installing the [ZohoAuth](https://cocoapods.org/pods/ZohoAuth) pod.


~~~

    $ sudo gem install cocoapods
    $ pod init


~~~

* Add the following to your Podfile:

~~~

    pod 'ZohoAuth'


~~~

* Run the following command in your project root directory from a terminal window:

~~~

    $ pod install


~~~

## 3. Connect Your App Delegate

Add the following to your <span style="color:green">AppDelegate</span> class. This will initialize ZohoAuth when you launch your application and will let ZohoAuth handle responses when the user performs an action (such as login).

Make sure to import the framework header: #import \<ZohoAuthKit/ZohoAuth.h\>

If using Swift you will need to add it to your [Objective-C bridging header](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html).

~~~

// Objective C

//  AppDelegate.m
#import <ZohoAuthKit/ZohoAuth.h>

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [ZohoAuth initWithClientID:<Your Client ID>
  		    ClientSecret:<Your Client Secret>
  		    Scope:<Your Scopes Array>
  		    URLScheme:<Your URLSCheme: Example:@"MyDemoApp://">
  		    MainWindow:[[UIApplication sharedApplication]delegate].window 
  		    AccountsURL:<Your Accounts URL: Example:@"https://accounts.zoho.com">];
  // Add any custom logic here.
  return YES;
}

- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url 
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

  BOOL handled = [ZohoAuth handleURL:url
  sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
  annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
  
  // Add any custom logic here.
  return handled;
}


~~~

~~~

// Swift

//  AppDelegate.swift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

    ZohoAuth(clientID: <Your Client ID>, 
    clientSecret: <Your Client Secret>, 
    scope: <Your Scopes Array>, 
    urlScheme: <Your URLSCheme: Example:"MyDemoApp://">, 
    mainWindow: UIApplication.shared.delegate?.window, 
    accountsURL: <Your Accounts URL: Example:"https://accounts.zoho.com">)
    // Add any custom logic here.
    return true
}

func application(_ application: UIApplication, open url: URL, 
options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

    let handled: Bool = ZohoAuth.handle(url, 
    sourceApplication: options[.sourceApplication], 
    annotation: options[.annotation])
    
    // Add any custom logic here.
    return handled
}


~~~
Note that <span style="color:green">application:openURL:options:</span> is only available in iOS 10 and above. If you are building with an older version of the iOS SDK, you can use:

~~~
// Objective C
- (BOOL)application:(UIApplication *)application 
            openURL:(NSURL *)url 
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
         
  BOOL handled = [ZohoAuth handleURL:url
  sourceApplication:sourceApplication
  annotation:annotation]];
  
  // Add any custom logic here.
  return handled;
} 


~~~

~~~
// Swift
func application(_ application: UIApplication, open url: URL, 
sourceApplication: String?, annotation: Any) -> Bool {

	let handled: Bool = ZohoAuth.handle(url, sourceApplication: sourceApplication, annotation: annotation)

	// Add any custom logic here.
    return handled
}


~~~

## 4. Add Zoho Login to Your Code

### 4a. Add Zoho Login
To add Zoho Login to your app, add the following code snippet to the login button action of your view controller.

~~~

// Objective C

// Add this to the header of your file, e.g. in ViewController.m 
// after #import "ViewController.h"
#import <ZohoAuthKit/ZohoAuth.h>

- (IBAction)loginButtonAction:(id)sender {

    [ZohoAuth presentZohoSignIn:^(NSString *token, NSError *error) {
        if(token!=nil && error==nil){
            // Handle sign in success logic here.
        }else{
            // Handle sign in failure logic here.
        }
    }];
    
}


~~~

~~~

//Swift
@IBAction func loginButtonAction(_ sender: Any) {

    ZohoAuth.presentZohoSign(in: {(_ token: String?, _ error: Error?) -> Void in
        if token != nil && error == nil {
            // Handle sign in success logic here.
        } else {
            // Handle sign in failure logic here.
        }
    })
    
}


~~~

Now you should be able to run your app and log in using Zoho.

### 4b. Add Custom Zoho Login
To add Zoho Login to your app and customize Zoho login page, add the following code snippet to the login button action of your view controller.

~~~

// Objective C

// Add this to the header of your file, e.g. in ViewController.m 
// after #import "ViewController.h"
#import <ZohoAuthKit/ZohoAuth.h>

- (IBAction)loginButtonAction:(id)sender {

    [ZohoAuth presentZohoSignInHavingCustomParams:<Your Custom Params: Ex: @"hide_fs=true"> 
    signinHanlder:^(NSString *token, NSError *error) {
        if(token!=nil && error==nil){
            // Handle sign in success logic here.
        }else{
            // Handle sign in failure logic here.
        }
    }];
    
}


~~~

~~~

//Swift
@IBAction func loginButtonAction(_ sender: Any) {

    ZohoAuth.presentZohoSign(inHavingCustomParams: <Your Custom Params: Ex: "hide_fs=true">,
     signinHanlder: {(_ token: String?, _ error: Error?) -> Void in
        if token != nil && error == nil {
            // Handle sign in success logic here.
        } else {
            // Handle sign in failure logic here.
        }
    })
    
}


~~~

#### List of supported Custom params:
Custom Param Name|Supported Values|Purpose
:--|:--|:--
hide_signup |true/false|To hide/show Signup option
portal_domain |\<Your Org Registered Domain Name\>|To show Org Logo in Sign in page
hide_fs |true/false|To hide/show Federated Sign in option

**Note**: Multiple custom params should be given in URL query params format. Example: @"hide\_signup=false\&hide\_fs=true"

## 5. OAuth Token

###5a. Get OAuth Access Token:

You need an OAuth access token to access Zoho's APIs. You can get an access token by calling the following method:

~~~

// Objective C

// Add this to the header of your file, e.g. in ViewController.m 
// after #import "ViewController.h"
#import <ZohoAuthKit/ZohoAuth.h>

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [ZohoAuth getOauth2Token:^(NSString *token, NSError *error) {
        if(token!=nil && error==nil){
            //use this token to access Zoho's APIs here.
        }else{
            // Handle token failure logice here.
        }
    }];
    
}


~~~

~~~

// Swift

func viewDidLoad() {
    super.viewDidLoad()
    
    ZohoAuth.getOauth2Token({(_ token: String?, _ error: Error?) -> Void in
        if token != nil && error == nil {
            //use this token to access Zoho's APIs here.
        } else {
            // Handle token failure logice here.
        }
    })
    
}


~~~

**Note**: This method will **always** return a valid access token.

###5b. How to send the access token?

Send the access token only via the authorization header.

Example: Zoho-oauthtoken\<space\>\<access\_token\>

~~~

// Objective C
[request setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token]
forHTTPHeaderField:@"Authorization"];


~~~

~~~

//Swift
request.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")


~~~

###5c. Logout/Sign-out Handling:
Add the following code snippet to the logout/sign-out button action:

~~~

// Objective C
[ZohoAuth revokeAccessToken:^(NSError *error) {
        if(error==nil){
            
        }else{
            
        }
 }];


~~~

~~~

//Swift
ZohoAuth.revokeAccessToken({(_ error: Error?) -> Void in
    if error == nil {

    } else {

    }
})


~~~

###5d. Special Error Handling:
If you receive the **invalid\_mobile\_code** error, you must bring the user to the signed-out state and have the user sign-in again.

**Note**: You will get this error if the user deletes your app from [Connected Apps](https://accounts.zoho.com/u/h#sessions/userconnectedapps).

## 6. Give Feedback
Please report bugs or issues to **support-mobilesdk@zohoaccounts.com**


---
