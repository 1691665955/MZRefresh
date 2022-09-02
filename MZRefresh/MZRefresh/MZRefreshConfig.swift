//
//  MZRefreshConfig.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/9/2.
//

import UIKit

public class MZRefreshConfig: NSObject {
    
    /// 刷新状态文字颜色
    var statusColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.black
        }
    }()
    
    /// 刷新时间文字颜色
    var timeColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor.gray
        }
    }()
    
    /// 刷新状态文字字体
    var statusFont: UIFont = .systemFont(ofSize: 16)
    
    /// 刷新时间文字字体
    var timeFont: UIFont = .systemFont(ofSize: 14)
    
    /// 配置类单例
    public static let shareInstance = MZRefreshConfig()
    
    /// 设置刷新状态文字颜色
    /// - Parameter color: 文字颜色
    public func setRefreshStatusColor(_ color: UIColor) {
        MZRefreshConfig.shareInstance.statusColor = color
        NotificationCenter.default.post(name: Notification.Name.MZRefreshStatusColorChanged, object: nil)
    }
    
    /// 设置刷新时间文字字体
    /// - Parameter color: 文字颜色
    public func setRefreshTimeColor(_ color: UIColor) {
        MZRefreshConfig.shareInstance.timeColor = color
        NotificationCenter.default.post(name: Notification.Name.MZRefreshTimeColorChanged, object: nil)
    }
    
    /// 设置刷新状态文字字体
    /// - Parameter font: 文字字体
    public func setRefreshStatusFont(_ font: UIFont) {
        MZRefreshConfig.shareInstance.statusFont = font
        NotificationCenter.default.post(name: Notification.Name.MZRefreshStatusFontChanged, object: nil)
    }
    
    /// 设置刷新时间文字字体
    /// - Parameter font: 文字字体
    public func setRefreshTimeFont(_ font: UIFont) {
        MZRefreshConfig.shareInstance.timeFont = font
        NotificationCenter.default.post(name: Notification.Name.MZRefreshTimeFontChanged, object: nil)
    }
}

extension Notification.Name {
    
    /// 刷新状态字体颜色更新
    static let MZRefreshStatusColorChanged = Notification.Name("MZRefreshStatusColorChanged")
    
    /// 刷新时间字体颜色更新
    static let MZRefreshTimeColorChanged = Notification.Name("MZRefreshTimeColorChanged")
    
    /// 刷新状态字体大小更新
    static let MZRefreshStatusFontChanged = Notification.Name("MZRefreshStatusFontChanged")
    
    /// 刷新时间字体大小更新
    static let MZRefreshTimeFontChanged = Notification.Name("MZRefreshTimeFontChanged")
}
