//
//  UsersViewController.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import UIKit
import RxSwift
import SVPullToRefresh

class UsersViewController: UIViewController {
    private let disposeBag = DisposeBag()
    @IBOutlet weak var tblContent: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let viewModel: UserViewModel = UserViewModel()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tblContent.addSubview(refreshControl)
        
        tblContent.addInfiniteScrolling { [weak self] in
            guard let self = self else { return }
            self.viewModel.getUsers(isMore: true)
        }
        
        viewModel.getUsers()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func refreshData() {
        viewModel.getUsers()
    }
    
    private func bindViewModel() {
        viewModel.output.getUsers
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isShowsInfiniteScrolling in
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.tblContent.infiniteScrollingView.stopAnimating()
                self.tblContent.reloadData()
                self.tblContent.showsInfiniteScrolling = isShowsInfiniteScrolling
            }).disposed(by: disposeBag)
        
        viewModel.output.getUser
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _user in
                guard let self = self else { return }
                guard let vc: DetailViewController = UIStoryboard.main?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
                    return
                }
                vc.viewModel.user = _user
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.output.responseError
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let self = self,
                      let error = event.element else { return }
                self.showAlert(title: error.code, message: error.message)
            }.disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe { event in
                guard let loading = event.element else { return }
                if loading {
                    //Pz.showLoadingLOTAnimation()
                } else {
                    //Pz.hideLoadingLOTAnimation()
                }
            }.disposed(by: disposeBag)
    }
}

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as? UserTableViewCell
        if cell ==  nil {
            cell = Bundle.main.loadNibNamed("UserTableViewCell", owner: self)?.first as? UserTableViewCell
        }
        
        
        let userListItem: UserListItem = viewModel.users[indexPath.row]
        cell?.reloadData(userListItem)
        return cell ?? UITableViewCell()
    }
}

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userListItem: UserListItem = viewModel.users[indexPath.row]
        view.endEditing(true)
        viewModel.getUser(userListItem: userListItem)
    }
}
