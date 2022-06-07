//
//  MZRefreshNormalFooter.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/11.
//

import UIKit
import NVActivityIndicatorView

open class MZRefreshNormalFooter: MZRefreshFooterComponent {
    
    /// 上拉加载组件
    /// - Parameters:
    ///   - type: 组件动画类型
    ///   - color: 组件动画颜色
    ///   - beginRefresh: 刷新回调
    public init(type: NVActivityIndicatorType = .lineSpinFadeLoader, color: UIColor = .gray, beginRefresh: @escaping () -> Void) {
        self.type = type
        self.color = color
        self.callback = beginRefresh
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var type: NVActivityIndicatorType!
    
    var color: UIColor!
    
    var callback: () -> Void
    
    public lazy var refreshNormalView: UIView =  {
        return MZRefreshNormalFooterContent(refreshOffset: refreshOffset, status: .normal, color: color, type: type)
    }()
    
    public lazy var refreshReadyView: UIView = {
        return MZRefreshNormalFooterContent(refreshOffset: refreshOffset, status: .ready, color: color, type: type)
    }()
    
    public lazy var refreshingView: UIView = {
        return MZRefreshNormalFooterContent(refreshOffset: refreshOffset, status: .refresh, color: color, type: type)
    }()
    
    public var refreshOffset: CGFloat {
        return 50.0
    }
    
    public var beginRefresh: () -> Void {
        return self.callback
    }
    
    public var currentStatus: MZRefreshStatus = .ready {
        didSet {
            (self.refreshingView as! MZRefreshNormalFooterContent).updateStatus(currentStatus)
            self.statusUpdate?(oldValue, currentStatus)
        }
    }
    
    public var statusUpdate: MZRefreshBlock?
    
    public func didScroll(_ percent: CGFloat) {
        self.refreshNormalView.alpha = percent
    }
}

class MZRefreshNormalFooterContent: UIView {
    var indicatorView: NVActivityIndicatorView?
    var status: MZRefreshStatus?
    
    convenience init(refreshOffset: CGFloat, status: MZRefreshStatus, color: UIColor, type: NVActivityIndicatorType) {
        self.init(frame: CGRect(x: 0, y: -refreshOffset, width: MZRefreshScreenWidth, height: refreshOffset))
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
            imageView.image = UIImage(named: status == .normal ? "up" : "down", in: .current, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = color
            imageView.center = CGPoint(x: 15, y: 15)
            animatedView.addSubview(imageView)
        }
        
        // 刷新文字描述
        let descLabel = UILabel(frame: CGRect(x: 30, y: 14, width: CGFloat.greatestFiniteMagnitude, height: 22))
        descLabel.textAlignment = .center
        descLabel.font = .systemFont(ofSize: 16)
        self.addSubview(descLabel)
        if status == .normal {
            descLabel.text = "pull_up_to_load_more".localized()
        } else if status == .ready {
            descLabel.text = "release_to_load_more".localized()
        } else {
            descLabel.text = "loading".localized()
        }
        
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 18)
        let size = descLabel.sizeThatFits(maxSize)
        descLabel.frame = CGRect(x: 30, y: 14, width: size.width, height: 22)
        self.frame = CGRect(x: (MZRefreshScreenWidth - size.width - 30) * 0.5, y: -refreshOffset, width: size.width + 30, height: refreshOffset)
        
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
            if scrollView.footer == nil || scrollView.footer?.currentStatus != status {
                super.removeFromSuperview()
            }
        }
    }
}
