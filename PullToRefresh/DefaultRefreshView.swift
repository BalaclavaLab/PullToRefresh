//
//  DefaultRefreshView.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class DefaultRefreshView: UIView {
    
    // MARK: - Internal Properties
    
    internal var sectionInsetTop: CGFloat = 0
    
    internal var sectionInsetBottom: CGFloat = 12

    // MARK: - Internal Properties

    fileprivate(set) lazy var activityIndicator: UIActivityIndicatorView! = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        activityIndicator.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75)
        self.addSubview(activityIndicator)
        return activityIndicator
    }()

    override func layoutSubviews() {
        centerActivityIndicator()
        setupFrame(in: superview)
        
        super.layoutSubviews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        centerActivityIndicator()
        setupFrame(in: superview)
    }
}

private extension DefaultRefreshView {
    
    func setupFrame(in newSuperview: UIView?) {
        guard let superview = newSuperview else { return }

        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: superview.frame.width, height: frame.height)
    }
    
     func centerActivityIndicator() {
        if let activityIndicator = activityIndicator {
            activityIndicator.center = convert(center, from: superview)
            activityIndicator.center.y += (sectionInsetBottom - sectionInsetTop) / 2
        }
    }
}
