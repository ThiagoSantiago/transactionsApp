//
//  ProfileViewController.swift
//  Transactions
//
//  Created by Thiago Santiago on 1/18/19.
//  Copyright © 2019 Thiago Santiago. All rights reserved.
//

import UIKit

protocol ProfileDisplayLogic: class {
    typealias UserViewModel = [(title: String, description: String)]
    
    func hideLoading()
    func displayLoadingView()
    func displayUser(image: UIImage)
    func displayError(message: String)
    func displayUser(info: UserViewModel)
}

class ProfileViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak private var errorView: UIView!
    @IBOutlet weak private var loadingView: UIView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak private var infoContentView: UIView!
    @IBOutlet weak private var tryAgainButton: UIButton!
    @IBOutlet weak private var headerContentView: UIView!
    @IBOutlet weak private var errorMessageLabel: UILabel!
    @IBOutlet weak private var userImageView: UIImageView!
    @IBOutlet weak private var changePhotoButton: UIButton!
    
     //MARK: Properties
    private var interactor: ProfileInteractor?
    private let imagePicker = UIImagePickerController()
    fileprivate var tableViewData: UserViewModel = []

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        interactor?.getUserInfos()
        interactor?.loadUserImage()
    }
    
    private func setup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let presenter = ProfilePresenter()
        let interactor = ProfileInteractor(presenter: presenter)
        self.interactor = interactor
        presenter.viewController = self
        
        self.registerTableViewCells()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        configViews()
    }
    
    private func registerTableViewCells() {
        self.tableView.register(UINib(nibName: "DescriptionItemCell", bundle: nil), forCellReuseIdentifier: "DescriptionItemCell")
    }
    
    private func configViews() {
        self.infoContentView.layer.cornerRadius = 8
        self.tryAgainButton.layer.cornerRadius = 25
        self.changePhotoButton.layer.cornerRadius = 25
        self.userImageView.setImageBorder(color: UIColor.white.cgColor, width: 2.0, radius: 40)
        self.infoContentView.setShadow(color: UIColor.black.cgColor, opacity: 0.6, shadowRadius: 5.0)
        self.headerContentView.setGradient(startColor: Colors.pink.cgColor, finalColor: Colors.blue.cgColor)
    }
    
    //MARK: Actions
    @IBAction func backButtonPressed(_ sender: Any) {
        TransactionAppRouter.popView()
    }
    
    @IBAction func tryAgainPressed(_ sender: Any){
        interactor?.getUserInfos()
        self.tryAgainButton.isEnabled = false
    }
    
    @IBAction func changePhotoPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title:"Take a picture", message: "Choose an image from your galery or take a new one.", preferredStyle: .actionSheet)
        
        let chooseAPicture = UIAlertAction(title: "Choose a picture", style: .default, handler: { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let takeANewPicture = UIAlertAction(title: "Take a picture", style: .default) { _ in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil) }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        
        optionMenu.addAction(chooseAPicture)
        optionMenu.addAction(takeANewPicture)
        optionMenu.addAction(cancel)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}


//MARK: ProfileDisplayLogic
extension ProfileViewController: ProfileDisplayLogic {
    
    func hideLoading() {
        self.loadingView.isHidden = true
    }
    
    func displayLoadingView() {
        self.loadingView.isHidden = false
    }
    
    func displayUser(image: UIImage) {
        self.userImageView.image = image
    }
        
    func displayError(message: String) {
        self.errorView.isHidden = false
        self.errorMessageLabel.text = message
        self.tryAgainButton.isEnabled = true
    }
    
    func displayUser(info: UserViewModel) {
        self.errorView.isHidden = true
        self.tableViewData = info
        self.userNameLabel.text = info[4].description
        self.tableView.reloadData()
    }
}

//MARK: UITableViewDelegate / UITableViewDataSource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionItemCell", for: indexPath) as? DescriptionItemCell else {
            return UITableViewCell()
        }
        cell.setContent(title: tableViewData[indexPath.row].title, description: tableViewData[indexPath.row].description)
        
        return cell
    }
}

//MARK: UIImagePickerControllerDelegate / UINavigationControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        self.userImageView.image = selectedImage
        self.interactor?.saveUser(image: selectedImage)
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
