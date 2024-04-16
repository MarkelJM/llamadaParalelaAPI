//
//  ListViewController.swift
//  apiParalelo
//
//  Created by Markel Juaristi Mendarozketa   on 29/2/24.
//

import UIKit
import Combine

class ListViewController: UIViewController {
    
    //private var viewModel = ListViewModel()
    
    var viewModel : ListViewModel!
 

    private var cancellables = Set<AnyCancellable>()
    private let spinner = UIActivityIndicatorView(style: .large)
    //var users: [UserModel] = []

    @IBOutlet weak var lbJob: UILabel!
    @IBOutlet weak var lbSurname: UILabel!
    @IBOutlet weak var listMembers: UITableView!
    
    
    @IBOutlet weak var lbSalary: UILabel!
    
    
    
    @IBOutlet weak var lbNetSalary: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpinner()
        setupTableView()
        setupBindings()
        viewModel.fetchNamesList()
    }
    
    private func setupSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        view.bringSubviewToFront(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        spinner.color = .black
        spinner.startAnimating()
    }


    
    private func setupTableView() {
        let nib = UINib(nibName: "UserTableViewCell", bundle: nil)
        listMembers.register(nib, forCellReuseIdentifier: "UserTableViewCell")
        listMembers.delegate = self
        listMembers.dataSource = self
    }
    
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.spinner.startAnimating()
                } else {
                    self?.spinner.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$users
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.spinner.stopAnimating()
                self?.listMembers.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$surname
            .receive(on: RunLoop.main)
            .sink { [weak self] surname in
                self?.lbSurname.text = surname
            }
            .store(in: &cancellables)
        
        viewModel.$job
            .receive(on: RunLoop.main)
            .sink { [weak self] job in
                self?.lbJob.text = job
            }
            .store(in: &cancellables)
        
        viewModel.$salaryDetails
            .receive(on: RunLoop.main)
            .sink { [weak self] salaryDetails in
                self?.lbSalary.text = salaryDetails
            }
            .store(in: &cancellables)
        
        viewModel.$totalNetSalary
            .receive(on: RunLoop.main)
            .sink { [weak self] totalNetSalary in
                self?.lbNetSalary.text = totalNetSalary
            }
            .store(in: &cancellables)
    }






}

extension ListViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows: \(viewModel.users.count)")
        return viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt called for row \(indexPath.row)")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell else {
            fatalError("UserTableViewCell not found")
        }
        let user = viewModel.users[indexPath.row]
        print("Configuring cell for \(user.name)")
        cell.lbName.text = user.name
        cell.lbID.text = "\(user.id)"
        return cell
    }

}

extension ListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row at \(indexPath.row), with userID: \(viewModel.users[indexPath.row].id)")
        let userId = viewModel.users[indexPath.row].id
        //viewModel.fetchUserDetails(forUserId: userId)
        viewModel.fetchUserDetailsAndSendPayroll(forUserId: userId)
        //viewModel.sendPayrollDataMock(forUserId: userId)

        

        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
