//
//  PopDateCalendarViewController.swift
//  EatingToday
//
//  Created by SeongHoon Kim on 2022/03/14.
//

import UIKit
import SnapKit
import FSCalendar

protocol setPickedDateDelegate: AnyObject {
    
    func setPickedDate(date: Date)
    
}

class PopDateCalendarViewController: UIViewController {
    
    let todayColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
    let selectedColor = UIColor(cgColor: CGColor(red: 216/255, green: 33/255, blue: 72/255, alpha: 1.0))
    let selectFontColor = UIColor(cgColor: CGColor(red: 7/255, green: 34/255, blue: 39/255, alpha: 1.0))
    
    weak var setPickedDateDelegate: setPickedDateDelegate?
    
    let popupView = UIView()
    let titleLabel = UILabel()
    
    let mainView = UIView()
    let calendarView = FSCalendar()
    
    let closeButton = UIButton()
    let dateFormatter = DateFormatter()
    
    var previousPickDate: Date?
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewConfigure()
        self.constraintConfigure()
    }
    
    @objc private func popCloseTapped() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private func viewConfigure() {
        
        self.view.addSubview(self.popupView)
        let shadowSize: CGFloat = 5.0
        self.popupView.layer.shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2, y: -shadowSize / 2, width: self.view.frame.size.width * 0.9 + shadowSize, height: 400 + shadowSize)).cgPath
        self.popupView.layer.shadowColor = UIColor.black.cgColor
        self.popupView.layer.shadowOffset = .zero
        self.popupView.layer.shadowRadius = 8
        self.popupView.layer.shadowOpacity = 0.5
        self.popupView.layer.masksToBounds = false
        
        self.popupView.layer.cornerRadius = 15
        self.popupView.backgroundColor = .white
        
        self.popupView.addSubview(self.closeButton)
        self.closeButton.setImage(UIImage(named: "logo_close"), for: .normal)
        self.closeButton.tintColor = .darkGray
        self.closeButton.addTarget(self, action: #selector(popCloseTapped), for: .touchUpInside)
        
        self.popupView.addSubview(self.titleLabel)
        self.titleLabel.textColor = .black
        self.titleLabel.text = "식사하신 날짜 선택"
        self.titleLabel.font = UIFont(name: "Helvetica Bold", size: 18)
        
        self.popupView.addSubview(self.mainView)
        
        self.mainView.addSubview(self.calendarView)
        self.calendarView.delegate = self
        self.calendarView.dataSource = self
        self.dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        self.calendarView.appearance.headerDateFormat = "YYYY년 M월"
        self.calendarView.appearance.headerTitleColor = .black
        self.calendarView.appearance.headerTitleFont = UIFont(name: "Helvetica Bold", size: 15)
        self.calendarView.locale = Locale(identifier:  "ko_KR")
        
        self.calendarView.appearance.weekdayTextColor = .darkGray
        self.calendarView.appearance.weekdayFont = UIFont(name: "Helvetica Bold", size: 13)
        
        self.calendarView.appearance.borderRadius = 0.3
        
        self.calendarView.appearance.todayColor = todayColor
        self.calendarView.appearance.titleTodayColor = .blue
        self.calendarView.appearance.subtitleTodayColor = .darkGray
        
        self.calendarView.appearance.titleSelectionColor = .white
        self.calendarView.appearance.subtitleSelectionColor = .white
        self.calendarView.appearance.selectionColor = selectedColor
        
        if let preDate = previousPickDate {
            self.calendarView.select(preDate, scrollToDate: true)
        }
        
        
        
        
        
        
        
        
    }
    
    private func constraintConfigure() {
        let leadingTrailingSize = 20
        
        self.popupView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(400)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(leadingTrailingSize - 2)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.width.height.equalTo(24)
        }
        
        self.closeButton.imageView?.snp.makeConstraints { make in
            make.height.width.equalTo(15)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(leadingTrailingSize - 2)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.height.equalTo(20)
        }
        
        self.mainView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(leadingTrailingSize)
            make.trailing.equalToSuperview().offset(-leadingTrailingSize)
            make.bottom.equalToSuperview().offset(-leadingTrailingSize)
        }
        
        self.calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
}


extension PopDateCalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        //print(dateFormatter.string(from: date) + "이 선택됨")
        
        setPickedDateDelegate?.setPickedDate(date: date)
        
        self.dismiss(animated: false, completion: nil)
        
    }
    
    
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        //print(dateFormatter.string(from: date) + "이 해제됨")
    }
    
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        switch dateFormatter.string(from: date) {
        case dateFormatter.string(from: Date()):
            return "오늘"
        default:
            return nil
        }
    }
}
