//
//  HomeVC.swift
//  FirebaseLogin
//
//  Created by kavita chauhan on 12/05/24.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

class HomeVC: UIViewController {
    
    @IBOutlet weak var userTableVw: UITableView!
    @IBOutlet weak var dateView: UIView!
    
    //MARK: Properties
    var userLists:[[String:Any]] = []
    let imagePicker = UIImagePickerController()
    var selectedImg:UIImage?
    var selectedDob:String?
    var loginEmail:String = ""
    var currentUserUid:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration()
    }
    
    //MARK: Function Configuration
    func configuration(){
        
        fetchData()
        imagePicker.delegate = self
        userTableVw.delegate = self
        userTableVw.dataSource = self
        
        let userNib = UINib(nibName: "UserListCell", bundle: nil)
        self.userTableVw.register(userNib, forCellReuseIdentifier: "UserListCell")
    }
    
    //MARK: Function FetchData from Database
    func fetchData(){
        
        let ref = Database.database().reference().child("Users")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {
                print("No data available")
                return
            }
            self.userLists.removeAll()
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else { continue }
                
                if let userData = childSnapshot.value as? [String: Any] {
                    if let email = userData["email"] as? String, email == self.loginEmail {
                        let childKey = childSnapshot.key
                        self.currentUserUid = childKey
                    }
                    self.userLists.append(userData)
                }
                self.userTableVw.reloadData()
            }
        }
        
    }
    
    //MARK: Function Add Data
    func fetchUpdate<T>(key: String, value: T) {
        let ref = Database.database().reference().child("Users")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {
                print("No data available")
                return
            }
            
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else { continue }
                
                if let userData = childSnapshot.value as? [String: Any] {
                    if let email = userData["email"] as? String, email == self.loginEmail {
                        let childKey = childSnapshot.key
                        self.currentUserUid = childKey
                        let userRef = ref.child(childKey)
                        userRef.updateChildValues([key: value])
                        self.fetchData()
                    }
                }
            }
        }
    }
    
    
    //MARK: Function Upload Image in Storage
    func uploadImageToFirebaseStorage(imageData: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let storageRef = Storage.storage().reference().child("images").child(currentUserUid)
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    
                    let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])
                    completion(.failure(unknownError))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
        
    }
    
    //MARK: Function Fetch Image Data
    func fetchImageFromURL(imageURL: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        
        let session = URLSession.shared
        let task = session.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let imageData = data else {
                
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(unknownError))
                return
            }
            
            if let image = UIImage(data: imageData) {
                completion(.success(image))
            } else {
                
                let unknownError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create UIImage from image data"])
                completion(.failure(unknownError))
            }
        }
        
        task.resume()
    }
    
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Function Select Image
    @IBAction func btnSelectDate(_ sender: Any) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        view.addSubview(datePicker)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: dateView.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: dateView.centerYAnchor).isActive = true
        
        datePicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
    }
    
    //MARK: Function Select DOB
    @objc func didChangeDate(_ sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: sender.date)
        print(date)
        fetchUpdate(key: "dob", value: date)
        
        
    }
    
    
    @IBAction func btnCaptureImage(_ sender: Any) {
        choosePicture()
    }
    
    
    
}
//MARK: Delegate and Datasource Method
extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        cell.lblName.text = userLists[indexPath.row]["name"] as? String
        cell.lblEmail.text = userLists[indexPath.row]["email"] as? String
        if let dob = userLists[indexPath.row]["dob"] as? String {
            cell.lblDob.isHidden = false
            cell.lblDob.text = dob
        }
        
        if let image = userLists[indexPath.row]["profileUrl"] as? String {
            print("imageData-=-=", image)
            if let imgUrl = URL(string: image) {
                cell.profileImg.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: "Logo")) { (image, error, cacheType, url) in
                    if let error = error {
                        print("Error fetching image: \(error)")
                    }
                }
            } else {
                // Handle invalid URL
                cell.profileImg.image = UIImage(named: "Logo")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
//MARK: Image Picker Delegate
extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @objc func choosePicture(){
        let alert  = UIAlertController(title: "Select Image", message: "", preferredStyle: .actionSheet)
        alert.modalPresentationStyle = .overCurrentContext
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let popoverController = alert.popoverPresentationController
        
        popoverController?.permittedArrowDirections = .up
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- ***************  UIImagePickerController delegate Methods ****************
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
            fatalError("Failed to convert image to data")
        }
        
        uploadImageToFirebaseStorage(imageData: imageData) { result in
            switch result {
            case .success(let downloadURL):
                print("Image uploaded successfully. Download URL: \(downloadURL)")
                self.fetchUpdate(key: "profileUrl", value: downloadURL.absoluteString)
            case .failure(let error):
                print("Error uploading image: \(error)")
                // Handle error
            }
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
