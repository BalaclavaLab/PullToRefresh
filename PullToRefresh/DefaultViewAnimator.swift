//
//  DefaultViewAnimator.swift
//  PullToRefreshDemo
//
//  Created by Serhii Butenko on 26/7/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class DefaultViewAnimator: RefreshViewAnimator {
    
    private let refreshView: DefaultRefreshView
    
    init(refreshView: DefaultRefreshView) {
        self.refreshView = refreshView
    }
    
    func animateState(state: State) {
        switch state {
        case .Initial:
            refreshView.activityIndicator?.stopAnimating()
            
        case .Releasing(let progress):
            refreshView.activityIndicator?.hidden = false
            refreshView.alpha = progress
            var transform = CGAffineTransformMakeScale(0.75, 0.75)
            transform = CGAffineTransformScale(transform, progress, progress);
            transform = CGAffineTransformRotate(transform, 3.14 * progress * 2);
            refreshView.activityIndicator?.transform = transform

        case .Loading:
            refreshView.alpha = 1
            refreshView.activityIndicator?.transform = CGAffineTransformMakeScale(0.75, 0.75)
            refreshView.activityIndicator?.startAnimating()
            
        default: break
        }
    }
}