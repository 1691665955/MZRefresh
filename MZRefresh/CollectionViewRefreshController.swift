//
//  CollectionViewRefreshController.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/13.
//

import UIKit

class CollectionViewRefreshController: UIViewController, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.backgroundColor = .gray
        if cell.contentView.subviews.count == 0 {
            let label = UILabel()
            label.textColor = .white
            label.text = "第\(indexPath.row + 1)项"
            label.center = cell.contentView.center
            cell.contentView.addSubview(label)
        } else {
            if let label = cell.contentView.subviews.first as? UILabel {
                label.text = "第\(indexPath.row + 1)项"
            }
        }
        return cell
    }
    

    lazy var collectionView: UICollectionView = {
        let space: CGFloat = 15.0
        let itemWidth = (SCREEN_WIDTH - space * 3) / 2
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = UIColor.init(dynamicProvider: { traitCollection in
                return (traitCollection.userInterfaceStyle == .dark) ? .black : .white
            })
        } else {
            collectionView.backgroundColor = .white
        }
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "UICollectionViewCell")
        collectionView.setRefreshHeader(MZRefreshNormalHeader(type: .lineScaleParty, color: .brown, beginRefresh: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                self?.count = 10
                self?.collectionView.reloadData()
                self?.collectionView.stopHeaderRefreshing()
            }
        }))
        collectionView.setRefreshFooter(MZRefreshNormalFooter(type: .lineScaleParty, color: .brown, beginRefresh: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] in
                self?.count += 10
                self?.collectionView.reloadData()
                self?.collectionView.stopFooterRefreshing()
            }
        }))
        return collectionView
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
        self.view.addSubview(self.collectionView)
        self.collectionView.startHeaderRefreshing()
    }

}
