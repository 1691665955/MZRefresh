//
//  NormalRefreshController.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/11.
//

import UIKit

class NormalRefreshController: UIViewController {

    var count: Int = 0
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.setRefreshHeader(MZRefreshNormalHeader(beginRefresh: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) { [weak self] in
                self?.loadNew(Int.random(in: 2...6))
            }
        }))
        scrollView.setRefreshFooter(MZRefreshNormalFooter(beginRefresh: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) { [weak self] in
                self?.loadMore(Int.random(in: 0...5))
            }
        }))
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.init(dynamicProvider: { traitCollection in
                return (traitCollection.userInterfaceStyle == .dark) ? .black : .white
            })
        } else {
            self.view.backgroundColor = .white
        }
        self.view.addSubview(scrollView)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(headerRefresh))
        
        self.scrollView.startHeaderRefreshing(animated: false)
    }
    
    @objc func headerRefresh() {
        self.scrollView.startHeaderRefreshing(animated: true)
    }
    
    func loadNew(_ count: Int) {
        self.loadData(count, isNew: true)
    }
    
    func loadMore(_ count: Int) {
        self.loadData(count, isNew: false)
    }
    
    func loadData(_ count: Int, isNew: Bool) {
        
        if isNew {
            self.scrollView.subviews.forEach { subView in
                subView.removeFromSuperview()
            }
        }
        let start: Int = isNew ? 0 : self.count
        let end: Int = isNew ? count : self.count + count
        for i in start..<end {
            let subView = UIView(frame: CGRect(x: 20, y: 20 + 120 * CGFloat(i), width: SCREEN_WIDTH - 40, height: 100))
            subView.backgroundColor = [UIColor.red, UIColor.brown, UIColor.purple][i % 3]
            scrollView.addSubview(subView)
            if i == end - 1 {
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: subView.frame.maxY + 20)
            }
        }
        if isNew {
            self.count = count
            self.scrollView.stopHeaderRefreshing()
        } else {
            self.count += count
            self.scrollView.stopFooterRefreshing()
        }
    }
}
