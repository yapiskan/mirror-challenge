//
//  AuthViewController.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class AuthViewController: BaseViewController {
    private let viewModel: AuthViewModelProtocol
    
    private let usernameField = FloatingTextField()
    private let passwordField = FloatingTextField()
    private let loginButton = LoadingButton()
    private let signUpButton = LoadingButton()
    
    init(viewModel: AuthViewModelProtocol, router: AppRouter) {
    	self.viewModel = viewModel
        super.init(router: router)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "Auth"
        
        usernameField.placeholder = "Username"
        usernameField.returnKeyType = .next
        usernameField.delegate = self
        view.addSubview(usernameField)
        
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .join
        passwordField.delegate = self
        view.addSubview(passwordField)
        
        loginButton.setTitle("Log In", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
        
        signUpButton.setTitle("Sing Up", for: .normal)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        view.addSubview(signUpButton)
        
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            usernameField.snp.makeConstraints({ (make) in
            	make.width.equalTo(280)
                make.height.equalTo(60)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(view.safeAreaInsets.top + 60)
            })
            
            passwordField.snp.makeConstraints({ (make) in
                make.width.equalTo(280)
                make.height.equalTo(60)
                make.centerX.equalToSuperview()
                make.top.equalTo(usernameField.snp.bottom)
            })
            
            loginButton.snp.makeConstraints({ (make) in
                make.width.equalTo(280)
                make.height.equalTo(40)
                make.centerX.equalToSuperview()
                make.top.equalTo(passwordField.snp.bottom).offset(40)
            })
            
            signUpButton.snp.makeConstraints({ (make) in
                make.width.equalTo(280)
                make.height.equalTo(40)
                make.centerX.equalToSuperview()
                make.top.equalTo(loginButton.snp.bottom).offset(10)
            })
            
            didSetupConstraints = true
        }
        
        super.updateViewConstraints()
    }
    
    @objc
    private func loginButtonTapped() {
        loginButton.startLoading()
        view.isUserInteractionEnabled = false
        login { [weak self] (success) in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.loginButton.stopLoading()
                strongSelf.view.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc
    private func signUpButtonTapped() {
        signUpButton.startLoading()
        view.isUserInteractionEnabled = false
        signUp { [weak self] (success) in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.signUpButton.stopLoading()
                strongSelf.view.isUserInteractionEnabled = true
            }
        }
    }
    
    private func login(_ completion: @escaping (Bool) -> ()) {
        guard let username = usernameField.text else { return }
        guard let password = passwordField.text else { return }
        
        viewModel.login(username: username, password: password) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            completion(result.isSuccess)
            if !result.isSuccess {
                strongSelf.router.showHUD(message: result.errorMessage)
				return
            }
            
            strongSelf.router.routeToHome()
        }
    }
    
    private func signUp(_ completion: @escaping (Bool) -> ()) {
        guard let username = usernameField.text else { return }
        guard let password = passwordField.text else { return }
        
        viewModel.signUp(username: username, password: password) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            if !result.isSuccess {
                strongSelf.router.showHUD(message: result.errorMessage)
            	completion(false)
            	return
            }
            
            strongSelf.login { (success) in
                completion(success)
            }
        }
    }
}

extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
            loginButton.sendActions(for: .touchUpInside)
            return true
        default:
            return false
        }
        
        return false
    }
}
