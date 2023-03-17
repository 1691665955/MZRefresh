//
//  UIScrollView+MZRefresh.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/11.
//

import UIKit

var MZRefreshHeaderKey = "MZRefreshHeader"
var MZRefreshFooterKey = "MZRefreshFooterKey"
var MZRefreshNoMoreDataFooterKey = "MZRefreshNoMoreDataFooterKey"
var MZRefreshIsNoMoreDataKey = "MZRefreshIsNoMoreDataKey"
var MZRefreshHeaderOffsetKey = "MZRefreshOffsetHeader"
var MZRefreshHeaderIsRefreshingKey = "MZRefreshHeaderIsRefreshingKey"
let MZRefreshHeaderTag = 88888
let MZRefreshFooterTag = 99999

public extension UIScrollView {
    
    /// 添加下拉刷新组件
    /// - Parameter header: 下拉刷新组件
    func setRefreshHeader(_ header: MZRefreshHeaderComponent) {
        self.removeRefreshHeader()
        addRefreshObserver()
        // 没有设置contentSize也可以滚动
        self.alwaysBounceVertical = true
        self.header = header
        self.header?.statusUpdate = {oldStatus, newStatus in
            if newStatus == .normal {
                if oldStatus != .normal {
                    if self.isRefreshing {
                        return
                    }
                    self.isRefreshing = false
                    self.viewWithTag(MZRefreshHeaderTag)?.removeFromSuperview()
                    let normalView = header.refreshNormalView
                    normalView.tag = MZRefreshHeaderTag
                    self.addSubview(normalView)
                }
            } else if newStatus == .ready {
                if oldStatus != .ready {
                    if self.isRefreshing {
                        return
                    }
                    self.isRefreshing = false
                    self.viewWithTag(MZRefreshHeaderTag)?.removeFromSuperview()
                    let readyView = header.refreshReadyView
                    readyView.tag = MZRefreshHeaderTag
                    self.addSubview(readyView)
                }
            } else if newStatus == .refresh {
                if self.isRefreshing {
                    return
                }
                self.isRefreshing = true
                self.viewWithTag(MZRefreshHeaderTag)?.removeFromSuperview()
                let refreshView = header.refreshingView
                refreshView.tag = MZRefreshHeaderTag
                self.addSubview(refreshView)
                MZRefreshDate.saveRefreshDate()
                header.beginRefresh()
            }
        }
        self.header?.currentStatus = .normal
    }
    
    /// 移除下拉刷新组件
    func removeRefreshHeader() {
        if self.header != nil {
            self.header = nil
            self.viewWithTag(MZRefreshHeaderTag)?.removeFromSuperview()
            removeRefreshObserver()
        }
    }
    
    /// 手动下拉刷新
    /// - Parameter animated: 是否执行动画
    func startHeaderRefreshing(animated: Bool = false) {
        if self.header != nil {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.05) { [weak self] in
                self?.header?.currentStatus = .refresh
                if animated {
                    self?.contentInset = UIEdgeInsets(top: self?.header?.refreshOffset ?? 0, left: 0, bottom: 0, right: 0)
                }
                self?.contentOffset = CGPoint(x: 0, y: -(animated ? (self?.header?.refreshOffset ?? 0) : 0) + (self?.originOffset ?? 0))
            }
        }
    }
    
    /// 停止下拉刷新动画
    func stopHeaderRefreshing() {
        self.isNoMoreData = false
        self.footer?.refreshNormalView.isHidden = false
        self.footer?.refreshReadyView.isHidden = false
        self.footer?.refreshingView.isHidden = false
        self.noMoreDataFooter?.isHidden = true
        
        if self.header != nil {
            self.isRefreshing = false
            self.header?.currentStatus = .normal
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.contentInset = UIEdgeInsets.zero
            }
        }
    }
    
    /// 停止下拉刷新动画，并且取消上拉加载，显示“暂无更多数据”
    func stopHeaderRefreshingWithNoMoreData() {
        self.stopHeaderRefreshing()
        self.stopRefreshingWithNoMoreData()
    }
    
    /// 设置上拉加载组件
    /// - Parameter footer: 上拉加载组件
    func setRefreshFooter(_ footer: MZRefreshFooterComponent) {
        self.removeRefreshFooter()
        addRefreshObserver()
        // 没有设置contentSize也可以滚动
        self.alwaysBounceVertical = true
        self.footer = footer
        self.footer?.statusUpdate = {oldStatus, newStatus in
            if newStatus == .normal {
                if oldStatus != .normal {
                    if self.isRefreshing {
                        return
                    }
                    self.isRefreshing = false
                    self.viewWithTag(MZRefreshFooterTag)?.removeFromSuperview()
                    let normalView = footer.refreshNormalView
                    normalView.tag = MZRefreshFooterTag
                    normalView.alpha = 0
                    self.addSubview(normalView)
                }
            } else if newStatus == .ready {
                if oldStatus != .ready {
                    if self.isRefreshing {
                        return
                    }
                    self.isRefreshing = false
                    self.viewWithTag(MZRefreshFooterTag)?.removeFromSuperview()
                    let readyView = footer.refreshReadyView
                    readyView.tag = MZRefreshFooterTag
                    self.addSubview(readyView)
                }
            } else if newStatus == .refresh {
                if self.isRefreshing {
                    return
                }
                self.isRefreshing = true
                self.viewWithTag(MZRefreshFooterTag)?.removeFromSuperview()
                let refreshView = footer.refreshingView
                refreshView.tag = MZRefreshFooterTag
                self.addSubview(refreshView)
                footer.beginRefresh()
            }
        }
        self.footer?.currentStatus = .normal
    }
    
    /// 移除上拉加载组件
    func removeRefreshFooter() {
        if self.footer != nil {
            self.footer = nil
            self.viewWithTag(MZRefreshFooterTag)?.removeFromSuperview()
            removeRefreshObserver()
        }
    }
    
    /// 手动下拉刷新
    /// - Parameter animated: 是否执行动画
    func startFooterRefreshing(animated: Bool = false) {
        if self.header != nil && self.contentSize.height > 0{
            if animated {
                self.footer?.currentStatus = .refresh
                self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.footer?.refreshOffset ?? 0, right: 0)
            } else {
                self.footer?.beginRefresh()
            }
            self.scrollToBottom(animated: animated)
        }
    }
    
    /// 停止上拉加载动画
    func stopFooterRefreshing() {
        self.isNoMoreData = false
        self.footer?.refreshNormalView.isHidden = false
        self.footer?.refreshReadyView.isHidden = false
        self.footer?.refreshingView.isHidden = false
        self.noMoreDataFooter?.isHidden = true
        
        if self.footer != nil {
            self.isRefreshing = false
            self.footer?.currentStatus = .normal
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                UIView.animate(withDuration: 0.1) { [weak self] in
                    self?.contentInset = UIEdgeInsets.zero
                }
            }
        }
    }
    
    /// 停止上拉加载动画，并且取消上拉加载，显示“暂无更多数据”
    func stopFooterRefreshingWithNoMoreData() {
        self.stopFooterRefreshing()
        self.stopRefreshingWithNoMoreData()
    }
    
    /// 设置“NoMoreData”组件
    /// - Parameter footer: “NoMoreData”组件
    func setRefreshNoMoreDataView(_ noMoreDataView: UIView? = nil) {
        self.removeRefreshNoMoreDataView()
        
        let refreshOffset = noMoreDataView?.frame.height ?? 40
        let footer = UIView.init(frame: CGRect(x: 0, y: -refreshOffset, width: self.frame.width, height: refreshOffset))
        
        if noMoreDataView == nil {
            let descLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: refreshOffset))
            descLabel.textAlignment = .center
            descLabel.font = .systemFont(ofSize: 16)
            descLabel.text = "no_more_data".localized()
            footer.addSubview(descLabel)
        } else {
            footer.addSubview(noMoreDataView!)
        }
        footer.isHidden = true
        self.addSubview(footer)
        
        self.noMoreDataFooter = footer
    }
    
    /// 移除“NoMoreData”组件
    func removeRefreshNoMoreDataView() {
        self.noMoreDataFooter?.removeFromSuperview()
        self.noMoreDataFooter = nil
    }
    
    private func stopRefreshingWithNoMoreData() {
        self.isNoMoreData = true
        self.footer?.refreshNormalView.isHidden = true
        self.footer?.refreshReadyView.isHidden = true
        self.footer?.refreshingView.isHidden = true
        
        if self.noMoreDataFooter == nil {
            self.setRefreshNoMoreDataView()
            
            var frame = self.noMoreDataFooter!.frame
            frame.origin.y = self.contentSize.height
            self.noMoreDataFooter!.frame = frame
        }
        self.noMoreDataFooter?.alpha = 0
        self.noMoreDataFooter?.isHidden = false
    }
    
    private func addRefreshObserver() {
        if self.header == nil && self.footer == nil && self.noMoreDataFooter == nil {
            self.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            self.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
            self.panGestureRecognizer.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
    }
    
    private func removeRefreshObserver() {
        if self.header == nil && self.footer == nil && self.noMoreDataFooter == nil {
            self.removeObserver(self, forKeyPath: "contentOffset")
            self.removeObserver(self, forKeyPath: "contentSize")
            self.panGestureRecognizer.removeObserver(self, forKeyPath: "state")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let point = change?[.newKey] as? CGPoint {
                if let originOffset = self.originOffset {
                    let trueOffset = point.y - originOffset
                    if trueOffset > -(self.header?.refreshOffset ?? 0) && trueOffset < 0 {
                        self.header?.currentStatus = .normal
                        self.header?.didScroll(-trueOffset / (self.header?.refreshOffset ?? 50))
                    } else if trueOffset < -(self.header?.refreshOffset ?? 0) {
                        self.header?.currentStatus = .ready
                        self.header?.didScroll(1)
                    } else if trueOffset > 0 {
                        if self.contentSize.height == 0 {
                            return
                        }
                        let height = self.frame.height
                        // 元素未占满屏幕
                        if height > self.contentSize.height {
                            if !self.isNoMoreData {
                                if trueOffset < (self.footer?.refreshOffset ?? 0) {
                                    self.footer?.currentStatus = .normal
                                    self.footer?.didScroll(trueOffset / (self.footer?.refreshOffset ?? 50.0))
                                } else if trueOffset > (self.footer?.refreshOffset ?? 0) {
                                    self.footer?.currentStatus = .ready
                                    self.footer?.didScroll(1)
                                }
                            }
                            
                            if trueOffset < (self.noMoreDataFooter?.frame.height ?? 0) {
                                self.noMoreDataFooter?.alpha = trueOffset / (self.noMoreDataFooter?.frame.height ?? 40.0)
                            } else if trueOffset > (self.noMoreDataFooter?.frame.height ?? 0) {
                                self.noMoreDataFooter?.alpha = 1
                            }
                        } else {
                            // 元素占满屏幕
                            var distanceFromBottom: CGFloat
                            if #available(iOS 11.0, *) {
                                distanceFromBottom = self.contentSize.height - point.y + safeAreaInsets.bottom
                            } else {
                                distanceFromBottom = self.contentSize.height - point.y
                            }
                            if distanceFromBottom < height {
                                if !self.isNoMoreData {
                                    if height - distanceFromBottom < (self.footer?.refreshOffset ?? 0) {
                                        self.footer?.currentStatus = .normal
                                        self.footer?.didScroll((height - distanceFromBottom) / (self.footer?.refreshOffset ?? 50.0))
                                    } else if height - distanceFromBottom > (self.footer?.refreshOffset ?? 0) {
                                        self.footer?.currentStatus = .ready
                                        self.footer?.didScroll(1)
                                    }
                                }
                                
                                if height - distanceFromBottom < (self.noMoreDataFooter?.frame.height ?? 0) {
                                    self.noMoreDataFooter?.alpha = (height - distanceFromBottom) / (self.noMoreDataFooter?.frame.height ?? 40.0)
                                } else if height - distanceFromBottom > (self.noMoreDataFooter?.frame.height ?? 0) {
                                    self.noMoreDataFooter?.alpha = 1
                                }
                            }
                        }
                    }
                }
            }
        } else if keyPath == "state" {
            if self.panGestureRecognizer.state == .ended {
                if self.header?.currentStatus == .ready {
                    self.header?.currentStatus = .refresh
                    self.contentInset = UIEdgeInsets(top: self.header?.refreshOffset ?? 0, left: 0, bottom: 0, right: 0)
                } else if self.footer?.currentStatus == .ready {
                    self.footer?.currentStatus = .refresh
                    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.footer?.refreshOffset ?? 0, right: 0)
                }
            }
        } else if keyPath == "contentSize" {
            if let size = change?[.newKey] as? CGSize {
                if self.footer != nil {
                    var normalFrame = self.footer!.refreshNormalView.frame
                    normalFrame.origin.y = size.height
                    self.footer!.refreshNormalView.frame = normalFrame
                    
                    var readyFrame = self.footer!.refreshReadyView.frame
                    readyFrame.origin.y = size.height
                    self.footer!.refreshReadyView.frame = readyFrame
                    
                    var refreshFrame = self.footer!.refreshingView.frame
                    refreshFrame.origin.y = size.height
                    self.footer!.refreshingView.frame = refreshFrame
                    
                    self.footer?.refreshWidthUpdate(size.width)
                }
                
                if self.header != nil {
                    self.header?.refreshWidthUpdate(size.width)
                }
                
                if self.noMoreDataFooter != nil {
                    var frame = self.noMoreDataFooter?.frame
                    frame?.size.width = size.width
                    self.noMoreDataFooter?.frame = frame ?? CGRect.zero
                    
                    for subView in self.noMoreDataFooter?.subviews ?? [] {
                        if let label = subView as? UILabel {
                            if label.text == "no_more_data".localized() {
                                var labelFrame = label.frame
                                labelFrame.size.width = size.width
                                label.frame = labelFrame
                            }
                        }
                    }
                }
                
                if self.noMoreDataFooter != nil {
                    var normalFrame = self.noMoreDataFooter!.frame
                    normalFrame.origin.y = size.height
                    self.noMoreDataFooter!.frame = normalFrame
                }
            }
        }
    }
    
    override func didMoveToSuperview() {
        if self.originOffset == nil {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.originOffset = self.contentOffset.y
            }
        }
    }
    
    internal var header: MZRefreshHeaderComponent? {
        set {
            objc_setAssociatedObject(self, &MZRefreshHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &MZRefreshHeaderKey) as? MZRefreshHeaderComponent
        }
    }
    
    internal var footer: MZRefreshFooterComponent? {
        set {
            objc_setAssociatedObject(self, &MZRefreshFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &MZRefreshFooterKey) as? MZRefreshFooterComponent
        }
    }
    
    internal var noMoreDataFooter: UIView? {
        set {
            objc_setAssociatedObject(self, &MZRefreshNoMoreDataFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &MZRefreshNoMoreDataFooterKey) as? UIView
        }
    }
    
    private var originOffset: CGFloat? {
        set {
            objc_setAssociatedObject(self, &MZRefreshHeaderOffsetKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &MZRefreshHeaderOffsetKey) as? CGFloat
        }
    }
    
    private var isRefreshing: Bool {
        set {
            objc_setAssociatedObject(self, &MZRefreshHeaderIsRefreshingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &MZRefreshHeaderIsRefreshingKey) as? Bool ?? false
        }
    }
    
    private var isNoMoreData: Bool {
        set {
            objc_setAssociatedObject(self, &MZRefreshIsNoMoreDataKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &MZRefreshIsNoMoreDataKey) as? Bool ?? false
        }
    }
    
    private func scrollToBottom(animated: Bool = false) {
        var offset: CGFloat = 0
        let height = self.frame.height
        // 元素未占满屏幕
        if height > self.contentSize.height {
            offset = (animated ? (self.footer?.refreshOffset ?? 0) : 0) + (self.originOffset ?? 0)
        } else {
            let distance = height - (animated ? (self.footer?.refreshOffset ?? 0) : 0)
            if #available(iOS 11.0, *) {
                offset = self.contentSize.height + safeAreaInsets.bottom - distance
            } else {
                offset = self.contentSize.height - distance
            }
        }
        self.contentOffset = CGPoint(x: 0, y: offset)
    }
    
}
