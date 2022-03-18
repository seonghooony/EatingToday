//
//  EatTableViewCell.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/02/22.
//

import UIKit
import SnapKit
import Cosmos
import Firebase
import FirebaseStorage

class EatTableViewCell: UITableViewCell {
    
    var images = [UIImage]()
    private var indexOfCellBeforeDragging = 0
    
    let headView = UIView()
    let titleStackView = UIView()
    let titleLabel = UILabel()
    let locationLabel = UILabel()
    let settingButton = UIButton()
    
    let imageContentView = UIView()
    var imageCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        //flowLayout.minimumLineSpacing = 20
        //flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.lightGray
        
        return collectionView
    }()
    
    let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.addTarget(EatTableViewCell.self, action: #selector(pageValueDidChanged), for: .valueChanged)
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
    let infoTitleLabel = UILabel()
    let scoreLabel = CosmosView()
    
    let categoryLabel = UILabel()
    let dateLabel = UILabel()
    let storyLabel = UILabel()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.viewConfigure()
        self.constraintConfigure()
//        self.setImages()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)has not been implemented")
    }
    


    
    
    func viewConfigure() {
        self.addSubview(headView)
        headView.backgroundColor = .white
        
        self.headView.addSubview(self.titleStackView)
        
        self.titleStackView.addSubview(titleLabel)
        self.titleLabel.text = "가게이름"
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .darkGray
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.titleStackView.addSubview(self.locationLabel)
        self.locationLabel.text = "장소 주소"
        self.locationLabel.textAlignment = .center
        self.locationLabel.textColor = .lightGray
        self.locationLabel.font = UIFont(name: "Helvetica", size: 13)
        
        self.headView.addSubview(settingButton)
        self.settingButton.setImage(UIImage(named: "logo_menu"), for: .normal)
        
//        if self.imageUrls != nil {
            self.addSubview(imageContentView)
            self.imageContentView.backgroundColor = .gray

        self.imageCollectionView.dataSource = self
        self.imageCollectionView.delegate = self
        self.imageCollectionView.isScrollEnabled = true
        self.imageCollectionView.showsVerticalScrollIndicator = false
        self.imageCollectionView.showsHorizontalScrollIndicator = false
        self.imageCollectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
            contentView.isUserInteractionEnabled = false
        self.imageContentView.addSubview(imageCollectionView)
            
        self.pageControl.hidesForSinglePage = true
//        self.pageControl.numberOfPages = images.count
        self.pageControl.pageIndicatorTintColor = .darkGray
        self.imageContentView.addSubview(pageControl)
//        }
        
        
        self.addSubview(self.infoContentView)
        
        self.infoContentView.addSubview(self.infoTitleLabel)
        self.infoTitleLabel.text = "정보"
        self.infoTitleLabel.textAlignment = .center
        self.infoTitleLabel.textColor = .black
        self.infoTitleLabel.font = UIFont(name: "Helvetica Bold", size: 16)
        
        self.infoContentView.addSubview(self.scoreLabel)
        self.scoreLabel.settings.fillMode = .half
        self.scoreLabel.settings.starSize = 20
        self.scoreLabel.settings.starMargin = 5
        self.scoreLabel.settings.filledColor = .orange
        self.scoreLabel.settings.emptyColor = .white
        self.scoreLabel.settings.filledBorderColor = .orange
        self.scoreLabel.settings.filledBorderWidth = 0.5
        self.scoreLabel.settings.emptyBorderColor = .orange
        self.scoreLabel.settings.emptyBorderWidth = 0.5
        self.scoreLabel.isUserInteractionEnabled = false
        
//        self.infoContentView.addSubview(self.categoryLabel)
//        self.categoryLabel.text = "카테고리"
//        self.categoryLabel.textAlignment = .center
//        self.categoryLabel.textColor = .black
//        self.categoryLabel.font = UIFont(name: "Helvetica", size: 15)
        
        self.infoContentView.addSubview(self.dateLabel)
        self.dateLabel.text = "날짜"
        self.dateLabel.textAlignment = .center
        self.dateLabel.textColor = .lightGray
        self.dateLabel.font = UIFont(name: "Helvetica", size: 15)
        
        self.infoContentView.addSubview(self.storyLabel)
        self.storyLabel.text = "이야기"
        self.storyLabel.textAlignment = .center
        self.storyLabel.textColor = .black
        self.storyLabel.font = UIFont(name: "Helvetica", size: 15)

        
        
    }
    
    func constraintConfigure() {
        
        let leadingtrailingSize = 20
        
        self.headView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(50)
            make.leading.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        self.titleStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.leading.equalToSuperview()
            make.width.equalTo(250)
        }
        
        self.titleLabel.snp.makeConstraints{ make in
            make.bottom.equalTo(self.titleStackView.snp.centerY)

            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(0)
        }
        
        self.locationLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleStackView.snp.centerY).offset(1)

            make.leading.equalToSuperview().offset(20)
        }

        self.settingButton.snp.makeConstraints{ make in
            make.centerY.equalTo(self.headView.snp.centerY)
            make.width.height.equalTo(24)
//            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
//        if self.imageUrls != nil {
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
        
        self.infoContentView.snp.makeConstraints { make in
            make.top.equalTo(self.imageContentView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        
        }
//        } else {
//            self.infoContentView.snp.makeConstraints { make in
//                make.top.equalTo(self.headView.snp.bottom)
//                make.leading.trailing.bottom.equalToSuperview()
//
//            }
//        }

        
        self.scoreLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
//            make.top.equalTo(self.infoTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        

        self.storyLabel.snp.makeConstraints { make in
            make.top.equalTo(self.scoreLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(leadingtrailingSize)
        }
        
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.storyLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-leadingtrailingSize)
        }
        
        
        
        
    }
    
    
}

extension EatTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count ?? 0
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



