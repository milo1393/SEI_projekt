//
//  ForgotPasswordController.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import UIKit
import NoveFeatherIcons
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField: CustomUITextField = CustomUITextField(icon: Feather.getIcon(.mail), placeholder: "Email", frame: .null)

    
    private let resetPasswordButton: CustomUIButton = {
        let button = CustomUIButton(title: "Send Reset", color: UIColor(named: "primary"), frame: .null)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reset Password"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor(named: "highlight");
        self.preferredContentSize = CGSize(width: 100, height: 100)
        
        // Do any additional setup after loading the view.
        resetPasswordButton.addTarget(self, action: #selector(resetPasswordButtonTapped), for: .touchUpInside)
        
        
        // ADD SUBVIEW
        view.addSubview(scrollView)
        
        // Subview to ScrollView
        scrollView.addSubview(emailField)
        scrollView.addSubview(resetPasswordButton)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        emailField.frame = CGRect(x: 30, y: 30, width: scrollView.width - 60, height: 43) //52 height is standard
        resetPasswordButton.frame = CGRect(x: 30 , y: view.bottom - 200, width: scrollView.width - 60, height: 43)
    }
    
    @objc private func resetPasswordButtonTapped(){
        emailField.resignFirstResponder() //hide keyboard
        //check if password and email are not empty; check if password is mind. 6 characters long
        guard let email = emailField.text, !email.isEmpty else {
            alertUserResetPasswordError()
            return
        }
    
        //Send Password Reset
        Auth.auth().sendPasswordReset(withEmail: email) {[weak self] error in
            guard let strongself = self else {return}
            guard error == nil else {
                strongself.alertUserResetPasswordError(message: "Firebase Error: \(String(describing: error?.localizedDescription))")
                return
            }
            strongself.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func alertUserResetPasswordError(message: String = "Please enter all information to reset your Password!"){
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

