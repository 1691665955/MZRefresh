//
//  RefreshTypeCell.swift
//  MZRefresh
//
//  Created by 曾龙 on 2022/1/13.
//

import UIKit
import NVActivityIndicatorView

class RefreshTypeCell: UICollectionViewCell {
    var indicatorType: NVActivityIndicatorType? {
        didSet {
            self.indicatorView?.stopAnimating()
            self.indicatorView?.removeFromSuperview()
            let space: CGFloat = 15.0
            let itemWidth = (SCREEN_WIDTH - space * 4) / 3
            self.indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemWidth), type: indicatorType ?? .blank, color: .brown, padding: 10)
            self.contentView.addSubview(self.indicatorView!)
            self.indicatorView?.startAnimating()
            
            self.indicatorNameLabel.text = "\(indicatorType ?? .blank)"
        }
    }
    
    private var indicatorView: NVActivityIndicatorView?
    
    private var indicatorNameLabel: UILabel = {
        let space: CGFloat = 15.0
        let itemWidth = (SCREEN_WIDTH - space * 4) / 3
        
        let label = UILabel(frame: CGRect(x: 0, y: itemWidth, width: itemWidth, height: 20))
        label.font = .systemFont(ofSize: 12)
        label.textColor = .brown
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(indicatorNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
