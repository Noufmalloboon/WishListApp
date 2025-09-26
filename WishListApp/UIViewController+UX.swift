//
//  UIViewController+UX.swift
//  WishListApp
//
//  Created by Nouf Alloboon on 04/04/1447 AH.
//

import Foundation

import UIKit

extension UIViewController {
    // Alert
    func showAlert(title: String, message: String, okTitle: String = "OK") {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: okTitle, style: .default, handler: nil))
        present(ac, animated: true)
    }

    // Action Sheet
    func showConfirmSheet(title: String,
                          message: String?,
                          confirmTitle: String = "Delete",
                          cancelTitle: String = "Cancel",
                          confirmStyle: UIAlertAction.Style = .destructive,
                          onConfirm: @escaping () -> Void) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: confirmTitle, style: confirmStyle, handler: { _ in onConfirm() }))
        ac.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        present(ac, animated: true)
    }

    // Toast (at the bottom)
    func showToast(_ text: String, seconds: TimeInterval = 1.4) {
        let label = PaddingLabel()
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.alpha = 0.0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        label.textColor = .white
        label.layer.cornerRadius = 12
        label.clipsToBounds = true

        // size and place
        let maxWidth = view.bounds.width * 0.9
        label.frame.size = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        label.sizeToFit()
        label.frame.size.width = min(label.frame.width + 24, maxWidth)
        label.frame.size.height += 16
        label.center = CGPoint(x: view.center.x, y: view.bounds.height - 100)

        view.addSubview(label)

        UIView.animate(withDuration: 0.25, animations: {
            label.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: seconds, options: [], animations: {
                label.alpha = 0.0
            }) { _ in
                label.removeFromSuperview()
            }
        }
    }
}

// New small class to make the code DRY
final class PaddingLabel: UILabel {
    let insets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right,
                      height: s.height + insets.top + insets.bottom)
    }
}










