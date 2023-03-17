//
//  MZRefreshOnlyGifHeader.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/15.
//

import UIKit

open class MZRefreshOnlyGifHeader: MZRefreshHeaderComponent {
    
    /// 下拉刷新组件
    /// - Parameters:
    ///   - images: gif分解图片数组
    ///   - size: gif图片显示大小
    ///   - refreshOffSet: 开始刷新所需的偏移量
    ///   - animationDuration: gif动画时间
    ///   - readyImage: 释放刷新图片
    ///   - beginRefresh: 刷新回调
    public init(images: [UIImage], size: CGFloat = 50.0, refreshOffSet:CGFloat = 50.0, animationDuration: CGFloat = 1.0, readyImage: UIImage? = nil, beginRefresh: @escaping () -> Void) {
        self.images = images
        self.size = size
        self.offset = max(size, refreshOffSet)
        self.animationDuration = animationDuration
        self.readyImage = readyImage
        self.callback = beginRefresh
    }
    
    /// 下拉刷新组件
    /// - Parameters:
    ///   - gifImage: gif图片Data
    ///   - size: gif图片显示大小
    ///   - refreshOffSet: 开始刷新所需的偏移量
    ///   - animationDuration: gif动画时间
    ///   - readyImage: 释放刷新图片
    ///   - beginRefresh: 刷新回调
    public init(gifImage: Data, size: CGFloat = 50.0, refreshOffSet:CGFloat = 50.0, animationDuration: CGFloat = 0.0, readyImage: UIImage? = nil, beginRefresh: @escaping () -> Void) {
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
        self.offset = max(size, refreshOffSet)
        self.readyImage = readyImage
        self.callback = beginRefresh
    }
    
    
    var images: [UIImage]
    var animationDuration: CGFloat
    var size: CGFloat
    var offset: CGFloat
    var readyImage: UIImage?
    var callback: () -> Void
    
    public lazy var refreshNormalView: UIView = {
        let imageList = self.images
        return MZRefreshOnlyGifHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .normal, images: imageList, animationDuration: self.animationDuration, size: self.size, readyImage: self.readyImage)
    }()
    
    public lazy var refreshReadyView: UIView = {
        let imageList = self.images
        return MZRefreshOnlyGifHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .ready, images: imageList, animationDuration: self.animationDuration, size: self.size, readyImage: self.readyImage)
    }()
    
    public lazy var refreshingView: UIView = {
        let imageList = self.images
        return MZRefreshOnlyGifHeaderContent(refreshWidth: refreshWidth, refreshOffset: refreshOffset, status: .refresh, images: imageList, animationDuration: self.animationDuration, size: self.size, readyImage: self.readyImage)
    }()
    
    public var refreshWidth: CGFloat = MZRefreshScreenWidth
    
    public var refreshOffset: CGFloat {
        return self.offset
    }
    
    public var beginRefresh: () -> Void {
        return self.callback
    }
    
    public var currentStatus: MZRefreshStatus = .ready {
        didSet {
            (self.refreshingView as! MZRefreshOnlyGifHeaderContent).updateStatus(currentStatus)
            self.statusUpdate?(oldValue, currentStatus)
        }
    }
    
    public var statusUpdate: MZRefreshBlock?
    
    public func didScroll(_ percent: CGFloat) {
        let count = min(Int(percent * CGFloat(self.images.count)), self.images.count - 1)
        guard let imageView = (self.refreshNormalView as! MZRefreshOnlyGifHeaderContent).subviews.first as? UIImageView else {
            return
        }
        imageView.image = self.images[count]
    }
    
    public func refreshWidthUpdate(_ width: CGFloat) {
        var frame = self.refreshNormalView.frame
        frame.size.width = width
        self.refreshNormalView.frame = frame
        self.refreshReadyView.frame = frame
        self.refreshingView.frame = frame
        for subView in self.refreshNormalView.subviews {
            var subFrame = subView.frame
            subFrame.size.width = width
            subView.frame = subFrame
        }
        for subView in self.refreshReadyView.subviews {
            var subFrame = subView.frame
            subFrame.size.width = width
            subView.frame = subFrame
        }
        for subView in self.refreshingView.subviews {
            var subFrame = subView.frame
            subFrame.size.width = width
            subView.frame = subFrame
        }
        self.refreshWidth = width
    }
    
}


class MZRefreshOnlyGifHeaderContent: UIView {
    var indicatorView: UIImageView?
    var status: MZRefreshStatus?
    
    convenience init(refreshWidth: CGFloat, refreshOffset: CGFloat, status: MZRefreshStatus, images: [UIImage], animationDuration: CGFloat, size: CGFloat, readyImage: UIImage?) {
        self.init(frame: CGRect(x: 0, y: -1000, width: refreshWidth, height: 1000))
        self.status = status
        // 刷新图标
        if status == .refresh {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 1000 - refreshOffset + (refreshOffset - size) * 0.5, width: refreshWidth, height: size))
            imageView.contentMode = .scaleAspectFit
            imageView.animationImages = images
            imageView.animationDuration = animationDuration
            self.addSubview(imageView)
            self.indicatorView = imageView
        } else {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 1000 - refreshOffset  + (refreshOffset - size) * 0.5, width: refreshWidth, height: size))
            imageView.contentMode = .scaleAspectFit
            imageView.image = status == .normal ? images.first : (readyImage ?? images.last)
            self.addSubview(imageView)
        }
        self.backgroundColor = images.first?.color(atPoint: CGPoint.zero)
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
    
    override func removeFromSuperview() {
        if let scrollView = self.superview as? UIScrollView {
            if scrollView.header == nil || scrollView.header?.currentStatus != status {
                super.removeFromSuperview()
            }
        }
    }
}
