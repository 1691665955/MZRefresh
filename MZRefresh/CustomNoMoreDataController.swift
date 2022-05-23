//
//  CustomNoMoreDataController.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/5/23.
//

import UIKit

class CustomNoMoreDataController: UIViewController, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        cell?.selectionStyle = .none
        cell?.textLabel?.text = "第\(indexPath.row + 1)行"
        return cell!
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.setRefreshHeader(MZRefreshNormalHeader(type: .ballClipRotatePulse, color: .brown, showTime: false, beginRefresh: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                self?.count = 10
                self?.tableView.reloadData()
                self?.tableView.stopHeaderRefreshing()
            }
        }))
        tableView.setRefreshFooter(MZRefreshNormalFooter(type: .ballClipRotatePulse, color: .brown, beginRefresh: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                self?.count += 10
                self?.tableView.reloadData()
                self?.tableView.stopFooterRefreshingWithNoMoreData()
            }
        }))
        
        // 自定义NoMoreData组件
        let footer = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 40))
        footer.font = .systemFont(ofSize: 14)
        footer.textAlignment = .center
        footer.textColor = .black
        footer.text = "—— 生活的强者，往往都能坚持到底 ——"
        footer.textColor = .brown
        tableView.setRefreshNoMoreDataView(footer)
        return tableView
    }()
    
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.startHeaderRefreshing()
    }

}
