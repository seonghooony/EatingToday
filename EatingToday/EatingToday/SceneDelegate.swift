//
//  SceneDelegate.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/16.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: scene.coordinateSpace.bounds)
        window?.windowScene = scene
        sleep(1)
        let firstViewController = LoginViewController()
        let navigationController = UINavigationController(rootViewController: firstViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

                
        
    }

    
}

