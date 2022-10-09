//
//  MessageCollectionViewCellActions.swift
//  CurrencyApp
//
//  Created by Rahul Parthasarathy on 23/11/22.
//

import Foundation
import MessageKit

extension MessageCollectionViewCell {
    @objc func thread(_ sender: Any?) {
        
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                collectionView.delegate?.collectionView?(collectionView, performAction: #selector(MessageCollectionViewCell.thread(_:)), forItemAt: indexPath, withSender: sender)
            }
        }
    }
    
    @objc func viewthread(_ sender: Any?) {
        
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                collectionView.delegate?.collectionView?(collectionView, performAction: #selector(MessageCollectionViewCell.viewthread(_:)), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}
