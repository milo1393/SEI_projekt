//
//  RegisterViewController.swift
//  SEI_LoginRegister
//
//  Created by Marko Milosavljevic on 26.06.21.
//

import UIKit
import NoveFeatherIcons
import FirebaseAuth
import FirebaseStorage
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Feather.getIcon(.image)
        imageView.tintColor = UIColor(named: "primary")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView 
    }()
    
    private var selectedImage: UIImage? = nil
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField = CustomUITextField(icon: Feather.getIcon(.mail), placeholder: "Email", frame: .null)
    private let firstNameField = CustomUITextField(icon: Feather.getIcon(.user), placeholder: "First Name", frame: .null)
    private let lastNameField = CustomUITextField(icon: Feather.getIcon(.user), placeholder: "Last Name", frame: .null)
    private let passwordField: CustomUITextField = {
        let field = CustomUITextField(icon: Feather.getIcon(.lock), placeholder: "Password", frame: .null)
        field.isSecureTextEntry = true
        return field
    }()
    
    private let registerButton: CustomUIButton = {
        let button = CustomUIButton(title: "Register", color: UIColor(named: "highlight"), frame: .null)
        return button
    }()
    
    var genderSelection: UISegmentedControl = {
        let items = ["MALE", "FEMALE"]
        let controller = UISegmentedControl(items: items)
        controller.selectedSegmentIndex = 0
        controller.layer.cornerRadius = 10.0  // Don't let background bleed
        controller.backgroundColor = .white
        controller.tintColor = .white
        controller.selectedSegmentTintColor = UIColor(named: "primary")
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        controller.setTitleTextAttributes(titleTextAttributes, for: .selected)
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // ADD SUBVIEW
        view.addSubview(scrollView)
        
        // Subview to ScrollView
        scrollView.addSubview(imageView)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(registerButton)
        scrollView.addSubview(genderSelection)
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        gesture.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true //dont know if we need this
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapChangeProfilePic(){
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let imageWidth = scrollView.width / 2.5
        
        imageView.layer.cornerRadius = imageWidth / 2 //to make it round
        imageView.frame = CGRect(x: (view.width - imageWidth) / 2, y: 40, width: imageWidth, height: imageWidth)
        
        genderSelection.frame = CGRect(x: 30, y: imageView.bottom + 50, width: scrollView.width - 60, height: 43)
        firstNameField.frame = CGRect(x: 30, y: genderSelection.bottom + 30, width: scrollView.width - 60, height: 43)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 10, width: scrollView.width - 60, height: 43)
        emailField.frame = CGRect(x: 30, y: lastNameField.bottom + 10, width: scrollView.width - 60, height: 43) //52 height is standard
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 43) //52 height is standard
        registerButton.frame = CGRect(x: 30 , y: passwordField.bottom + 10, width: scrollView.width - 60, height: 43)
    }
    
    @objc private func registerButtonTapped(){
        
        emailField.resignFirstResponder() //hide keyboard
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        //check if password and email are not empty, check if password is mind. 6 characters long
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        //FIREBASE REGISTER USER
        UserManager.shared.userExists(with: email, completion: { [weak self] exists in
            
            guard let strongSelf = self else { return }
            guard !exists else {
                //user already exists
                strongSelf.alertUserLoginError(message: "Looks like a User with this email already exists.")
                return
            }
            
            //CREATE USER
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard let result = authResult, error == nil else {
                    strongSelf.alertUserLoginError(message: "Error creating User: \(error.debugDescription)")
                    return
                }
                
                var profileImageURL: String?
                let gender: Gender = (self?.genderSelection.selectedSegmentIndex == 0) ?  Gender.MALE : Gender.FEMALE
                var usertoUpload = User(userID: result.user.uid, firstName: firstName, lastName: lastName, email: email, gender: gender, profilePictureURL: profileImageURL)
                
                //UPLOAD PROFILE IMAGE
                if let image = strongSelf.selectedImage, let data = image.pngData() {
                    StorageManager.shared.uploadProfilePicture(with: data, fileName: result.user.uid, completion: { imageResult in
                        switch imageResult {
                        case .failure(let error):
                            print("Storage Manager Error: \(error.localizedDescription)")
                            strongSelf.uploadUserData(user: usertoUpload, result: result)
                        case .success(let downloadUrl):
                            print("Url to Profileimage: \(downloadUrl)")
                            profileImageURL = downloadUrl
                            usertoUpload.profilePictureURL = profileImageURL
                            strongSelf.uploadUserData(user: usertoUpload, result: result)
                        }
                    })} else {
                        strongSelf.uploadUserData(user: usertoUpload, result: result)
                    }
            })
        })
    }
    
    private func uploadUserData(user: User, result: AuthDataResult){
        //UPLOAD USER DATA
        UserManager.shared.insertUser(with: user){ success in
            
            if (success){
                DispatchQueue.main.async {
                    self.spinner.dismiss()
                }
                
                result.user.sendEmailVerification(completion: {_ in
                    try? FirebaseAuth.Auth.auth().signOut()
                    let alert = UIAlertController(title: "Welcome!", message: "We sent you a verification link! Please accept it and login to the app.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
                })
            } else {
                self.alertUserLoginError(message: "Error uplaoding your User Data!")
            }
        }
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create a account!"){
        DispatchQueue.main.async {
            self.spinner.dismiss() //hide spinner
        }
        
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}


extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
            
        } else if textField == passwordField {
            registerButtonTapped() //when pressing enter in password field -> try to log in
        }
        return true
    }
}

//Image Picker
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in self?.presentImagePicker(source: .camera)}))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self]_ in self?.presentImagePicker(source: .photoLibrary)}))
        present(actionSheet, animated: true)
        
    }
    
    func presentImagePicker(source :UIImagePickerController.SourceType){
        let vc = UIImagePickerController()
        vc.sourceType = source
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.selectedImage = selectedImage
        self.imageView.image = selectedImage
    }
    
    
}
