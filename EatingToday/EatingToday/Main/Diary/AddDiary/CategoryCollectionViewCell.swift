//
//  CategoryCollectionViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/14.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    let cellView = UIView()
    let foodImageView = UIImageView()
    let categoryLabel = UILabel()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewConfigure()
        self.constraintConfigure()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    private func viewConfigure() {
        self.addSubview(self.cellView)
        self.cellView.addSubview(self.foodImageView)
        self.foodImageView.image = UIImage(systemName: "house")
        
        self.cellView.addSubview(self.categoryLabel)
        self.categoryLabel.textAlignment = .center
        self.categoryLabel.textColor = .black
        self.categoryLabel.text = "라면"
        self.categoryLabel.font = UIFont(name: "Helvetica Bold", size: 16)

    }
    
    private func constraintConfigure() {
        
        self.cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.foodImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        self.categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(self.foodImageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
}
