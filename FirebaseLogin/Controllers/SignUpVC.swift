//
//  SignUpVC.swift
//  FirebaseLogin
//
//  Created by kavita chauhan on 12/05/24.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpVC: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    var ref = DatabaseReference.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        
        txtName.setLeftPadding(15)
        txtEmail.setLeftPadding(15)
        txtPassword.setLeftPadding(15)
        
    }
    
    //MARK: Button Sign Up
    @IBAction func btnSignUp(_ sender: Any) {
       
        if txtName.text!.isEmpty && txtEmail.text!.isEmpty && txtPassword.text!.isEmpty{
            self.displayAlert(message: "Required all fields")
        }else if self.isValidEmail(txtEmail.text!) == false{
            self.displayAlert(message: "Plase enter valid email")
        }else if isValidPassword(txtPassword.text!) == false{
            self.displayAlert(message: "Please enter 6 digit password")
        }else{
            saveData()
            registerUser()
        }
    }
    
    //MARK: Function Save Data
    func saveData(){
        var user = self.ref.child("Users").childByAutoId()
        let dict = ["name":txtName.text,"email":txtEmail.text]
        user.setValue(dict)
    }
    
    //MARK: Function Register Data
    func registerUser(){
        Auth.auth().createUser(withEmail: txtEmail.text ?? "", password: txtPassword.text ?? "") { authResult, error in
          if let error = error as? NSError {
              self.displayAlert(message: error.localizedFailureReason ?? error.localizedDescription)
          } else {
            print("User signs up successfully")
            self.navigationController?.popViewController(animated: true)
              
          }
        }
    }
   
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Function Password validation
    func isValidPassword(_ password: String) -> Bool {
      let minPasswordLength = 6
      return password.count >= minPasswordLength
    }
    
}
