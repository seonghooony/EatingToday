//
//  MapCategoryCollectionViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/04/12.
//

import UIKit


class MapCategoryCollectionViewCell: UICollectionViewCell {
    
    let cellView = UIView()
    let categoryImageView = UIImageView()
    let categoryLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            if !isSelected {
                self.cellView.backgroundColor = UIColor.white
                self.categoryLabel.textColor = .black
            } else {
                self.cellView.backgroundColor = UIColor(displayP3Red: 255/255, green: 107/255, blue: 107/255, alpha: 1)
                self.categoryLabel.textColor = .white
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewConfigure()
        self.constraintConfigure()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    private func viewConfigure() {
        self.backgroundColor = .clear
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        
        self.cellView.backgroundColor = .white
        self.cellView.layer.cornerRadius = 17.5
        self.cellView.layer.masksToBounds = true
        self.addSubview(self.cellView)
        self.cellView.addSubview(self.categoryImageView)
        self.categoryImageView.backgroundColor = .clear
        self.cellView.addSubview(self.categoryLabel)
        self.categoryLabel.textAlignment = .center
        self.categoryLabel.textColor = .black
        self.categoryLabel.font = UIFont(name: "Helvetica Bold", size: 14)
    }
    
    private func constraintConfigure() {
        self.cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.categoryImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.width.height.equalTo(20)
        }
        
        self.categoryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.categoryImageView.snp.trailing).offset(10)
        }
        
    }
}
