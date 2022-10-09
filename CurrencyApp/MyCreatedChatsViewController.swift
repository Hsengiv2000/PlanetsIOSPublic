//
//  MyCreatedChatsViewController.swift
//  CurrencyApp
//
//  Created by RahulMacbook on 22/12/22.
//

import Foundation
import UIKit


//The idea is to have your chats, long press on it to edit
class MyCreatedChatsViewController: ViewController {
    
    private let currentUserChatsManager: CurrentUserChatsManager
    private let tableView: UITableView = UITableView()
    private var myChats: [ChatGroupModel] {
        return currentUserChatsManager.userChats.value.filter({$0.celebID == currentUserChatsManager.currentUserID})
    }
    private let uiFactory: UIFactory
    
    private var indexPathMap: [GroupID: IndexPath] = [:]
    internal var arrowExpandCache: [GroupID: Bool] = [:]
    
    init(currentUserChatsManager: CurrentUserChatsManager, uiFactory: UIFactory) {
        self.currentUserChatsManager = currentUserChatsManager
        self.uiFactory = uiFactory
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecommendedChatsCell.self, forCellReuseIdentifier: "MyChatsCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        self.title = "Chats I created"
        
    }
    
    
    private func setupUI() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MyCreatedChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecommendedChatsCell = self.tableView.dequeueReusableCell(withIdentifier: "MyChatsCell") as! RecommendedChatsCell
        indexPathMap[myChats[indexPath.row].groupID] = indexPath
             // set the text from the data model
        //TODO EXPIRY
        print("EXPIRY TIME IS ",myChats[indexPath.row].startTime, " CURRENT TIME IS", NSDate().timeIntervalSince1970 )
        
        cell.update(groupModel: myChats[indexPath.row],hasStarted: myChats[indexPath.row].startTime ?? 0 <= NSDate().timeIntervalSince1970, isMine: myChats[indexPath.row].celebID == currentUserChatsManager.currentUser.userID)
        
        cell.didTapEnterJoin = { [weak self ] in
            guard let me = self else { return }
            switch me.myChats[indexPath.row].joinPaidStatus {
            case .joined:
                me.navigationController?.pushViewController( me.uiFactory.chatWallVC(group: me.myChats[indexPath.row], userModel: me.currentUserChatsManager.currentUser ), animated: true)
            case .none, .paid:
                break
            }
        }
        
        cell.recommendedChatView.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myChats.count
    }
}

extension MyCreatedChatsViewController: RecommendedChatViewDelegate {
   
    func obtainArrowExpansion(groupID: GroupID) -> Bool {
        arrowExpandCache[groupID] ?? true
    }
    
    func didTapArrow(groupID: GroupID) {
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
