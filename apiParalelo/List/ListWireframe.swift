//
//  ListWireframe.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 1/3/24.
//

import Foundation
import UIKit

class ListWireframe {
    
    var viewController: ListViewController {
        let viewController = ListViewController(nibName: "ListViewController", bundle: nil)
        
        let dataManager = createDataManagerV3()
        let viewModel = createViewModelV3(with: dataManager)
        
        viewController.viewModel = viewModel
        
        return viewController
    }

    private func createDataManagerV3() -> ListDataManager {
        return ListDataManager()
    }

    private func createViewModelV3(with dataManager: ListDataManager) -> ListViewModel {
        return ListViewModel(dataManager: dataManager)
    }

}
