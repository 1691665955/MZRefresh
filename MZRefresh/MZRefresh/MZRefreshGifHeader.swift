//
//  MZRefreshGifHeader.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/14.
//

import UIKit

open class MZRefreshGifHeader: MZRefreshHeaderComponent {
    
    /// 下拉刷新组件
    /// - Parameters:
    ///   - images: gif分解图片数组
    ///   - size: gif图片显示大小
    ///   - animationDuration: gif动画时间
    ///   - showTime: 是否显示上次下拉刷新时间
    ///   - beginRefresh: 刷新回调
    public init(images: [UIImage], size: CGFloat = 30.0, animationDuration: CGFloat = 1.0, showTime: Bool = true, beginRefresh: @escaping () -> Void) {
        self.images = images
        self.size = size
        self.animationDuration = animationDuration
        self.showTime = showTime
        self.callback = beginRefresh
    }
    
    /// 下拉刷新组件
    /// - Parameters:
    ///   - gifImage: gif图片Data
    ///   - size: gif图片显示大小
    ///   - animationDuration: gif动画时间（默认为gif图片动画时间）
    ///   - showTime: 是否显示上次下拉刷新时间
    ///   - beginRefresh: 刷新回调
    public init(gifImage: Data, size: CGFloat = 30.0, animationDuration: CGFloat = 0.0, showTime: Bool = true, beginRefresh: @escaping () -> Void) {
        if let imageSource = CGImageSourceCreateWithData(gifImage as CFData, nil) {
            let imageCount = CGImageSourceGetCount(imageSource)
            var images = [UIImage]()
            var totalDuration: CGFloat = 0.0
            for index in 0..<imageCount {
                guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
                    continue
                }
                images.append(UIImage(cgImage: cgImage))
                
                guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) else {
                    continue
                }
                guard let gifDic = (properties as Dictionary)[kCGImagePropertyGIFDictionary] as? Dictionary<CFString, Any> else {
                    continue
                }
                guard let duration = gifDic[kCGImagePropertyGIFDelayTime] as? CGFloat else {
                    continue
                }
                totalDuration += duration
            }
            self.images = images
            self.animationDuration = (animationDuration == 0.0 ? totalDuration : animationDuration)
        } else {
            self.images = []
            self.animationDuration = (animationDuration == 0.0 ? 1.0 : animationDuration)
        }
        self.size = size
        self.showTime = showTime
        self.callback = beginRefresh
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var images: [UIImage]
    
    var animationDuration: CGFloat
    
    var size: CGFloat
    
    var showTime: Bool
    
    var callback: () -> Void
    
    public lazy var refreshNormalView: UIView = {
        return MZRefreshGifHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .normal, images: self.images, size: self.size, animationDuration: self.animationDuration, showTime: self.showTime)
    }()
    
    public lazy var refreshReadyView: UIView = {
        return MZRefreshGifHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .ready, images: self.images, size: self.size, animationDuration: self.animationDuration, showTime: self.showTime)
    }()
    
    public lazy var refreshingView: UIView = {
        return MZRefreshGifHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .refresh, images: self.images, size: self.size, animationDuration: self.animationDuration, showTime: self.showTime)
    }()
    
    public var refreshWidth: CGFloat = MZRefreshScreenWidth
    
    public var refreshOffset: CGFloat {
        return max(self.size, 50.0)
    }
    
    public var beginRefresh: () -> Void {
        return self.callback
    }
    
    public var currentStatus: MZRefreshStatus = .ready {
        didSet {
            (self.refreshingView as! MZRefreshGifHeaderContent).updateStatus(currentStatus)
            self.statusUpdate?(oldValue, currentStatus)
            if oldValue == .refresh && currentStatus == .normal {
                // 停止刷新
                (self.refreshNormalView as? MZRefreshGifHeaderContent)?.timeString = MZRefreshDate.getLastRefreshTime()
                (self.refreshReadyView as? MZRefreshGifHeaderContent)?.timeString = MZRefreshDate.getLastRefreshTime()
                (self.refreshingView as? MZRefreshGifHeaderContent)?.timeString = MZRefreshDate.getLastRefreshTime()
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

class MZRefreshGifHeaderContent: UIView {
    var timeString: String? {
        didSet {
            if timeLabel != nil {
                timeLabel!.text = "\("last_update_time".localized())\(timeString ?? MZRefreshDate.getLastRefreshTime())"
                
                let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 18)
                let size = timeLabel!.sizeThatFits(maxSize)
                
                let originX = (self.size ?? 0) + 3
                timeLabel!.frame = CGRect(x: originX, y: 29 + (refreshOffset! - 50) * 0.5, width: size.width, height: 18)
                descLabel!.frame = CGRect(x: originX, y: 4 + (refreshOffset! - 50) * 0.5, width: size.width, height: 22)
                self.frame = CGRect(x: (refreshWidth! - size.width - originX) * 0.5, y: -refreshOffset!, width: size.width + originX, height: refreshOffset!)
            }
        }
    }
    var indicatorView: UIImageView?
    var refreshWidth: CGFloat?
    var refreshOffset: CGFloat?
    var descLabel: UILabel?
    var timeLabel: UILabel?
    var status: MZRefreshStatus?
    var size: CGFloat?
    
    convenience init(refreshWidth: CGFloat, refreshOffset: CGFloat, status: MZRefreshStatus, images: [UIImage], size: CGFloat, animationDuration: CGFloat, showTime: Bool) {
        self.init(frame: CGRect(x: 0, y: -refreshOffset, width: refreshWidth, height: refreshOffset))
        
        self.refreshWidth = refreshWidth
        self.refreshOffset = refreshOffset
        self.status = status
        self.size = size
        
        let animatedView = UIView(frame: CGRect(x: 0, y: (refreshOffset - size) * 0.5, width: size, height: size))
        self.addSubview(animatedView)
        // 刷新图标
        if status == .refresh {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
            imageView.contentMode = .scaleAspectFit
            imageView.animationImages = images
            imageView.animationDuration = animationDuration
            animatedView.addSubview(imageView)
            self.indicatorView = imageView
        } else {
            let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0, width: 16.0, height: 16.0))
            imageView.image = UIImage(named: status == .normal ? "down" : "up", in: .refreshBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = .gray
            imageView.center = CGPoint(x: size * 0.5, y: size * 0.5)
            animatedView.addSubview(imageView)
        }
        
        let originX = size + 3
        
        // 刷新文字描述
        descLabel = UILabel(frame: CGRect(x: originX, y: 4 + (refreshOffset - 50) * 0.5, width: CGFloat.greatestFiniteMagnitude, height: 22))
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
            descLabel!.frame = CGRect(x: originX, y: 14 + (refreshOffset - 50) * 0.5, width: size.width, height: 22)
            self.frame = CGRect(x: (refreshWidth - size.width - originX) * 0.5, y: -refreshOffset, width: size.width + originX, height: refreshOffset)
        } else {
            // 上次刷新时间
            timeLabel = UILabel(frame: CGRect(x: originX, y: 29 + (refreshOffset - 50) * 0.5, width: CGFloat.greatestFiniteMagnitude, height: 18))
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

