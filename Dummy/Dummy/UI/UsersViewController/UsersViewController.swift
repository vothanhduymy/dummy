//
//  UsersViewController.swift
//  Dummy
//
//  Created by Vo Thanh Duy My on 21/06/2022.
//

import UIKit
import RxSwift
import RxCocoa
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
        setupSearchObserver()
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
                self.searchBar.clear()
            }).disposed(by: disposeBag)
        
        viewModel.output.getUser
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _user in
                guard let self = self else { return }
                guard let vc: DetailViewController = UIStoryboard.main?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
                    return
                }
                vc.viewModel.user = _user
                vc.delegate = self
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
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
    
    private func setupSearchObserver() {
        guard let txtSearch = searchBar.textField else { return }
        
        txtSearch
            .rx.text
            .orEmpty
            .debounce(.seconds(0), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] t in
                guard let self = self else { return }
                if t.count == 0 {
                    self.viewModel.showUsers = self.viewModel.users
                } else {
                    let tempArr = self.viewModel.showUsers.filter {
                        return $0.firstName.contains(t) || $0.lastName.contains(t)
                    }
                    self.viewModel.showUsers = tempArr
                }
                self.tblContent.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.showUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell") as? UserTableViewCell
        if cell ==  nil {
            cell = Bundle.main.loadNibNamed("UserTableViewCell", owner: self)?.first as? UserTableViewCell
        }
        
        
        let userListItem: UserListItem = viewModel.showUsers[indexPath.row]
        cell?.reloadData(userListItem)
        return cell ?? UITableViewCell()
    }
}

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userListItem: UserListItem = viewModel.showUsers[indexPath.row]
        view.endEditing(true)
        viewModel.getUser(userListItem: userListItem)
    }
}

extension UsersViewController: DetailViewControllerDelegate {
    func deleteUser(id: String) {
        viewModel.users.removeAll(where: {
            $0.id == id
        })
        viewModel.showUsers.removeAll(where: {
            $0.id == id
        })
        tblContent.reloadData()
    }
}
