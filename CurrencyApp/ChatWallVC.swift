//
//  ChatWallVC.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 15/11/22.
//

import Foundation

import InputBarAccessoryView
import MessageKit
import UIKit
import Kingfisher


// MARK: - ChatViewController

/// A base class for the example controllers
class ChatWallViewController: MessagesViewController {
    
    private let currentUser: UserModel
    private let currentSenderType: SenderType
    private let chatGroupManager: ChatGroupManager
    private let readOnlyView = UIButton().then {
        $0.isHidden = true
        $0.setTitle("READ ONLY GROUP", for: .normal)
        $0.backgroundColor = .gray
        $0.alpha = 0.6
    }
    
    private(set) lazy var refreshControl = UIRefreshControl().then {
        
        $0.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let uiFactory: UIFactory
    
    public init(currentUser: UserModel, chatGroupManager: ChatGroupManager, uiFactory: UIFactory) {
        self.currentUser = currentUser
        self.currentSenderType = Sender(senderID: currentUser.userID, displayName: currentUser.username)
        self.chatGroupManager = chatGroupManager
        self.uiFactory = uiFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(onTapInfo))
        self.view.addSubview(readOnlyView)
        self.hidesBottomBarWhenPushed = true
        self.title = chatGroupManager.currentGroup.groupName
        
        if let _ = chatGroupManager.currentGroup.chatThread {
            self.title = chatGroupManager.currentGroup.groupName + " | thread "
        }
    
        self.messagesCollectionView.messagesDataSource = self
        self.messagesCollectionView.messagesLayoutDelegate = self
        self.messagesCollectionView.messagesDisplayDelegate = self
        self.messageInputBar.delegate = self
        messagesCollectionView.refreshControl = refreshControl
        configureMessageInputBar()
        self.chatGroupManager.fetchMessages().on(value: { [ weak self] _ in
            guard let me = self else { return }
            me.messagesCollectionView.reloadData()
            me.messagesCollectionView.scrollToLastItem(animated: false)
        }).start()
        setupEvents()
        readOnlyView.snp.makeConstraints { make in
            make.width.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatGroupManager.joinRoom()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chatGroupManager.leaveRoom()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupEvents() {
        chatGroupManager.newMessageSignal.take(duringLifetimeOf: self).observeResult { [weak self] result in
            guard let me = self else { return }
            if case let .success(newMessage) = result {
                print("ACKNOWLEDGEMENT RECEIVED GOAT")
                me.receivedMessage(message: newMessage)
            }
        }
        
        setupMessageActions()
        
    }
    
    private func setupMessageActions() {
        var menuItems: [UIMenuItem] = []
        let threadItem = UIMenuItem(title: "thread", action: #selector(MessageCollectionViewCell.thread(_:)))
        menuItems.append(threadItem)
        let viewthreadItem = UIMenuItem(title: "viewthread", action: #selector(MessageCollectionViewCell.viewthread(_:)))
        menuItems.append(viewthreadItem)
        UIMenuController.shared.menuItems = menuItems
    }
    
    private func receivedMessage(message: Message) {
        // Reload last section to update header/footer labels and insert a new one
        if self.viewIfLoaded?.window != nil {
            // viewController is visible
            
            DispatchQueue.main.async { [weak self] in
                guard let me = self else { return }
                me.chatGroupManager.messages.append(message)
                me.messagesCollectionView.performBatchUpdates({
                    me.messagesCollectionView.insertSections([me.chatGroupManager.messages.count - 1])
                    if me.chatGroupManager.messages.count >= 2 {
                        me.messagesCollectionView.reloadSections([me.chatGroupManager.messages.count - 2])
                    }
                }, completion: { [weak me] _ in
                    guard let myself = me else { return }
                    if myself.isLastSectionVisible() == true || message.sender.senderId == myself.currentUser.userID {
                        myself.messagesCollectionView.scrollToLastItem(animated: true)
                    }
                })
            }
            
        }
    }
    
    @objc private func onTapInfo(_ sender: UIButton)
    {
        //todo
//        navigationController?.pushViewController(uiFactory.checkoutViewController(groupModel: chatGroupManager.currentGroup, onPayment: nil), animated: true)
    }
    
    @objc func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let me = self else { return }
            me.chatGroupManager.fetchMessages().on(value: { [weak me] _ in
                guard let myself = me else { return }
                DispatchQueue.main.async {
                    myself.messagesCollectionView.reloadDataAndKeepOffset()
                    myself.refreshControl.endRefreshing()
                }
                
            }).start()
            
        }
    }
    
    
    //Override stuff
    
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if action == NSSelectorFromString("thread:") {
            return chatGroupManager.currentGroup.celebID == chatGroupManager.currentUser.userID && chatGroupManager.currentGroup.chatThread == nil && chatGroupManager.messages[indexPath.section].chatThread == nil
        } else if action == NSSelectorFromString("viewthread:") {
            return chatGroupManager.messages[indexPath.section].chatThread != nil
        }
        else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
    
    func configureMessageInputBar() {
        // super.configureMessageInputBar()
        messageInputBar = CustomInputBarAccessoryView()
        messageInputBar.delegate = self
        if !chatGroupManager.canChat {
            self.messageInputBar.isHidden = true
            self.readOnlyView.isHidden = false
        }
        
    }
    
    private func updateMessagesRefreshTable(_ indexPath: IndexPath ) {
        DispatchQueue.main.async { [weak self] in
            guard let me = self else { return }
            me.messagesCollectionView.reloadSections([indexPath.section])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        if action == NSSelectorFromString("thread:") {
            chatGroupManager.createThread(message: chatGroupManager.messages[indexPath.section], index: indexPath.section).on(value: { [weak self] thread in
                guard let me = self else { return }
                var message = me.chatGroupManager.messages[indexPath.section]
                me.chatGroupManager.messages[indexPath.section] = Message(sender: message.sender, messageId: message.messageId, groupID: message.groupID, sentDate: message.sentDate, kind: message.kind, chatThread: thread, threadID: thread.threadID)
                me.updateMessagesRefreshTable(indexPath)
                me.navigationController?.pushViewController(me.uiFactory.chatWallVC(group: ChatGroupModel(chatGroupModel: me.chatGroupManager.currentGroup, chatThread: thread), userModel: me.chatGroupManager.currentUser), animated: true)
            }).start()
        } else if action == NSSelectorFromString("viewthread:") {
            if let thread = chatGroupManager.messages[indexPath.section].chatThread {
                navigationController?.pushViewController(uiFactory.chatWallVC(group: ChatGroupModel(chatGroupModel: chatGroupManager.currentGroup, chatThread: thread ), userModel: chatGroupManager.currentUser), animated: true)
            }
            
        }
        else {
            super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        }
    }
}


extension ChatWallViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return currentSenderType
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        //        Message(sender: currentSenderType, messageId: MessageID(indexPath.section), sentDate: Date(), kind: .text("HEIAOFIEIOAF + " + String(indexPath.section)))
        chatGroupManager.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        //chatGroupManager.messages.value.count
        chatGroupManager.messages.count
    }
    
    
    func isLastSectionVisible() -> Bool {
        guard !chatGroupManager.messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: chatGroupManager.messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
}


extension ChatWallViewController: MessagesDisplayDelegate {
    
    func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and _: MessageType, at _: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? UIColor(red: 0 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1) : UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
        
        if let userModel = chatGroupManager.groupMembers.first(where: {$0.userID == message.sender.senderId}), let urlString = userModel.imageURL {
            
            if let imageURL = URL(string: urlString) {
                KingfisherManager.shared.retrieveImage(with: imageURL, options: nil, progressBlock: nil) { result in
                    switch result {
                    case .success(let value):
                        
                        let avatar = Avatar(image: value.image)
                        
                        avatarView.set(avatar: avatar)
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            }
        } else {
            let avatar = Avatar(image: UIImage(systemName: "magnifyingglass"))
            
            avatarView.set(avatar: avatar)
        }
        
    }
    
    
    
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView)
    {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.kf.setImage(with: imageURL)
        } else {
            imageView.kf.cancelDownloadTask()
        }
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        var name = message.sender.displayName
        if let newMessage = chatGroupManager.messages.first(where: {$0.messageId == message.messageId}) {
            if newMessage.chatThread != nil {
                name = "🧵" + name
            }
        }
        return NSAttributedString(
            string: name,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let sentDate = message.sentDate
        let sentDateString = MessageKitDateFormatter.shared.string(from: sentDate)
        let timeLabelFont: UIFont = .boldSystemFont(ofSize: 10)
        let timeLabelColor: UIColor
        if #available(iOS 13, *) {
            timeLabelColor = .systemGray
        } else {
            timeLabelColor = .darkGray
        }
        
        print(NSAttributedString(string: sentDateString, attributes: [NSAttributedString.Key.font: timeLabelFont, NSAttributedString.Key.foregroundColor: timeLabelColor]))
        return NSAttributedString(string: sentDateString, attributes: [NSAttributedString.Key.font: timeLabelFont, NSAttributedString.Key.foregroundColor: timeLabelColor])
    }
    
    
    func animationBlockForLocation(
        message _: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView) -> ((UIImageView) -> Void)?
    {
        { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    view.layer.transform = CATransform3DIdentity
                },
                completion: nil)
        }
    }
    
    
    // MARK: - Audio Messages
    func audioTintColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
    }
    
    
}



extension ChatWallViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        18
    }
    
    func cellBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        17
    }
    
    func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        20
    }
    
    func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        16
    }
}


extension ChatWallViewController: InputBarAccessoryViewDelegate {
    
    @objc
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        processInputBar(messageInputBar)
    }
    
    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }
        
        let messageText: String = inputBar.inputTextView.text
        
        chatGroupManager.sendMessage(text: messageText )
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        // inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                //   inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                guard let me = self else { return }
                
            }
        }
    }
}


extension ChatWallViewController: CustomInputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        for item in attachments {
            if case .image(let image) = item {
                self.sendImageMessage(photo: image)
            }
        }
        inputBar.invalidatePlugins()
    }
    
    func sendImageMessage(photo: UIImage) {
        chatGroupManager.sendImageMessage(photo: photo)
    }
    
    func inputBar(_: InputBarAccessoryView, shouldShowAlert alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func inputBar(_: InputBarAccessoryView, shouldShowImagePicker imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func inputBarShouldDismiss(_: InputBarAccessoryView) {
        dismiss(animated: true, completion: nil)
    }
}
