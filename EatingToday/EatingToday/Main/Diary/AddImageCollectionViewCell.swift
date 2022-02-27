//
//  AddImageCollectionViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/27.
//

import UIKit

class AddImageCollectionViewCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewConfigure()
        constraintConfigure()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    func viewConfigure() {
        self.addSubview(imageView)
        
    }
    
    func constraintConfigure() {
        self.imageView.snp.makeConstraints{ make in
            make.top.leading.bottom.trailing.equalToSuperview().offset(0)
            
            
        }
    }
}
