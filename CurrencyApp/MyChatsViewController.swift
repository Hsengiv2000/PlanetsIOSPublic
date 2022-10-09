//
//  MyChatsViewController.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 12/12/22.
//

import Foundation
import UIKit

class MyChatsViewController: ViewController {
    
    private let refreshControl = UIRefreshControl()
    
    private let searchBar = UISearchBar().then {
        $0.placeholder = "Filter"
        $0.backgroundColor = .darkGray
    }
    
    private let tableView = UITableView().then{
        $0.backgroundColor = .darkGray
        $0.separatorStyle = .none
    }
    
    private let currentUserChatsManager: CurrentUserChatsManager
    private let uiFactory: UIFactory
    private var currentChats: [ChatGroupModel] = []
    private var arrowExpandCache: [GroupID: Bool] = [:]
    private var indexPathMap: [GroupID: IndexPath] = [:]
    init(currentUserChatsManager: CurrentUserChatsManager, uiFactory: UIFactory) {
        self.currentUserChatsManager = currentUserChatsManager
        self.uiFactory = uiFactory
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        setupConstraints()
        setupEvents()
        self.title = "My Chats"

        currentUserChatsManager.fetchUserChats()
        super.viewDidLoad()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(searchBar)
        searchBar.delegate = self
    }
    private func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(4)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(2)
        }
    }
    private func setupEvents() {
        tableView.register(RecommendedChatsCell.self, forCellReuseIdentifier: "MyChatsCell")
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        currentUserChatsManager.userChats.signal.take(duringLifetimeOf: self).observeValues { [weak self] groups in
            self?.currentChats = groups
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        currentUserChatsManager.fetchUserChats()
    }
}


extension MyChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        
        return currentChats.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: RecommendedChatsCell = self.tableView.dequeueReusableCell(withIdentifier: "MyChatsCell") as! RecommendedChatsCell
            
             // set the text from the data model
        //TODO EXPIRY
        print("EXPIRY TIME IS ",currentChats[indexPath.row].startTime, " CURRENT TIME IS", NSDate().timeIntervalSince1970 )
        indexPathMap[currentChats[indexPath.row].groupID] = indexPath
        cell.update(groupModel: currentChats[indexPath.row],hasStarted: currentChats[indexPath.row].startTime ?? 0 <= NSDate().timeIntervalSince1970, isMine: currentChats[indexPath.row].celebID == currentUserChatsManager.currentUser.userID)
        
        cell.didTapEnterJoin = { [weak self ] in
            guard let me = self else { return }
            switch me.currentChats[indexPath.row].joinPaidStatus {
            case .joined:
                me.navigationController?.pushViewController( me.uiFactory.chatWallVC(group: me.currentChats[indexPath.row], userModel: me.currentUserChatsManager.currentUser ), animated: true)
            case .paid:
                break
//                me.navigationController?.pushViewController(me.uiFactory.checkoutViewController(groupModel: me.currentChats[indexPath.row], onPayment: { [weak me] paymentResult, amount, currency in
//
//                }), animated: true)
            case .none:
                break
            }
        }
        cell.recommendedChatView.delegate = self
        return cell
    }
         
         // method to run when table view cell is tapped
         func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
             print("You tapped cell number \(indexPath.row).")
         }
    
}

extension MyChatsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            currentChats = currentUserChatsManager.userChats.value
        } else {
            currentChats = currentUserChatsManager.userChats.value.filter({
                $0.groupName.contains(searchText) || $0.groupDescription.contains(searchText)
            })
        }
        searchBar.showsCancelButton = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

extension MyChatsViewController: RecommendedChatViewDelegate {
   
    func obtainArrowExpansion(groupID: GroupID) -> Bool {
        arrowExpandCache[groupID] ?? true
    }
    
    func didTapArrow(groupID: GroupID) {
        //todo memory leaks
        DispatchQueue.main.async { [weak self] in
            guard let me = self else { return }
            me.arrowExpandCache[groupID] = !(me.arrowExpandCache[groupID] ?? true)
            me.tableView.beginUpdates()
            if let indexpath = me.indexPathMap[groupID] {
                me.tableView.reloadRows(at: [indexpath ], with: .none)
                }
            me.tableView.endUpdates()
            
        }
    }
}
