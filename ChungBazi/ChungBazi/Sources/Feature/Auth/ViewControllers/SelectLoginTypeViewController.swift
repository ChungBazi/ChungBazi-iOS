//
//  SelectLoginTypeViewController.swift
//  ChungBazi
//

import UIKit

class SelectLoginTypeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = selectLoginView
    }
    
    private lazy var selectLoginView = SelectLoginView()
}
