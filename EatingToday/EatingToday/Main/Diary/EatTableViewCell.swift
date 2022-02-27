//
//  EatTableViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/22.
//

import UIKit
import SnapKit

class EatTableViewCell: UITableViewCell {
    
    var images = [UIImage(systemName: "pencil"), UIImage(systemName: "house"),UIImage(systemName: "person"),UIImage(systemName: "pencil")]
    private var indexOfCellBeforeDragging = 0
    
    let headView = UIView()
    let titleLabel = UILabel()
    let settingButton = UIButton()
    
    let imageContentView = UIView()
    var imageCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        //flowLayout.minimumLineSpacing = 20
        //flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.red
        
        return collectionView
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.addTarget(self, action: #selector(pageValueDidChanged), for: .valueChanged)
        return pageControl
    }()
    @objc func pageValueDidChanged() {
        let indexPath = NSIndexPath(row: pageControl.currentPage, section: 0)
        let animated: Bool = {
            return pageControl.interactionState != .continuous
        }()
        
        imageCollectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: animated)
    }
    
    let infoContentView = UIView()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewConfigure()
        self.constraintConfigure()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    


    
    func viewConfigure() {
        self.addSubview(headView)
        headView.backgroundColor = .yellow
        
        self.headView.addSubview(titleLabel)
        self.titleLabel.text = "가게이름"
        
        self.headView.addSubview(settingButton)
        self.settingButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        
        self.addSubview(imageContentView)
        self.imageContentView.backgroundColor = .gray
        
        
        
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imageCollectionView.isScrollEnabled = true
        imageCollectionView.showsVerticalScrollIndicator = false
        imageCollectionView.showsHorizontalScrollIndicator = false
        imageCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        contentView.isUserInteractionEnabled = false
        self.imageContentView.addSubview(imageCollectionView)
        
        pageControl.hidesForSinglePage = true
        pageControl.numberOfPages = images.count
        pageControl.pageIndicatorTintColor = .darkGray
        self.imageContentView.addSubview(pageControl)

        
        
    }
    
    func constraintConfigure() {
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        
        self.titleLabel.snp.makeConstraints{ make in
            make.centerY.equalTo(self.headView.snp.centerY)

            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(0)
        }

        self.settingButton.snp.makeConstraints{ make in
            make.centerY.equalTo(self.headView.snp.centerY)

//            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        self.imageContentView.snp.makeConstraints { make in
            make.top.equalTo(self.headView.snp.bottom).offset(0)
            make.height.equalTo(self.frame.size.width)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        self.imageCollectionView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().offset(0)
        }
        
        self.pageControl.snp.makeConstraints { make in
            make.top.equalTo(self.imageContentView.snp.bottom).offset(-25)
            make.centerX.equalTo(self)
        }
        
    }
    
    
}

extension EatTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        cell.backgroundColor = UIColor.brown
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    
}

extension EatTableViewCell: UICollectionViewDelegate {
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let page = Int(targetContentOffset.pointee.x / self.frame.width)
//        self.pageControl.currentPage = page
//        print(self.pageControl.currentPage)
////        self.collectionView.scrollToItem(at: IndexPath(item: self.pageControl.currentPage, section: 0), at: .right, animated: true)
//
//    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        // Stop scrolling
        targetContentOffset.pointee = scrollView.contentOffset

        // Calculate conditions
        let pageWidth = self.bounds.width// The width your page should have (plus a possible margin)
        let collectionViewItemCount = images.count// The number of items in this section
        let proportionalOffset = imageCollectionView.contentOffset.x / pageWidth
        let indexOfMajorCell = Int(round(proportionalOffset))
        let swipeVelocityThreshold: CGFloat = 0.5
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < collectionViewItemCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {
            // Animate so that swipe is just continued
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = pageWidth * CGFloat(snapToIndex)
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: velocity.x,
                options: .allowUserInteraction,
                animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            // Pop back (against velocity)
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            imageCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / self.frame.width)
        self.pageControl.currentPage = page
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pageWidth = self.bounds.width// The width your page should have (plus a possible margin)
        let proportionalOffset = imageCollectionView.contentOffset.x / pageWidth
        indexOfCellBeforeDragging = Int(round(proportionalOffset))
    }
    
}

extension EatTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.bounds.width, height: self.bounds.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}



