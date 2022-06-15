//
//  SceneDelegate.swift
//  testingCoreML
//
//  Created by Тоха on 15.06.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let controller = CatViewController()
        let presenter = CatViewPresenter()
        controller.presenter = presenter
        presenter.output = controller
        window?.rootViewController = controller
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

