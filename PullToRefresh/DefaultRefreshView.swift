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

    private(set) var activityIndicator: UIActivityIndicatorView?

    override func layoutSubviews() {
        if activityIndicator == nil {
            activityIndicator = {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
                activityIndicator.hidesWhenStopped = true
                activityIndicator.color = UIColor.blackColor()
                activityIndicator.transform = CGAffineTransformMakeScale(0.75, 0.75)
                addSubview(activityIndicator)
                return activityIndicator
            }()
        }
        centerActivityIndicator()
        setupFrameInSuperview(superview)
        super.layoutSubviews()
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        setupFrameInSuperview(superview)
    }
}

private extension DefaultRefreshView {
    
    func setupFrameInSuperview(newSuperview: UIView?) {
        if let superview = newSuperview {
            frame = CGRectMake(frame.origin.x, frame.origin.y, superview.frame.width, frame.height)
        }
    }
    
     func centerActivityIndicator() {
        if let activityIndicator = activityIndicator {
            activityIndicator.center = convertPoint(center, fromView: superview)
            activityIndicator.center.y += (sectionInsetBottom - sectionInsetTop) / 2
        }
    }
}
