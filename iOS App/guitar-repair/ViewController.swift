//
//  ViewController.swift
//  guitar-repair
//
//  Created by steven freed on 6/5/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSUserPoolsSignIn
import AWSAuthUI
import AWSAuthCore

class ViewController: UIViewController {
    
     // Menu IBOutlets
    @IBOutlet weak var hamburger: UIBarButtonItem!
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var curvedMenu: UIImageView!
    @IBOutlet weak var screenButton: UIButton!

    // Menu Buttons and image IBOutlets
    @IBOutlet weak var menuLogoImage: UIImageView!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var pastOrdersButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Stack Menu tapped function
        hamburger.target = self
        hamburger.action = #selector(menuTapped(_:))
        
        curvedMenu.image = #imageLiteral(resourceName: "curvedMenu")
        hideMenu()
        
        // Instantiate sign-in UI from the SDK library
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            AWSAuthUIViewController
                .presentViewController(with: self.navigationController!,
                                       configuration: nil,
                                       completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                        if error != nil {
                                            print("Error occurred: \(String(describing: error))")
                                        } else {
                                            // Sign in successful.
                                        }
                })
        }

    }

    // MARK: - Hides menu when screen is tapped
    @IBAction func screenTapped(_ sender: Any)
    {
      hideMenu()
    }
    
    // MARK: - Shows or Hides menu when menu button is tapped
    @objc
    func menuTapped(_ sender: UIBarButtonItem)
    {
        if menu.isHidden == false
        {
            hideMenu()
        } else {
            showMenu()
        }
    }
    
    // MARK: - Logout user on logout menu button tap
    @IBAction func logoutTapped(_ sender: UIButton) {
        AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
            
            // print("Sign-out Successful: \(signInProvider.getDisplayName)");
            self.showSignIn()
        })
    }
    
    // MARK: - Show AWSAuthUI signin view
    func showSignIn() {
        AWSAuthUIViewController.presentViewController(with: self.navigationController!, configuration: nil, completionHandler: {
            (provider: AWSSignInProvider, error: Error?) in
            if error != nil {
                print("Error occurred: \(String(describing: error))")
            } else {
                print("Sign-in successful.")
                
            }
        })
    }
    
    // MARK: - Show menu animation
    func showMenu()
    {
        self.menu.isHidden = false
        // set menu content
        self.menuLogoImage.layer.cornerRadius = menuLogoImage.frame.height/2
        
        UIView.animate(withDuration: 0.4) {
            self.screenButton.alpha = 1
        }
        
        // curved menu
        UIView.animate(withDuration: 0.4, delay: 0.3, options: .curveEaseOut, animations: {
            self.curvedMenu.transform = .identity
        })
        
        // middle menu component (order)
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.orderButton.transform = .identity
        })
        
        // 2 next menu components (about and past orders)
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.aboutButton.transform = .identity
            self.pastOrdersButton.transform = .identity
        })
        
        // 2 outter menu components (image and logout)
        UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.menuLogoImage.transform = .identity
            self.logoutButton.transform = .identity
        })
    }
    
    // MARK: - Hide menu animation
    func hideMenu()
    {
        // set menu content
        UIView.animate(withDuration: 0.4) {
            self.screenButton.alpha = 0
        }
        
        // 2 outter menu components (image and logout)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.menuLogoImage.transform = CGAffineTransform(translationX: -self.menu.frame.width, y: 0)
            self.logoutButton.transform = CGAffineTransform(translationX: -self.menu.frame.width, y: 0)
        })
        
        // 2 next menu components (about and past orders)
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.aboutButton.transform = CGAffineTransform(translationX: -self.menu.frame.width, y: 0)
            self.pastOrdersButton.transform = CGAffineTransform(translationX: -self.menu.frame.width, y: 0)
        })
        
        // curved menu
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut, animations: {
            self.curvedMenu.transform = CGAffineTransform.init(translationX: -self.curvedMenu.frame.width, y: 0)
        })
        
        // middle menu component (order)
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.orderButton.transform = CGAffineTransform(translationX: -self.menu.frame.width, y: 0)
        }) { success in
            self.menu.isHidden = true
        }
    }
    
}

