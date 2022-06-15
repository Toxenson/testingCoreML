//
//  CatViewPresenter.swift
//  testingCoreML
//
//  Created by Тоха on 15.06.2022.
//

import CoreML

protocol BasePresenter: AnyObject {
    var output: BaseController? { get set }
}

protocol CatViewPresenterOutput: AnyObject {
    
}

class CatViewPresenter: BasePresenter {
    var output: BaseController?
    
}
