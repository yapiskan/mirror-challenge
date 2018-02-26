//
//  EditAccountViewController.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation

class EditAccountViewController: BaseViewController {
    private let viewModel: AccountViewModelProtocol
    
    init(viewModel: AccountViewModelProtocol, router: AppRouter) {
        self.viewModel = viewModel
        super.init(router: router)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        title = "Edit Account"
    }
}
