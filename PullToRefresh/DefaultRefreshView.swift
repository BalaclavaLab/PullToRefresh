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

    fileprivate(set) var activityIndicator: UIActivityIndicatorView?

    override func layoutSubviews() {
        if activityIndicator == nil {
            activityIndicator = {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                activityIndicator.hidesWhenStopped = true
                activityIndicator.color = UIColor.black
                activityIndicator.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                addSubview(activityIndicator)
                return activityIndicator
            }()
        }
        centerActivityIndicator()
        setupFrameInSuperview(superview)
        super.layoutSubviews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setupFrameInSuperview(superview)
    }
}

private extension DefaultRefreshView {
    
    func setupFrameInSuperview(_ newSuperview: UIView?) {
        if let superview = newSuperview {
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: superview.frame.width, height: frame.height)
        }
    }
    
     func centerActivityIndicator() {
        if let activityIndicator = activityIndicator {
            activityIndicator.center = convert(center, from: superview)
            activityIndicator.center.y += (sectionInsetBottom - sectionInsetTop) / 2
        }
    }
}
