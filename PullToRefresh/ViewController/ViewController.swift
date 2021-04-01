//
//  ViewController.swift
//  PullToRefresh
//
//  Created by Ruthlyn Huet on 4/1/21.
//

import UIKit

class ViewController: UIViewController {
    
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var result: DataResponse?
    var tableData = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewSetup()
        dataFetch()
        pullToRefreshSetup()
    }
    
    private func tableViewSetup(){
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    
    private func pullToRefreshSetup(){
        table.refreshControl = UIRefreshControl()
        table.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @objc private func didPullToRefresh(){
        // Re-Fetch data here..
      dataFetch()
    }
    
    private func dataFetch(){
        tableData.removeAll()
        
        if table.refreshControl?.isRefreshing == true{
            print("Refreshing Data..")
        }else{
            print("fetching data.")
        }
        let apiURL = "https://api.sunrise-sunset.org/json?date=2020-8-1&lng=37.3230&lat=-122.0322&formatted=0"
        guard let url = URL(string: apiURL) else {
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url){ [weak self] data, _, error in
            guard let selfStrong = self, let data = data, error == nil else {return}
            
            do{
                self?.result = try JSONDecoder().decode(DataResponse.self, from: data)
                
            }catch let error{
                print("Something Went Wrong: \(error.localizedDescription)")
            }
            
            guard let final = self?.result else{return}
            
            self?.dataAppend(data: final)
            
        }
        dataTask.resume()
    }
    
    
    private func dataAppend(data: DataResponse){
        tableData.append("Sunrise: \(data.results.sunrise)")
        tableData.append("Sunset: \(data.results.sunset)")
        tableData.append("Day Length: \(data.results.day_length)")
        
        DispatchQueue.main.async {
            self.table.refreshControl?.endRefreshing()
            self.table.reloadData()
        }

    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = tableData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
