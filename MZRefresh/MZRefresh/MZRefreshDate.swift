//
//  MZRefreshDate.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/13.
//

import Foundation

let MZRefreshDateKey = "MZRefreshDateKey"

public struct MZRefreshDate {
    
    /// 保存当前刷新时间
    public static func saveRefreshDate() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(Date(), forKey: MZRefreshDateKey)
        userDefaults.synchronize()
    }
    
    /// 获取上次刷新时间
    /// - Returns: 上次刷新时间
    public static func getLastRefreshTime() -> String {
        guard let date = UserDefaults.standard.value(forKey: MZRefreshDateKey) as? Date else {
            return "no_record".localized()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let lastTime = formatter.string(from: date)
        let nowTime = formatter.string(from: Date())
        if lastTime[lastTime.startIndex...lastTime.index(lastTime.startIndex, offsetBy: 10)] == nowTime[nowTime.startIndex...nowTime.index(nowTime.startIndex, offsetBy: 10)] {
            return "\("today".localized()) " + String(lastTime[lastTime.index(lastTime.endIndex, offsetBy: -5)...])
        } else if lastTime[lastTime.startIndex...lastTime.index(lastTime.startIndex, offsetBy: 5)] == nowTime[nowTime.startIndex...nowTime.index(nowTime.startIndex, offsetBy: 5)] {
            return String(lastTime[lastTime.index(lastTime.startIndex, offsetBy: 5)...])
        } else {
            return lastTime
        }
    }
}
