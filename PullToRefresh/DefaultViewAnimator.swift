//
//  DefaultViewAnimator.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class DefaultViewAnimator: RefreshViewAnimator {
    
    fileprivate let refreshView: DefaultRefreshView
    
    init(refreshView: DefaultRefreshView) {
        self.refreshView = refreshView
    }
    
    func animateState(_ state: State) {
        switch state {
        case .initial:
            refreshView.activityIndicator?.stopAnimating()
            
        case .releasing(let progress):
            refreshView.activityIndicator?.isHidden = false
            refreshView.alpha = progress
            var transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            transform = transform.scaledBy(x: progress, y: progress);
            transform = transform.rotated(by: 3.14 * progress * 2);
            refreshView.activityIndicator?.transform = transform

        case .loading:
            refreshView.alpha = 1
            refreshView.activityIndicator?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            refreshView.activityIndicator?.startAnimating()
            
        default: break
        }
    }
}
