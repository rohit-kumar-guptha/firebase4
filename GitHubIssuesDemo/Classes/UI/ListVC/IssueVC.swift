//
//  IssueVC.swift
//  GitHubIssuesDemo
//
//  Created by Prabhat Pandey on 25/08/19.
//  Copyright © 2019 Prabhat Pandey. All rights reserved.
//

import UIKit
import TableFlip

class IssueVC: UIViewController {
    
    @IBOutlet weak var tableForIssueList: UITableView!
    private let viewModel = IssueListViewModel()
    private let client = ApiClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchIssueListFromApi()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    self.title = constants.vcTitle.TITLE_ISSUE_LIST
        
          let fadeAnimation = TableViewAnimation.Cell.fade(duration: 0.3)
                                                                                    self.tableForIssueList.animate(animation: fadeAnimation, completion: nil)
        
       
    
    }
    
    func fetchIssueListFromApi() {
        if IssueDao.shared.isNetworkConnected() {
            SharedActivity.sharedInstance()?.start()
            client.getIssueListFeed(from: .issueList) { result in
                weak var weakSelf = self
                SharedActivity.sharedInstance()?.stop()
                switch result {
                case .success(let result):
                    if let list = result, list.count > 0 {
                        self.tableForIssueList.isHidden = false

                        weakSelf?.viewModel.getIssuesList(issued: list)
                        weakSelf?.tableForIssueList.reloadData()
                        
                           let fadeAnimation = TableViewAnimation.Cell.fade(duration: 0.3)
                                                                                                       self.tableForIssueList.animate(animation: fadeAnimation, completion: nil)
                           
                    } else {
                        self.tableForIssueList.isHidden = true

                        IssueDao.shared.showErrorAlert(title: constants.APP_NAME, message: constants.ERROR_MESSAGE, obj: self)
                    }
                case .failure(let error):
                    IssueDao.shared.showErrorAlert(title: constants.APP_NAME, message: "the error \(error)", obj: self)
                    self.tableForIssueList.isHidden = true
                    print("the error \(error)")
                }
            }
        } else {
            SharedActivity.sharedInstance()?.stop()
            IssueDao.shared.showErrorAlert(title: constants.APP_NAME, message: constants.ERROR_NETWORK, obj: self)
        }
    }
    
    private let viewModel2 = IssueDetailViewModel()
}

extension IssueVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : IssueTVC = tableView.dequeueReusableCell(withIdentifier: IssueTVC.identifier, for: indexPath) as! IssueTVC
        cell.selectionStyle = .none
        if self.viewModel.count > 0 {
            let cellViewModel = viewModel.cellViewModel(index: indexPath.row)
            cell.viewModel = cellViewModel
            
       //     print(indexPath.row)
            
            client.getIssueCommentDetail(from: .issueDetail(cellViewModel?.number)) { result in
                      
                           switch result {
                           case .success(let result):
                               if let issues = result, issues.count >= 0 {
                                cell.lblForDescription.text = "comments : \(issues.count)"
                                print(issues.count)
                               } else {
                               }
                           case .failure(let error):
                               print("the error \(error)")
                           }
            }
        }
            
         return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: constants.vc.VC_ISSUE_DETAIL) as! IssueDetailVC
        let cellViewModel = viewModel.cellViewModel(index: indexPath.row)
        detailVC.number = cellViewModel!.number
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}

