//
//  LoginViewController.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import UIKit
import NoveFeatherIcons
import FirebaseAuth
import JGProgressHUD


class LoginViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LoginImage")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let emailField: CustomUITextField = CustomUITextField(icon: Feather.getIcon(.mail), placeholder: "Email", frame: .null)

    private let passwordField: CustomUITextField = {
        let field = CustomUITextField(icon: Feather.getIcon(.lock), placeholder: "Password", frame: .null)
        field.isSecureTextEntry = true
        return field
    }()

    var forgetPasswordLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Forgot Password? - Click to reset!",
                                                  attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()

    private let loginButton: CustomUIButton = {
        let button = CustomUIButton(title: "Log in", color: UIColor(named: "primary"), frame: .null)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"
        view.backgroundColor = .white

        self.navigationController?.navigationBar.tintColor = UIColor(named: "highlight")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))

        // Do any additional setup after loading the view.
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapForgetPassword))
        gesture.numberOfTapsRequired = 1
        forgetPasswordLabel.isUserInteractionEnabled = true
        forgetPasswordLabel.addGestureRecognizer(gesture)

        emailField.delegate = self
        passwordField.delegate = self

        // ADD SUBVIEW
        view.addSubview(scrollView)

        // Subview to ScrollView
        scrollView.addSubview(imageView)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(forgetPasswordLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
        let imageWidth = scrollView.width / 2

        imageView.frame = CGRect(x: (view.width - imageWidth) / 2, y: 40, width: imageWidth, height: imageWidth)
        emailField.frame = CGRect(x: 30, y: scrollView.height/2.5, width: scrollView.width - 60, height: 43) //52 height is standard
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 43)
        loginButton.frame = CGRect(x: 30 , y: passwordField.bottom + 10, width: scrollView.width - 60, height: 43)
        forgetPasswordLabel.frame = CGRect(x: 30, y: loginButton.bottom + 10, width: scrollView.width - 60, height: 30)
    }

    @objc func didTapForgetPassword(){
        let vc = ForgotPasswordViewController()
        let nav = UINavigationController(rootViewController: vc)
        vc.preferredContentSize = CGSize(width: view.frame.width/2, height: view.frame.height/2)
        nav.modalPresentationStyle = .formSheet //so user can not dismiss login page
        present(nav, animated: true)
    }

    @objc private func loginButtonTapped(){
        spinner.show(in: view)
        emailField.resignFirstResponder() //hide keyboard
        passwordField.resignFirstResponder()

        //check if password and email are not empty; check if password is mind. 6 characters long
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }

        print("User logged in!")
        //FIREBASE LOGIN
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in

            guard let strongSelf = self else {return}

            DispatchQueue.main.async{
                strongSelf.spinner.dismiss()
            }

            guard let result = authResult, error == nil else {
                strongSelf.alertUserLoginError(message: "Error signing in to Firebase: \(String(describing: error?.localizedDescription))")
                return
            }
            let user = result.user

            if(!result.user.isEmailVerified){
                strongSelf.alertUserLoginError(message: "User is not email verified. Please accept the link we sent you!")
                return
            }

            print("Logged in: \(user)")
            UserManager.shared.getUser(userID: user.uid, completion: {resUser in
                guard let u = resUser else {
                    strongSelf.alertUserLoginError(message: "User was not found in Database!")
                    return
                }

                UserManager.shared.setUserDefaults(currentUser: u){success in
                    if success {
                        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                    } else {
                        strongSelf.alertUserLoginError(message: "Error storing your User Data to User Defaults: )")
                    }
                }

            })
        })
    }

    func alertUserLoginError(message: String = "Please enter all information to log in!"){

        DispatchQueue.main.async {
            self.spinner.dismiss()
        }

        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()

        } else if textField == passwordField {
            loginButtonTapped() //when pressing enter in password field -> try to log in
        }
        return true
    }
}
