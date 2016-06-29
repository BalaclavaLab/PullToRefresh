//
//  Created by Anastasiya Gorban on 4/14/15.
//  Copyright (c) 2015 Yalantis. All rights reserved.
//
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at https://github.com/Yalantis/PullToRefresh
//

import UIKit
import Foundation

public protocol RefreshViewAnimator {
     func animateState(state: State)
}

// MARK: PullToRefresh

public class PullToRefresh: NSObject {
    
    public var hideDelay: NSTimeInterval = 0.5

    let refreshView: UIView
    var action: (() -> ())?
    
    private let animator: RefreshViewAnimator
    
    // MARK: - ScrollView & Observing

    private var scrollViewDefaultInsets = UIEdgeInsetsZero
    weak var scrollView: UIScrollView? {
        willSet {
            removeScrollViewObserving()
        }
        didSet {
            if let scrollView = scrollView {
                scrollViewDefaultInsets = scrollView.contentInset
                addScrollViewObserving()
            }
        }
    }
    
    private func addScrollViewObserving() {
        scrollView?.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &KVOContext)
    }
    
    func removeScrollViewObserving() {
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &KVOContext)
    }

    // MARK: - State
    
    var state: State = .Inital {
        didSet {
            animator.animateState(state)
            switch state {
            case .Loading:
                if let scrollView = scrollView where (oldValue != .Loading) {
                    scrollView.setContentOffset(CGPoint(x: previousScrollViewOffset.x, y: -scrollViewDefaultInsets.top - refreshView.frame.height), animated: true)
                    action?()
                }
            case .Finished:
                removeScrollViewObserving()
                if scrollView?.contentOffset.y <= -scrollViewDefaultInsets.top {
                    UIView.animateWithDuration(0.3, delay: hideDelay, options: .CurveEaseInOut, animations: {
                        self.scrollView?.contentOffset.y = -self.scrollViewDefaultInsets.top
                        }, completion: { finished in
                            self.addScrollViewObserving()
                            self.state = .Inital
                    })
                } else {
                    addScrollViewObserving()
                    state = .Inital
                }
                
            default: break
            }
        }
    }
    
    // MARK: - Initialization
    
    public init(refreshView: UIView, animator: RefreshViewAnimator) {
        self.refreshView = refreshView
        self.animator = animator
    }
    
    public override convenience init() {
        let refreshView = DefaultRefreshView()
        self.init(refreshView: refreshView, animator: DefaultViewAnimator(refreshView: refreshView))
    }
    
    deinit {
        removeScrollViewObserving()
    }
    
    // MARK: KVO

    private var KVOContext = "PullToRefreshKVOContext"
    private let contentOffsetKeyPath = "contentOffset"
    private var previousScrollViewOffset: CGPoint = CGPointZero
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        if (context == &KVOContext && keyPath == contentOffsetKeyPath && object as? UIScrollView == scrollView) {
            let offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
            let refreshViewHeight = refreshView.frame.size.height
            
            switch offset {
            case 0 where (state != .Loading): state = .Inital
            case -refreshViewHeight...0 where (state != .Loading && state != .Finished):
                state = .Releasing(progress: -offset / refreshViewHeight)
            case -1000...(-refreshViewHeight):
                if state == State.Releasing(progress: 1) && scrollView?.dragging == false {
                    state = .Loading
                } else if state != State.Loading && state != State.Finished {
                    state = .Releasing(progress: 1)
                }
            default: break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        
        previousScrollViewOffset.y = scrollView!.contentOffset.y
    }
    
    // MARK: - Start/End Refreshing
    
    func startRefreshing() {
        if self.state != State.Inital {
            return
        }
        
        scrollView?.setContentOffset(CGPointMake(0, -refreshView.frame.height - scrollViewDefaultInsets.top), animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.27 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.state = .Loading
            })
    }
    
    func endRefreshing() {
        if state == .Loading {
            state = .Finished
        }
    }
}

// MARK: - State enumeration

public enum State:Equatable, CustomStringConvertible {
    case Inital, Loading, Finished
    case Releasing(progress: CGFloat)
    
    public var description: String {
        switch self {
        case .Inital: return "Inital"
        case .Releasing(let progress): return "Releasing:\(progress)"
        case .Loading: return "Loading"
        case .Finished: return "Finished"
        }
    }
}

public func ==(a: State, b: State) -> Bool {
    switch (a, b) {
    case (.Inital, .Inital): return true
    case (.Loading, .Loading): return true
    case (.Finished, .Finished): return true
    case (.Releasing, .Releasing): return true
    default: return false
    }
}

// MARK: Default PullToRefresh

class DefaultRefreshView: UIView {
    
    // MARK: - Private Properties
    
    private let laoderContentHeight: CGFloat = 44
    
    private var frameHeight: CGFloat {
        return laoderContentHeight + sectionInsetTop + sectionInsetBottom
    }
    
    // MARK: - Internal Properties
    
    var sectionInsetTop: CGFloat = 0
    
    var sectionInsetBottom: CGFloat = 12
    
    private(set) var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Object Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, frameHeight)
    }
    
    override func layoutSubviews() {
        if activityIndicator == nil {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.color = UIColor.blackColor()
            activityIndicator.transform = CGAffineTransformMakeScale(0.75, 0.75)
            addSubview(activityIndicator)
        }
        centerActivityIndicator()
        setupFrameInSuperview(superview)
        super.layoutSubviews()
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        setupFrameInSuperview(superview)
    }
    
    private func setupFrameInSuperview(newSuperview: UIView?) {
        if let superview = newSuperview {
            frame = CGRectMake(frame.origin.x, frame.origin.y, superview.frame.width, frameHeight)
        }
    }
    
    private func centerActivityIndicator() {
        if activityIndicator != nil {
            activityIndicator.center = convertPoint(center, fromView: superview)
            activityIndicator.center.y += (sectionInsetBottom - sectionInsetTop) / 2
        }
    }
}

class DefaultViewAnimator: RefreshViewAnimator {
    private let refreshView: DefaultRefreshView
    
    init(refreshView: DefaultRefreshView) {
        self.refreshView = refreshView
    }
    
    func animateState(state: State) {
        switch state {
        case .Inital: refreshView.activityIndicator?.stopAnimating()
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
