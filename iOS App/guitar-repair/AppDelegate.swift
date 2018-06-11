//
//  AppDelegate.swift
//  guitar-repair
//
//  Created by steven freed on 6/5/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import UIKit
import CoreData
import AWSPinpoint
import AWSAuthCore
import AWSMobileClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize AWSMobileClient
        let didFinishLaunching = AWSMobileClient.sharedInstance().interceptApplication(
            application, didFinishLaunchingWithOptions:
            launchOptions)
        
        // Initialize Pinpoint to enable session analytics
        let pinpoint = AWSPinpoint(configuration:
            AWSPinpointConfiguration.defaultPinpointConfiguration(
                launchOptions: launchOptions))
        
        //  Initialize the Amazon Cognito credentials provider
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId: "us-east-1:yourIdentityPoolId")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        return didFinishLaunching
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Open AWSAuthUI for user to register or login
        return AWSMobileClient.sharedInstance().interceptApplication(
            application, open: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }

}

