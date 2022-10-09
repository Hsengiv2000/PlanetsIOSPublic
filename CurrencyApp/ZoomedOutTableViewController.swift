//
//  ZoomedOutTableViewController.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 20/12/22.
//

import Foundation
import UIKit

class ZoomedOutTableViewController: ViewController {
    
    public let tableView: UITableView
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
