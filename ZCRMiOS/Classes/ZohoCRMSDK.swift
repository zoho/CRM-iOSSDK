//
//  ZohoCRMSDK.swift
//  ZCRMiOS
//
//  Created by Sarath Kumar Rajendran on 06/09/18.
//  Copyright © 2017 zohocrm. All rights reserved.
//

import UIKit

public class ZohoCRMSDK {
	
	public static let shared = ZohoCRMSDK()
	private var isVerticalCRM: Bool = false
	private var zcrmLoginHandler: ZCRMLoginHandler = ZCRMLoginHandler.init()
	private var zvcrmLoginHandler: ZVCRMLoginHandler = ZVCRMLoginHandler.init()
	
	private init() {
		
		if let file = Bundle.main.path(forResource : "AppConfiguration", ofType: "plist" ) {
			
			let appConfiguration: [String : Any]  = (NSDictionary( contentsOfFile : file ) as? [String : Any])!
			let crmAppConfigs: CRMAppConfigUtil = CRMAppConfigUtil(appConfigDict: appConfiguration)
			let appType = appConfiguration["Type"] as? String
			crmAppConfigs.setAppType(type: appType!)
			do {
				if appType == "ZCRM" {
					self.zcrmLoginHandler = try ZCRMLoginHandler(appConfigUtil: crmAppConfigs)
				} else {
					self.zvcrmLoginHandler = try ZVCRMLoginHandler(appConfigUtil: crmAppConfigs)
					self.isVerticalCRM = true
				}
				self.clearFirstLaunch()
			} catch {
				print(error)
			}
		}
		
	}
	
	private func clearFirstLaunch() {
		let alreadyLaunched = UserDefaults.standard.bool(forKey:"first")
		if !alreadyLaunched{
			if self.isVerticalCRM {
				self.zvcrmLoginHandler.clearIAMLoginFirstLaunch()
			} else {
				self.zcrmLoginHandler.clearIAMLoginFirstLaunch()
			}
			UserDefaults.standard.set(true, forKey: "first")
		}
	}
	
	public func handleUrl( url : URL, sourceApplication : String?, annotation : Any ) {
		
		if self.isVerticalCRM {
			self.zvcrmLoginHandler.iamLoginHandleURL(url: url, sourceApplication: sourceApplication, annotation: annotation)
		} else {
			self.zcrmLoginHandler.iamLoginHandleURL(url: url, sourceApplication: sourceApplication, annotation: annotation)
		}
	}
	
	
	public func initialise(window: UIWindow) {
		
		if self.isVerticalCRM {
			self.zvcrmLoginHandler.initIAMLogin(window: window)
		} else {
			self.zcrmLoginHandler.initIAMLogin(window: window)
		}
	}
	
	public func showLogin(completion: @escaping (Bool) -> ()) {
		
		if self.isVerticalCRM {
			
			if self.zvcrmLoginHandler.isUserSignedIn() {
				completion(true)
			} else {
				self.zvcrmLoginHandler.handleLogin { (success) in
					completion(success)
				}
			}
		} else {
			
			if self.zcrmLoginHandler.isUserSignedIn() {
				completion(true)
			} else {
				self.zcrmLoginHandler.handleLogin { (success) in
					completion(success)
				}
			}
		}
	}
	
	public func isUserSignedIn() -> Bool {
		
		var isUserSignedIn:Bool = false
		if self.isVerticalCRM {
			isUserSignedIn = self.zvcrmLoginHandler.isUserSignedIn()
		} else {
			isUserSignedIn = self.zcrmLoginHandler.isUserSignedIn()
		}
		return isUserSignedIn
	}

	public func logout(completion: @escaping (Bool) -> ()) {
		
		if self.isVerticalCRM {
			self.zvcrmLoginHandler.logout { (success) in
				completion(success)
			}
		} else {
			self.zcrmLoginHandler.logout { (success) in
				completion(success)
			}
		}
	}
}
