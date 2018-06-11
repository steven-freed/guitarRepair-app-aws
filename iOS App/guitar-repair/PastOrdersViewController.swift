//
//  PastOrdersViewController.swift
//  guitar-repair
//
//  Created by steven freed on 6/5/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import UIKit
import AWSAPIGateway
import AWSAuthCore

// Repair object for past orders
class Repair: NSObject {
    var _repairType: String?
    var _repairPrice: Double?
    var _orderTime: String?
}

class PastOrdersViewController: UIViewController {

    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
 
    // AWS Clients
    let client = APIDevorderServiceClient.default()
    let awsClient = AWSIdentityManager.default()
    // Datasource
    var dataSource = [Repair]()
    
    override func viewWillAppear(_ animated: Bool) {
        
        // init tableview
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        // init activity indicator
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         getOrders()
    }
    
    // MARK: - Gets orders from db by invoking lambda function through API-Gateway
    private func getOrders()
    {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        
        let userId = awsClient.identityId
        
        let json: [String: Any] = ["userId": userId!]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        client.invoke(AWSAPIGatewayRequest(httpMethod: "POST", urlString: "/readOrders", queryParameters: [:], headerParameters: [:], httpBody: jsonData!)).continueWith { (task: AWSTask) -> Any? in
            if task.result!.statusCode == 200
            {
                let data = task.result?.responseData
                self.dataToArray(data: data)
            }
            DispatchQueue.main.sync {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
            
            return nil
        }
    }
    
    // MARK: - Converts URLResponse data to Object array of Repairs
    private func dataToArray(data: Data?)
    {
        let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
        let json = jsonDict!!["items"] as? NSArray
        
        if let array = json {
            for obj in array {
                if let dict = obj as? NSDictionary {
                    // Now reference the data you need using:
                    let repair = dict.value(forKey: "repairType") as! String
                    let price = dict.value(forKey: "repairPrice") as! Double
                    let date = dict.value(forKey: "orderTime") as! String
                    let item = Repair()
                    item._repairType = repair
                    item._repairPrice = price
                    item._orderTime = date
                    dataSource.append(item)
                }
            }
        }
    }

}

extension PastOrdersViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PastOrderTableViewCell
        cell.repair.text = dataSource[indexPath.row]._repairType!
        cell.price.text = "$" + String(format: "%.2f", dataSource[indexPath.row]._repairPrice!)
        cell.date.text = dataSource[indexPath.row]._orderTime!
        
        return cell
    }
    
}
