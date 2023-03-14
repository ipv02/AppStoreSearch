//
//  SceneDelegate.swift
//  AppStoreSearch
//
//  Created by Igor P-V on 14.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let searchNC = UINavigationController(rootViewController: SearchViewController())
        searchNC.navigationBar.prefersLargeTitles = true
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = searchNC
        window?.makeKeyAndVisible()
    }
}

