//
//  CustomTabBar.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import UIKit
import NoveFeatherIcons
import FirebaseAuth

class CustomTabBar: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        UITabBar.appearance().barTintColor = .systemBackground
        //tabBar.tintColor = .label
        setupVCs()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    func setupVCs() {
        viewControllers = [TableViewController()
            //createNavController(for: TableViewController(), title: NSLocalizedString("ToDo", comment: ""), image: Feather.getIcon(.penTool)!)
        ]
    }
    
    private func validateAuth(){
        guard let firebaseUser = FirebaseAuth.Auth.auth().currentUser, let user = UserManager.shared.getUserDefault(), user.userID == firebaseUser.uid, firebaseUser.isEmailVerified else {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen //so user can not dismiss login page
            present(nav, animated: false)
            
            return
        }
    }
    
    fileprivate func createNavController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = ""
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
        navController.tabBarItem.image = image
        navController.navigationBar.prefersLargeTitles = true
        navController.isNavigationBarHidden = true
        return navController
    }
}
