//
//  DetailViewController.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 22/06/2022.
//

import UIKit
import RxSwift
import SwifterSwift

protocol DetailViewControllerDelegate: AnyObject {
    func deleteUser(id: String)
}

class DetailViewController: UIViewController {
    private let disposeBag = DisposeBag()
    let viewModel = DetailViewModel()
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtDateOfBirth: UITextField!
    weak var delegate: DetailViewControllerDelegate?
    
    @IBOutlet weak var btnChangeName: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    var isEdit: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fillData()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imgPicture.cornerRadius = imgPicture.height / 2
        
        btnChangeName.layer.borderColor = UIColor.lightGray.cgColor
        btnChangeName.layer.borderWidth = 1
    }
    
    private func fillData() {
        imgPicture.nukeLoadImage(url: URL(string: viewModel.user.picture))
        txtFirstName.text = viewModel.user.firstName
        txtLastName.text = viewModel.user.lastName
        txtEmail.text = viewModel.user.email
        txtDateOfBirth.text = Date(iso8601String: viewModel.user.dateOfBirth)?.string(withFormat: "dd/MM/yyyy")
        txtFirstName.isUserInteractionEnabled = isEdit
        txtLastName.isUserInteractionEnabled = isEdit
        btnChangeName.setTitle(isEdit ? "Save" : "Change name", for: .normal)
    }
    
    private func bindViewModel() {
        viewModel.output.deleteUser
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] deletedUserId in
                guard let self = self else { return }
                self.showAlert(title: "Delete success", message: nil) { [weak self]  _ in
                    guard let self = self else { return }
                    self.navigationController?.popViewController(animated: true, { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.deleteUser(id: deletedUserId)
                    })
                }
            }).disposed(by: disposeBag)
        
        viewModel.output.updateUser
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.showAlert(title: "Update success", message: nil)
                self.isEdit.toggle()
                self.fillData()
            }).disposed(by: disposeBag)
        
        viewModel.output.responseError
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let self = self,
                      let error = event.element else { return }
                self.showAlert(title: error.error, message: error.data?.data)
            }.disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe { event in
                guard let loading = event.element else { return }
                if loading {
                    Util.showLoading()
                } else {
                    Util.hideLoading()
                }
            }.disposed(by: disposeBag)
    }

    @IBAction func btnChangeNameTapped(_ sender: Any) {
        view.endEditing(true)
        
        if txtFirstName.text?.isEmpty != false {
            self.showAlert(title: "Invalid", message: "First name is required!") { [weak self] _ in
                self?.txtFirstName.becomeFirstResponder()
            }
            return
        }
        
        if txtLastName.text?.isEmpty != false {
            self.showAlert(title: "Invalid", message: "Last name is required!") { [weak self] _ in
                self?.txtLastName.becomeFirstResponder()
            }
            return
        }
        
        if isEdit {
            viewModel.changeName(firstName: txtFirstName.text?.trimmed, lastName: txtLastName.text?.trimmed)
            return
        }
        isEdit.toggle()
        fillData()
        txtFirstName.becomeFirstResponder()
    }
    
    @IBAction func btnDeleteTapped(_ sender: Any) {
        view.endEditing(true)
        showAlert(title: "Delete this user?", message: "Are you sure?", buttonTitles: ["Delete", "Cancel"], highlightedButtonIndex: 1) { [weak self] _index in
            if _index == 0 {
                self?.viewModel.deleteUser()
            }
        }
    }
    
    
}
