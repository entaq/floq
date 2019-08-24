//
//  AddCliqVC.swift
//  Floq
//
//  Created by Mensah Shadrach on 12/11/2018.
//  Copyright © 2018 Arun Nagarajan. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase



class AddCliqVC: UIViewController {

    private var imageView:UIImageView!
    private var imagebutt:UIButton!
    private var textField:UITextField!
    private var locationManager:CLLocationManager!
    var titleLabel:UILabel!
    private var location:CLLocation?
    private var createButton:UIButton!
    private var imagePicker:UIImagePickerController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
       navigationItem.title = "Create Cliq"
        setupViews()
        setupLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        
    }
    
    private var infoImage:UIImageView = {
        let image = UIImageView(frame: .zero)
        image.contentMode = .scaleAspectFit
        image.image = #imageLiteral(resourceName: "otherNearbyUsersC")
        return image
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        App.setDomain(.AddCliq)
    }
    
    
    func setupViews(){
        
        self.view.backgroundColor = UIColor.white
        let headerview = UIView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: 80)))
        headerview.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 46/255, alpha: 1)
        titleLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 30)))
        titleLabel.center.x = headerview.center.x
        titleLabel.center.y = 60
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.text = "Create Cliq"
        let closebutt = UIButton(frame: CGRect(x: 20, y: headerview.center.y, width: 20, height: 20))
        closebutt.setImage(UIImage.init(named: "cancel"), for: .normal)
        closebutt.addTarget(self, action: #selector(closeTapped(_:)), for: .touchUpInside)
        headerview.addSubview(closebutt)
        headerview.addSubview(titleLabel)
        
        let ibframe = CGRect(origin:CGPoint(x: 0, y: 80), size:CGSize(width: view.frame.width, height: view.frame.height * 0.35))
        imageView = UIImageView(frame:ibframe)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imagebutt = UIButton(frame: ibframe)
        imagebutt.setTitle("Add Cover Photo", for: .normal)
        imagebutt.setTitleColor(.white, for: .normal)
        imagebutt.backgroundColor = UIColor(red: 132/255, green: 149/255, blue: 165/255, alpha: 0.5)
        imagebutt.addTarget(self, action: #selector(pickImagePressed(_:)), for: .touchUpInside)
        
        
        let textviewbg = UIView(frame: CGRect(x: 0, y:80 + view.frame.height * 0.35,width: view.frame.width, height: 60))
        textviewbg.backgroundColor = UIColor(red: 78/255, green: 205/255, blue: 196/255, alpha: 1)
        textField = UITextField(frame: CGRect(x: 20, y: 10,width: view.frame.width, height: 40))
        textField.placeholder = "Give your cliq a name"
        textField.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.returnKeyType = .done
        textField.delegate = self
        textviewbg.addSubview(textField)
        
//        let infolabel = UILabel(frame: CGRect(x:0,y:132 + view.frame.height * 0.35, width: view.frame.width, height: 60))
//        infolabel.backgroundColor = .clear
//        infolabel.numberOfLines = 2
//        infolabel.textAlignment = .center
//        infolabel.textColor = UIColor(red: 132/255, green: 149/255, blue: 165/255, alpha: 1)
//        infolabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
//        infolabel.text = "Other nearby users can find this cliq"
        
        createButton = UIButton(frame: CGRect(x: 50, y: view.frame.height - 120, width: view.frame.width - 100, height: 80))
        
        createButton.setTitle("Create", for: .normal)
        createButton.setAttributedTitle(NSAttributedString(string: "Create", attributes: [ .font: UIFont.systemFont(ofSize: 30, weight: .medium), NSAttributedString.Key.foregroundColor:UIColor.white]), for: .normal)
        createButton.addTarget(self, action: #selector(createCliqPressed(_:)), for: .touchUpInside)
        createButton.backgroundColor = UIColor(red: 132/255, green: 149/255, blue: 165/255, alpha: 1)
        createButton.layer.cornerRadius = 4.0
        view.addSubview(headerview)
        view.addSubview(imageView)
        view.addSubview(imagebutt)
        view.addSubview(textviewbg)
        view.addSubview(infoImage)
        view.addSubview(createButton)
        infoImage.layout{
            $0.top == textviewbg.bottomAnchor + 16
            $0.leading == view.leadingAnchor + 12
            $0.trailing == view.trailingAnchor - 12
            $0.height |=| 140
        }
    }
    
    
    @objc func createCliqPressed(_ sender: UIButton){
        createCliq()
    }
    
    @objc func closeTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func pickImagePressed(_ sender: UIButton){
        imagePickerAlert()
    }
    
    
    
    
    
    func imagePickerAlert(){
        
        let alert = UIAlertController.createDefaultAlert("Add Cover Photo", "",.actionSheet, "Take photo") { (action) in
            self.imagePicker = UIImagePickerController()
            self.imagePicker?.sourceType = .camera
            self.present(self.imagePicker!, animated: true, completion: nil)
            self.imagePicker?.delegate = self
           //Launch Camera
        }
        let action2 = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker = UIImagePickerController()
            self.imagePicker?.delegate = self
            self.present(self.imagePicker!, animated: true, completion: nil)
            //Call Picker
        }
        
        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(action2); alert.addAction(action3)
        present(alert, animated: true, completion: nil)
    }
    
    func setupLocation(){
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager?.startUpdatingLocation()
        }
    }
    
    
    func createCliq() {
        
        
        let imageValue = imageView.image
        
        
        let name = textField.text
        
        guard name != nil && (name?.count)! > 0 else {
            
            present(UIAlertController.createDefaultAlert("INFO", "Please add a title for your cliq",.alert, "OK",.default, nil), animated: true, completion: nil)
            return
        }
        
        guard let image : UIImage = imageValue else {
            present(UIAlertController.createDefaultAlert("INFO", "Please add a cover image",.alert, "OK",.default, nil), animated: true, completion: nil)
            return
        }
        
        guard let loc : CLLocation = location else {
            let alert = UIAlertController.createDefaultAlert("INFO", "Unable to access current location. Please enable location services",.alert, "OK",.default, nil)
            let settings = UIAlertAction(title: "Settings", style: .default){_ in UIApplication.openSettings()}
            alert.addAction(settings)
            present(alert, animated: true, completion: nil)
            return
        }
        let overlay = LoaderView(frame: self.view.frame)
        overlay.label.text = "Creating Cliq, Please wait..."
        self.view.addSubview(overlay)
        DataService.main.addNewCliq(image: image, name: name!, locaion: loc) { (success, errM) in
            if let suc = success as? Bool{
                if suc && errM == nil{
                  self.dismiss(animated: true, completion: nil)
                }else{
                    self.present(UIAlertController.createDefaultAlert("INFO", errM!,.alert, "OK",.default, nil), animated: true, completion: nil)
                }
            }
        }

    }
    

}


extension AddCliqVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    

    
}

extension AddCliqVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker!.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage{
            imageView.image = image
            imagebutt.setTitle("", for: .normal)
        }
        imagePicker!.dismiss(animated: true, completion: nil)
    }
}


extension AddCliqVC:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let userLocation = locations.first else{
            return
        }
        
        location = userLocation
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    

}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
