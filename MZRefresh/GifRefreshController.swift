//
//  GifRefreshController.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/14.
//

import UIKit

class GifRefreshController: UIViewController, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        cell?.selectionStyle = .none
        cell?.textLabel?.text = "第\(indexPath.row + 1)行"
        return cell!
    }
    
    lazy var animationImages: [UIImage] = {
        var images = [UIImage]()
        for i in 1...6 {
            images.append(UIImage(named: "running\(i)")!)
        }
        return images
    }()
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.setRefreshHeader(MZRefreshGifHeader(images: animationImages, size: 60, beginRefresh: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                self?.count = 10
                self?.tableView.reloadData()
                self?.tableView.stopHeaderRefreshing()
            }
        }))
        
        tableView.setRefreshFooter(MZRefreshGifFooter(images: animationImages, size: 60, beginRefresh: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                self?.count += 10
                self?.tableView.reloadData()
                self?.tableView.stopFooterRefreshing()
            }
        }))
        
//        let path = Bundle.main.path(forResource: "1", ofType: "gif")!
//        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
//        tableView.setRefreshHeader(MZRefreshGifHeader(gifImage: data, beginRefresh: {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
//                self?.count = 10
//                self?.tableView.reloadData()
//                self?.tableView.stopHeaderRefreshing()
//            }
//        }))
//
//        tableView.setRefreshFooter(MZRefreshGifFooter(gifImage: data, beginRefresh: {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
//                self?.count += 10
//                self?.tableView.reloadData()
//                self?.tableView.stopFooterRefreshing()
//            }
//        }))
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
