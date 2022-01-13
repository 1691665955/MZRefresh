//
//  RefreshTypeController.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/13.
//

import UIKit
import NVActivityIndicatorView

class RefreshTypeController: UIViewController, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presentingIndicatorTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RefreshTypeCell", for: indexPath) as! RefreshTypeCell
        cell.indicatorType = self.presentingIndicatorTypes[indexPath.row]
        return cell
    }
    

    lazy var collectionView: UICollectionView = {
        let space: CGFloat = 15.0
        let itemWidth = (SCREEN_WIDTH - space * 4) / 3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 20)
        layout.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
        layout.minimumLineSpacing = space
        layout.minimumInteritemSpacing = space
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.register(RefreshTypeCell.classForCoder(), forCellWithReuseIdentifier: "RefreshTypeCell")
        return collectionView
    }()
    
    private let presentingIndicatorTypes = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.collectionView)
    }

}
