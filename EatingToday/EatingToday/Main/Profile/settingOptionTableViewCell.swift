//
//  settingOptionTableViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/04/04.
//

import UIKit

class settingOptionTableViewCell: UITableViewCell {
    
    let optionNameLabel = UILabel()
    
    let arrowImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewConfigure()
        self.constraintConfigure()

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    func viewConfigure() {
        self.backgroundColor = .white
        self.addSubview(self.optionNameLabel)
        self.optionNameLabel.textColor = .darkGray
        self.optionNameLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.addSubview(self.arrowImageView)
        self.arrowImageView.image = UIImage(named: "next")
        self.arrowImageView.tintColor = .lightGray
        
    }
    
    func constraintConfigure() {
        
        self.optionNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        self.arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(16)
        }
        
        
    }
}
