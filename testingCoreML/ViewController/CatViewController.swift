//
//  ViewController.swift
//  testingCoreML
//
//  Created by Тоха on 15.06.2022.
//

import UIKit

protocol BaseController: AnyObject {
    var presenter: BasePresenter? { get set }
}

class CatViewController: UIViewController, BaseController {

    weak var presenter: BasePresenter?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }


}

