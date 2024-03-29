//
//  DefaultNoMoreDataController.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/5/23.
//

import UIKit

class DefaultNoMoreDataController: UIViewController, UITableViewDataSource {

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
        let tableView = UITableView()
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
        return tableView
    }()
    
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.init(dynamicProvider: { traitCollection in
                return (traitCollection.userInterfaceStyle == .dark) ? .black : .white
            })
        } else {
            self.view.backgroundColor = .white
        }
        self.view.addSubview(self.tableView)
        makeConstraints()
        
        self.tableView.startHeaderRefreshing()
    }

}

extension DefaultNoMoreDataController {
    func makeConstraints() {
        tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}
