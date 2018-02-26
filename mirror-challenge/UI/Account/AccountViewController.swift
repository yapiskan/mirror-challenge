//
//  AccountViewController.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import UIKit

class AccountViewController: BaseViewController {
    private var viewModel: AccountViewModelProtocol
    
    private let usernameLabel = UILabel()
    private let infoLabel = UILabel()
    private let heightSlider = SliderView(title: "HEIGHT")
    private let ageSlider = SliderView(title: "AGE")
    private let logoutButton = UIButton()
    
    init(viewModel: AccountViewModelProtocol, router: AppRouter) {
        self.viewModel = viewModel
        
        super.init(router: router)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "Account"
        
        usernameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(usernameLabel)
        
        infoLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        infoLabel.numberOfLines = 0
        view.addSubview(infoLabel)
        
        heightSlider.minimumValue(0)
        heightSlider.maximumValue(240)
        view.addSubview(heightSlider)
        heightSlider.onChange = { value in
            return self.viewModel.convertToImperial(height: value)
        }
        
        ageSlider.minimumValue(0)
        ageSlider.maximumValue(100)
        view.addSubview(ageSlider)
        ageSlider.onChange = { value in
        	return "\(value)"
        }
        
        logoutButton.setTitle("Log out", for: .normal)
        logoutButton.setTitleColor(.red, for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        
        view.setNeedsUpdateConstraints()
        
        bindData()
        viewModel.onDataUpdate = { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
            	strongSelf.bindData(false)
            }
        }
        viewModel.startFetchingUser()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            usernameLabel.translatesAutoresizingMaskIntoConstraints = false
            usernameLabel.snp.makeConstraints({ (make) in
                make.top.equalToSuperview().offset(view.safeAreaInsets.top + 20)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().inset(20)
            })
            
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            infoLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(usernameLabel.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().inset(20)
            })
            
            ageSlider.translatesAutoresizingMaskIntoConstraints = false
            ageSlider.snp.makeConstraints({ (make) in
                make.top.equalTo(infoLabel.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().inset(20)
            })
            
            heightSlider.translatesAutoresizingMaskIntoConstraints = false
            heightSlider.snp.makeConstraints({ (make) in
                make.top.equalTo(ageSlider.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().inset(20)
            })
            
            logoutButton.translatesAutoresizingMaskIntoConstraints = false
            logoutButton.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(20)
            })
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    private func bindData(_ initial: Bool = true) {
        let user = viewModel.user
        usernameLabel.text = user.username
        let info = [
            "Likes Javascript?: \(user.likesJavascript ? "Yes" : "No")",
            "Magic Number: \(user.magicNumber)",
            "Magic Hash: \(user.magicHash)",
        ]
        
        infoLabel.text = info.joined(separator: "\n")
        if initial {
            heightSlider.value(user.height)
            ageSlider.value(user.age)
        }
    }
    
    @objc
    private func logoutButtonTapped() {
        router.alert(with: "Log out", message: "Do you want to log out?", actions: [("Log out", .destructive), ("Cancel", .cancel)], style: .actionSheet) { [unowned self] (success) in
            if !success { return }
            
            self.viewModel.logout()
            self.router.routeToAuth()
        }
    }
    
    @objc
    private func saveButtonTapped() {
        viewModel.updateUser(height: heightSlider.value(), age: ageSlider.value(), likesJavascript: false) { [weak self] (success) in
            guard let strongSelf = self else { return }
            
            strongSelf.router.alert(message: "\(success)")
        }
    }
}

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
