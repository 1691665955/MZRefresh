//
//  MZRefreshComponent.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/11.
//

import Foundation
import UIKit

let MZRefreshScreenWidth = UIScreen.main.bounds.width
public typealias MZRefreshBlock = (_ oldStatus: MZRefreshStatus, _ newStatus: MZRefreshStatus) -> Void

public enum MZRefreshStatus: Int {
    case normal  = 0
    case ready   = 1
    case refresh = 2
}

public protocol MZRefreshComponent {
    
    /// 刷新组件的宽度
    var refreshWidth: CGFloat {get set}
    
    /// 刷新状态
    var currentStatus: MZRefreshStatus { get set }
    
    /// 下拉刷新
    var refreshNormalView: UIView { get }
    
    /// 释放刷新
    var refreshReadyView: UIView { get }
    
    /// 正在刷新
    var refreshingView: UIView { get }
    
    /// 刷新条件
    var refreshOffset: CGFloat { get }
    
    /// 开始刷新
    var beginRefresh: () -> Void { get }
    
    /// 刷新状态更新
    var statusUpdate: MZRefreshBlock? {get set}
    
    /// 滚动高度百分比动态监听，根据百分比处理过渡动画
    func didScroll(_ percent: CGFloat)
    
    /// 刷新组件宽度更新
    func refreshWidthUpdate(_ width: CGFloat)
}
