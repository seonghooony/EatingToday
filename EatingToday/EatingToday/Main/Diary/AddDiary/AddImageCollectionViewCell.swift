//
//  AddImageCollectionViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/27.
//

import UIKit
protocol deleteIndexImageDelegate: AnyObject {
    func deleteIndexImage(index: Int)
}


class AddImageCollectionViewCell: UICollectionViewCell {
    
    var deleteIndexImageDelegate: deleteIndexImageDelegate?
    
    var cellIndex: Int?
    
    var imageView = UIImageView()
    var deleteButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewConfigure()
        constraintConfigure()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    
    @objc func deleteImageTapped() {
        print(cellIndex)
        if let idx = cellIndex {
            deleteIndexImageDelegate?.deleteIndexImage(index: idx - 1)
        }
    }
    
    func viewConfigure() {
        self.addSubview(imageView)
        self.addSubview(deleteButton)
        self.deleteButton.setImage(UIImage(systemName: "xmark.app.fill"), for: .normal)
        self.deleteButton.tintColor = .gray
        self.deleteButton.addTarget(self, action: #selector(deleteImageTapped), for: .touchUpInside)
        
        
        
    }
    
    func constraintConfigure() {
        self.imageView.snp.makeConstraints{ make in
            make.top.leading.bottom.trailing.equalToSuperview().offset(0)
            
        }

        self.deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.height.width.equalTo(20)
        }
            
        
        
    }
}
