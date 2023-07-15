//
//  MZRefreshNormalHeader.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/11.
//

import UIKit
import NVActivityIndicatorView

open class MZRefreshNormalHeader: MZRefreshHeaderComponent {
    
    /// 下拉刷新组件
    /// - Parameters:
    ///   - type: 组件动画类型
    ///   - color: 组件动图颜色
    ///   - showTime: 是否显示上次下拉刷新时间
    ///   - beginRefresh: 刷新回调
    public init(type: NVActivityIndicatorType = .lineSpinFadeLoader, color: UIColor = .gray, showTime: Bool = true, beginRefresh: @escaping () -> Void) {
        self.type = type
        self.color = color
        self.showTime = showTime
        self.callback = beginRefresh
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var type: NVActivityIndicatorType
    
    var color: UIColor
    
    var showTime: Bool
    
    var callback: () -> Void
    
    public lazy var refreshNormalView: UIView = {
        return MZRefreshNormalHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .normal, color: color, type: type, showTime: self.showTime)
    }()
    
    public lazy var refreshReadyView: UIView = {
        return MZRefreshNormalHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .ready, color: color, type: type, showTime: self.showTime)
    }()
    
    public lazy var refreshingView: UIView = {
        return MZRefreshNormalHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .refresh, color: color, type: type, showTime: self.showTime)
    }()
    
    public var refreshWidth: CGFloat = MZRefreshScreenWidth
    
    public var refreshOffset: CGFloat {
        return 50.0
    }
    
    public var beginRefresh: () -> Void {
        return self.callback
    }
    
    public var currentStatus: MZRefreshStatus = .ready {
        didSet {
            self.statusUpdate?(oldValue, currentStatus)
            (self.refreshingView as! MZRefreshNormalHeaderContent).updateStatus(currentStatus)
            if oldValue == .refresh && currentStatus == .normal {
                // 停止刷新
                (self.refreshNormalView as? MZRefreshNormalHeaderContent)?.timeString = MZRefreshDate.getLastRefreshTime()
                (self.refreshReadyView as? MZRefreshNormalHeaderContent)?.timeString = MZRefreshDate.getLastRefreshTime()
                (self.refreshingView as? MZRefreshNormalHeaderContent)?.timeString = MZRefreshDate.getLastRefreshTime()
            }
        }
    }
    
    public var statusUpdate: MZRefreshBlock?
    
    public func didScroll(_ percent: CGFloat) {
        
    }
    
    public func refreshWidthUpdate(_ width: CGFloat) {
        let offset = width - self.refreshWidth
        var frame = self.refreshNormalView.frame
        frame.origin.x += offset * 0.5
        self.refreshNormalView.frame = frame
        self.refreshReadyView.frame = frame
        self.refreshingView.frame = frame
        self.refreshWidth = width
    }
}

class MZRefreshNormalHeaderContent: UIView {
    var timeString: String? {
        didSet {
            if timeLabel != nil {
                timeLabel!.text = "\("last_update_time".localized())\(timeString ?? MZRefreshDate.getLastRefreshTime())"
                
                let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 18)
                let size = timeLabel!.sizeThatFits(maxSize)
                timeLabel!.frame = CGRect(x: 30, y: 29, width: size.width, height: 18)
                descLabel!.frame = CGRect(x: 30, y: 4, width: size.width, height: 22)
                self.frame = CGRect(x: (refreshWidth! - size.width - 30) * 0.5, y: -refreshOffset!, width: size.width + 30, height: refreshOffset!)
            }
        }
    }
    var indicatorView: NVActivityIndicatorView?
    var refreshWidth: CGFloat?
    var refreshOffset: CGFloat?
    var descLabel: UILabel?
    var timeLabel: UILabel?
    var status: MZRefreshStatus?
    
    convenience init(refreshWidth: CGFloat, refreshOffset: CGFloat, status: MZRefreshStatus, color: UIColor, type: NVActivityIndicatorType, showTime: Bool) {
        self.init(frame: CGRect(x: 0, y: -refreshOffset, width: refreshWidth, height: refreshOffset))
        self.refreshWidth = refreshWidth
        self.refreshOffset = refreshOffset
        self.status = status
        
        let animatedView = UIView(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
        self.addSubview(animatedView)
        // 刷新图标
        if status == .refresh {
            let iconView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0), type: type, color: color)
            iconView.center = CGPoint(x: 15, y: 15)
            animatedView.addSubview(iconView)
            self.indicatorView = iconView
        } else {
            let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0, width: 16.0, height: 16.0))
            imageView.image = UIImage(named: status == .normal ? "down" : "up", in: .refreshBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
            imageView.center = CGPoint(x: 15, y: 15)
            animatedView.addSubview(imageView)
        }
        
        // 刷新文字描述
        descLabel = UILabel(frame: CGRect(x: 30, y: 4, width: CGFloat.greatestFiniteMagnitude, height: 22))
        descLabel!.textAlignment = .center
        descLabel!.font = MZRefreshConfig.shareInstance.statusFont
        descLabel?.textColor = MZRefreshConfig.shareInstance.statusColor
        self.addSubview(descLabel!)
        if status == .normal {
            descLabel!.text = "pull_down_to_refresh".localized()
        } else if status == .ready {
            descLabel!.text = "release_to_refresh".localized()
        } else {
            descLabel!.text = "loading".localized()
        }
        
        if !showTime {
            let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 18)
            let size = descLabel!.sizeThatFits(maxSize)
            descLabel!.frame = CGRect(x: 30, y: 14, width: size.width, height: 22)
            self.frame = CGRect(x: (refreshWidth - size.width - 30) * 0.5, y: -refreshOffset, width: size.width + 30, height: refreshOffset)
        } else {
            // 上次刷新时间
            timeLabel = UILabel(frame: CGRect(x: 30, y: 29, width: CGFloat.greatestFiniteMagnitude, height: 18))
            timeLabel!.textColor = MZRefreshConfig.shareInstance.timeColor
            timeLabel!.font = MZRefreshConfig.shareInstance.timeFont
            self.addSubview(timeLabel!)
            
            self.setValue(MZRefreshDate.getLastRefreshTime(), forKey: "timeString")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatusColor), name: Notification.Name.MZRefreshStatusColorChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimeColor), name: Notification.Name.MZRefreshTimeColorChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatusFont), name: Notification.Name.MZRefreshStatusFontChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTimeFont), name: Notification.Name.MZRefreshTimeFontChanged, object: nil)
    }
    
    @objc func updateStatusColor(notification: Notification) {
        descLabel?.textColor = MZRefreshConfig.shareInstance.statusColor
    }
    
    @objc func updateTimeColor(notification: Notification) {
        timeLabel?.textColor = MZRefreshConfig.shareInstance.timeColor
    }
    
    @objc func updateStatusFont(notification: Notification) {
        descLabel?.font = MZRefreshConfig.shareInstance.statusFont
    }
    
    @objc func updateTimeFont(notification: Notification) {
        timeLabel?.font = MZRefreshConfig.shareInstance.timeFont
    }
    
    func updateStatus(_ status: MZRefreshStatus) {
        if self.status == .refresh {
            if status == .refresh {
                self.indicatorView?.startAnimating()
            } else {
                self.indicatorView?.stopAnimating()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        guard let newStr = value as? String else {
            return
        }
        timeString = newStr
    }
    
    override func removeFromSuperview() {
        if let scrollView = self.superview as? UIScrollView {
            if scrollView.header == nil || scrollView.header?.currentStatus != status {
                super.removeFromSuperview()
            }
        }
    }
}

