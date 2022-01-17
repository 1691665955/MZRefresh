//
//  ViewController.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/10.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataSource: [String] = ["Normal-Scroll-Refresh", "Normal-TableView-Refresh", "Normal-CollectionView-Refresh", "Normal-Refresh-Type", "Gif-Refresh", "OnlyGif-Refresh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MZRefresh"
        self.config()
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.dataSource[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var controller: UIViewController = UIViewController()
        switch indexPath.row {
        case 0:
            controller = NormalRefreshController()
        case 1:
            controller = TableViewRefreshController()
        case 2:
            controller = CollectionViewRefreshController()
        case 3:
            controller = RefreshTypeController()
        case 4:
            controller = GifRefreshController()
        case 5:
            controller = OnlyGifRefreshController()
        default:
            break
        }
        controller.title = self.dataSource[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func config() {
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
            // UINavigationBarAppearance属性从iOS13开始
            let navBarAppearance = UINavigationBarAppearance()
            // 背景色
            navBarAppearance.backgroundColor = UIColor.brown
            // 去掉半透明效果
            navBarAppearance.backgroundEffect = nil
            // 去除导航栏阴影（如果不设置clear，导航栏底下会有一条阴影线）
            navBarAppearance.shadowColor = UIColor.clear
            // 字体颜色
            navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
}

