//
//  LoginVC.swift
//  FirebaseLogin
//
//  Created by kavita chauhan on 12/05/24.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        txtEmail.text = ""
        txtPassword.text = ""
    }
    
    //MARK: Button Login
    @IBAction func btnLogin(_ sender: Any) {
       
        if txtEmail.text!.isEmpty && txtPassword.text!.isEmpty {
            self.displayAlert(message: "Please enter email and password")
        }else if self.isValidEmail(txtEmail.text!) == false{
            self.displayAlert(message: "Please enter valid email")
        }else{
            loginUser()
        }
        
    
    }
    
    //MARK: Function Login
    func loginUser(){
        Auth.auth().signIn(withEmail: txtEmail.text ?? "", password: txtPassword.text ?? "") { (authResult, error) in
          if let error = error as? NSError {
              print("error",error.localizedFailureReason ?? "")
              self.displayAlert(message: error.localizedFailureReason ?? error.localizedDescription)
          } else {
            print("User signs up successfully")
              let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
              vc.loginEmail = self.txtEmail.text ?? ""
              self.navigationController?.pushViewController(vc, animated: true)
              
          }
        }
        
        
       
    }
    
    //MARK: Button Register
    @IBAction func btnRegsiter(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @IBAction func btnDisclamer(_ sender: Any) {
    }
    
}

//MARK: Alert Function & Email Validation
extension UIViewController {
    
    func displayAlert(title: String = "Altert ", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    
    func isValidEmail(_ email: String) -> Bool {
      let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
      return emailPred.evaluate(with: email)
    }
}



// Assuming Firebase has already been configured in your app

//        let ref = Database.database().reference()
//
//        // Get a reference to the specific location you want to delete
//        let usersRef = ref.child("Users")
//
//        // Remove all data under the "Users" node
//        usersRef.removeValue { error, _ in
//            if let error = error {
//                print("Error removing data:", error)
//            } else {
//                print("Data removed successfully.")
//            }
//        }
