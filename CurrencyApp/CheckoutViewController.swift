//
//  CheckoutViewController.swift
//  CurrencyApp
//
//  Created by BigoSG on 8/12/22.
//

import Foundation
import UIKit
import StripePaymentSheet

class CheckoutViewController: ViewController {
    
    private let leaveGroupButton = UIButton().then {
        $0.setTitle("LEAVE GROUP", for: .normal)
        $0.backgroundColor = .white
        $0.setTitleColor(.red, for: .normal)
        $0.layer.borderColor = UIColor.red.cgColor
        $0.layer.borderWidth = 2
    }
    
    
    private let checkoutButton = UIButton().then {
        $0.setTitle("Checkout with Amount", for: .normal)
        $0.backgroundColor = .green
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.setTitleColor(.blue, for: .normal)
        
    }
    
    private let purchasesTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.isHidden = true
    }
    
    private let amountBox = UITextView().then {
        $0.keyboardType = .numberPad
        $0.backgroundColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 30)
    }
    private let kickoutTimeLabel = UILabel()
    
    private let checkoutManager: CheckoutManager
    private let chatGroupModel: ChatGroupModel
    private let groupView = RecommendedChatsView()
    private var isArrowExpanded: Bool = true
    private let onPayment: ((PaymentSheetResult, Float, String) -> ())?
    private let chatPackage: ChatGroupPackage
    
    public init(groupModel: ChatGroupModel, checkoutManager: CheckoutManager, chatPackage: ChatGroupPackage, onPayment: ((PaymentSheetResult, Float, String)->())?) {
        self.chatGroupModel = groupModel
        self.checkoutManager = checkoutManager
        self.onPayment = onPayment
        self.chatPackage = chatPackage
        
        groupView.update(groupModel: groupModel, hideButton: groupModel.joinPaidStatus.rawValue == 2, hasStarted: chatGroupModel.startTime ?? 0 <= NSDate().timeIntervalSince1970  , isMine: chatGroupModel.celebID == checkoutManager.currentUserID)
        
        
        super.init()
        groupView.delegate = self
        purchasesTableView.register(IndividualPaymentsCell.self, forCellReuseIdentifier: "IndividualPaymentsCell")
        purchasesTableView.delegate = self
        purchasesTableView.dataSource = self
    }
    
    var paymentSheet: PaymentSheet?
   
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(groupView)
        view.addSubview(checkoutButton)
        view.addSubview(amountBox)
        view.addSubview(purchasesTableView)
        view.addSubview(kickoutTimeLabel
        )
        if chatGroupModel.joinPaidStatus.rawValue == 2 {
            leaveGroupButton.addTarget(self, action: #selector(didLeaveGroup), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: leaveGroupButton)
        }
        
        amountBox.snp.makeConstraints { make in
            make.top.equalTo(groupView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(60)
            make.height.equalTo(50)
            
        }
        
        checkoutButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.equalTo(amountBox.snp.bottom).offset(5)
            make.height.equalTo(70)
        }
        groupView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(250)
        }
        purchasesTableView.snp.makeConstraints {make in
            make.top.equalTo(checkoutButton.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-100)
            make.leading.trailing.equalToSuperview()
        }
        kickoutTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(amountBox.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(130)
            make.height.equalTo(60)
        }
        view.backgroundColor = .white
        checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        
        checkoutButton.isUserInteractionEnabled = true
        checkoutButton.isHidden = chatGroupModel.joinPaidStatus.rawValue == 2
        amountBox.isHidden = chatGroupModel.joinPaidStatus.rawValue == 2
        // MARK: Fetch the PaymentIntent client secret, Ephemeral Key secret, Customer ID, and publishable key
        
        
        
        amountBox.text = String(chatPackage.amount)
        kickoutTimeLabel.text = chatPackage.kickoutTime == nil ? "No Kickout Time" : "Expires after seconds: " + String(chatPackage.kickoutTime!)
            
            
        
    }
    
    @objc private func didLeaveGroup() {
        showYesNoBox(heading: "Leaving..?", txt: "will miss you", yesHandler: { [weak self] _ in
            guard let me = self else { return }
            me.checkoutManager.leaveGroup(groupID: me.chatGroupModel.groupID).on(value: {[weak me] _ in
                me?.showSuccessToast("Left group")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    me?.navigationController?.popViewController(animated: true)
                }
            }).start()
        })
    }
    
    @objc
    func didTapCheckoutButton() {
        if amountBox.text == "" {
            showErrorToast("pls enter amount")
            return
        }
        
//        if chatGroupModel.startTime ?? 0 < NSDate().timeIntervalSince1970 {
//            showErrorToast("Group Started bromigo")
//            return
//            
//        }
        checkoutManager.obtainProductPaymentIntent(groupID: chatGroupModel.groupID, amount: chatPackage.amount, kickoutTime: chatPackage.kickoutTime).on(started: { [weak self] in
            guard let me = self else { return }
            DispatchQueue.main.async {
                me.startLoadingAnimation()
            }
        }).on(value: { [weak self] paymentIntent in
            guard let me = self else { return }
            
            STPAPIClient.shared.publishableKey = paymentIntent.publishableKey
            // MARK: Create a PaymentSheet instance
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Planets, Inc."
            configuration.customer = .init(id: paymentIntent.customer, ephemeralKeySecret: paymentIntent.ephemeralKey)
            // Set `allowsDelayedPaymentMethods` to true if your business can handle payment
            // methods that complete payment after a delay, like SEPA Debit and Sofort.
            configuration.allowsDelayedPaymentMethods = true
            me.paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntent.paymentIntent, configuration: configuration)
            
            DispatchQueue.main.async {
                me.stopLoadingAnimation()
                me.checkoutButton.isEnabled = false
                me.paymentSheet?.present(from: me) { paymentResult in
                    var handler: ((UIAlertAction)->()) = { [weak me] _ in
                        guard let myself = me else { return }
                        myself.checkoutButton.isEnabled = true
                        //TODO
                        myself.onPayment?(paymentResult, Float(myself.amountBox.text ?? "0") ?? 0, "sgd")
                        switch paymentResult {
                        case .completed:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                myself.navigationController?.popViewController(animated: true)
                            }
                        case .canceled:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                myself.navigationController?.popViewController(animated: true)
                            }
                        case .failed(let _):
                            break
                        }
                    }
                    switch paymentResult {
                    case .completed:
                        
                        let individualPaymentObject = IndividualPaymentModel(createdAt: Float(NSDate().timeIntervalSince1970), amount: (Float(me.amountBox.text ?? "0") ?? 0) * 100, currency: "sgd", groupID: me.chatGroupModel.groupID)
                        me.checkoutManager.appendPayment(individualPaymentObject: individualPaymentObject)
                        me.showSuccessToast("Your order is confirmed", handler: handler)
                    case .canceled:
                        me.showErrorToast("Payment Cancelled", handler: handler)
                    case .failed(let error):
                        me.showErrorToast("Payment failed: \(error)", handler: handler)
                    }
                }
            }
        }).start()
        
        
    }
    
}

extension CheckoutViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        purchasesTableView.isHidden = (checkoutManager.paymentDict[chatGroupModel.groupID]?.count ?? 0) == 0
     
        return checkoutManager.paymentDict[chatGroupModel.groupID]?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let individualPayments = checkoutManager.paymentDict[chatGroupModel.groupID], individualPayments.count >= indexPath.row {
            let cell: IndividualPaymentsCell = self.purchasesTableView.dequeueReusableCell(withIdentifier: "IndividualPaymentsCell") as! IndividualPaymentsCell
            cell.update(individualPaymentModel: individualPayments[indexPath.row], groupName: chatGroupModel.groupName)
            return cell
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Payment History: " + String((checkoutManager.groupAmountDict[chatGroupModel.groupID] ?? 0 ) / 100 ) + " sgd"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        
        headerView.addSubview(label)
        headerView.backgroundColor = .darkGray
        
        return headerView
    }
 
}


extension CheckoutViewController: RecommendedChatViewDelegate {
    func obtainArrowExpansion(groupID: GroupID) -> Bool {
        return isArrowExpanded
    }
    
    func didTapArrow(groupID: GroupID) {
        
        isArrowExpanded = !isArrowExpanded
    }
}
