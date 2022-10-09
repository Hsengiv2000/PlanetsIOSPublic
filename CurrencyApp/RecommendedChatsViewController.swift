//
//  RecommendedChatsViewController.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 18/11/22.
//

import Foundation
import UIKit

class RecommendedChatsViewController: ViewController {
    
    
    private let refreshControl = UIRefreshControl()
    
    
    private let tableView = UITableView().then{
        $0.backgroundColor = .darkGray
        $0.separatorStyle = .none
    }
    
    private let recommendedChatsManager: RecommendedChatsManager?
    private let uiFactory: UIFactory
    private var indexPathMap: [GroupID: IndexPath] = [:]
    internal var arrowExpandCache: [GroupID: Bool] = [:]
    
    init(recommendedChatsManager: RecommendedChatsManager?, uiFactory: UIFactory) {
        self.recommendedChatsManager = recommendedChatsManager
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
        self.title = "Explore"
        guard let recommendedChatsManager = recommendedChatsManager else {
            return
        }

        recommendedChatsManager.fetchRecommendedChats()
        super.viewDidLoad()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
    }
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    private func setupEvents() {
        tableView.register(RecommendedChatsCell.self, forCellReuseIdentifier: "RecommendedChatsCell")
        guard let recommendedChatsManager = recommendedChatsManager else {
            return
        }
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        recommendedChatsManager.recommendedChats.signal.take(duringLifetimeOf: self).observeValues { [weak self] groups in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        recommendedChatsManager?.fetchRecommendedChats()
        
    }
}


extension RecommendedChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recommendedChatsManager = recommendedChatsManager else {
            return 0
        }
        return recommendedChatsManager.recommendedChats.value.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let recommendedChatsManager = recommendedChatsManager else {
            return UITableViewCell()
        }
        let cell: RecommendedChatsCell = self.tableView.dequeueReusableCell(withIdentifier: "RecommendedChatsCell") as! RecommendedChatsCell
            
        let chats  = recommendedChatsManager.recommendedChats.value
        indexPathMap[chats[indexPath.row].groupID] = indexPath
             // set the text from the data model
        print("EXPIRY TIME IS ",chats[indexPath.row].startTime, " CURRENT TIME IS", NSDate().timeIntervalSince1970 )
        cell.update(groupModel: chats[indexPath.row],hasStarted: chats[indexPath.row].startTime ?? 0 <= NSDate().timeIntervalSince1970, isMine: chats[indexPath.row].celebID == recommendedChatsManager.currentUser.userID)
        cell.didTapEnterJoin = { [weak self ] in
            guard let me = self else { return }
            
            switch chats[indexPath.row].joinPaidStatus {
            case .joined:
                me.navigationController?.pushViewController( me.uiFactory.chatWallVC(group: chats[indexPath.row], userModel: me.recommendedChatsManager!.currentUser ), animated: true)
            case .paid:
                //todo break
                break
//                me.navigationController?.pushViewController(me.uiFactory.checkoutViewController(groupModel: chats[indexPath.row], onPayment: { [weak me] paymentResult, amount, currency in
//                    guard let myself = me else { return }
//                }), animated: true)
            case .none:
                me.navigationController?.pushViewController(me.uiFactory.selectPackagesViewController(groupModel: chats[indexPath.row]), animated: true)
//                me.navigationController?.pushViewController(me.uiFactory.checkoutViewController(groupModel: chats[indexPath.row], onPayment: { [weak me] paymentResult, amount, currency in
//                    guard let myself = me else { return }
//                    if case let .completed = paymentResult {
//                        myself.recommendedChatsManager?.removeChat(groupID: chats[indexPath.row].groupID)
//                    }
//                }), animated: true)
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



extension RecommendedChatsViewController: RecommendedChatViewDelegate {
   
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
