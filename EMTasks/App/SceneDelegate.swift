//
//  SceneDelegate.swift
//  EMTasks
//
//  Created by Евгений Лукин on 21.03.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let mainVC = TasksListViewController()
        
        window?.rootViewController = mainVC
        
        window?.makeKeyAndVisible()
    }
}
