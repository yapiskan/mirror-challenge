//
//  SliderView.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/26/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

final class SliderView: BaseView {
    var title = "SLIDER"
    var titleLabel = UILabel()
    var slider = UISlider()
    var onChange: ((Int) -> (String))?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(slider)
        slider.addTarget(self, action: #selector(didValueChange), for: .valueChanged)
        
        setNeedsUpdateConstraints()
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        
        self.title = title
        titleLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.snp.makeConstraints({ (make) in
                make.left.right.top.equalToSuperview()
            })
            
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.snp.makeConstraints({ (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(30)
                make.top.equalTo(titleLabel.snp.bottom)
            })
            
            didSetupConstraints = true
        }
        
        super.updateConstraints()
    }
    
    func minimumValue(_ value: Int) {
        slider.minimumValue = Float(value)
    }
    
    func maximumValue(_ value: Int) {
        slider.maximumValue = Float(value)
    }
    
    func value(_ value: Int) {
        slider.value = Float(value)
        didValueChange()
    }
    
    func value() -> Int {
        return Int(slider.value)
    }
    
    @objc
    private func didValueChange() {
        let value = Int(slider.value)
        if let valueToDisplay = onChange?(value) {
            titleLabel.text = "\(title): \(valueToDisplay)"
        }
    }
}
