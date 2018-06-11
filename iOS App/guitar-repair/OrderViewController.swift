//
//  OrderViewController.swift
//  guitar-repair
//
//  Created by steven freed on 6/5/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import UIKit
import AWSAuthCore
import AWSCognito
import AWSAPIGateway
import AWSCognitoIdentityProvider

class OrderViewController: UIViewController, UITextFieldDelegate {

    // IBOutlets for view
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var editText: UITextField!
    
    // AWS Clients
    let client = APIDevorderServiceClient.default()
    let awsClient = AWSIdentityManager.default()
    let cognitoUser = AWSCognitoIdentityUserPool.default().currentUser()
    private var currentUsersAttributes = [String: String]()
    
    // Datasources for UITableView
    let dataSource: [String] = ["Setup", "Fret Dress", "Refret", "Headstock Crack/Neck Repair", "Nut Replacement", "Saddle Replacement", "Pickup Installation (per pickup)", "Full Rewire"]
    let dataPrices: [Double] = [40.00, 85.00, 175.00, 80.00, 75.00, 75.00, 20.00, 85.00]
    var bitmap: [Int] = [0, 0, 0, 0, 0, 0, 0, 0]
 
    override func viewWillAppear(_ animated: Bool) {
        
        // init tableview
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsSelection = true
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        getCustomerData()
    }
    
    // MARK: - Gets customer attributes for a repair order
    //         phone_number, name
    private func getCustomerData()
    {
                self.cognitoUser?.getDetails().continueWith(block: {(_ task: AWSTask<AWSCognitoIdentityUserGetDetailsResponse>) -> Any? in
                    let response: AWSCognitoIdentityUserGetDetailsResponse? = task.result
                    for attribute in response!.userAttributes! {
                        //print the user attributes
                        self.currentUsersAttributes[attribute.name!] = attribute.value!
                    }
                    
                    return nil
                })
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init view
        editText.delegate = self
        self.orderButton.layer.cornerRadius = orderButton.frame.height/2
        
        // keyboard notifictions
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
      
        // orderbutton function
        orderButton.addTarget(self, action: #selector(orderTapped(_sender:)), for: .touchUpInside)
    }
    
    // MARK: - Sends order to db by invoking the lambda function through API-Gateway
    @objc func orderTapped(_sender: UIButton)
    {
        let userId = awsClient.identityId
        let name = self.currentUsersAttributes["name"]
        let phone = Int(self.currentUsersAttributes["phone_number"]!)
        var repairNote = "none"
        if editText.text != "" {
            repairNote = editText.text!
        }
        let repairType = getRepairType()
        let repairPrice = getRepairPrice()
        
         if repairType == nil
         {
            return
         }
        
        let json: [String: Any] = ["userId": userId!,
                                   "name": name!,
                                   "phone": phone!,
                                   "repairNote": repairNote,
                                   "repairType": repairType!,
                                   "repairPrice": repairPrice!
                                   ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        client.invoke(AWSAPIGatewayRequest(httpMethod: "POST", urlString: "/createOrder", queryParameters: [:], headerParameters: [:], httpBody: jsonData!)).continueWith { (task: AWSTask) -> Any? in
            if task.result!.statusCode == 200
            {
                self.showAlert(title: "Order Sent!", message: "😎")
            } else {
                self.showAlert(title: "Something went wrong...", message: "Please try back soon.")
            }
            return nil
    }
    }
    
    // MARK: - Returns repair type from bitmap
    func getRepairType() -> String?
    {
        for i in 0..<bitmap.count
        {
            if bitmap[i] == 1
            {
                return dataSource[i]
            }
        }
        
        self.showAlert(title: "Opps!", message: "You may have forgotten to fill in a field...")
        return nil
    }
    
    // MARK: - Returns price from bitmap
    func getRepairPrice() -> Double?
    {
        for i in 0..<bitmap.count
        {
            if bitmap[i] == 1
            {
                return dataPrices[i]
            }
        }
        return 0.00
    }
    
    // MARK: - Presents alerts
    func showAlert(title: String, message: String)
    {
        DispatchQueue.main.async {
            let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            activityView.center = self.view.center
            activityView.hidesWhenStopped = true
            activityView.startAnimating()
            self.view.addSubview(activityView)
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: {
                    self.tableView.reloadData()
                    self.editText.text = ""
                    self.bitmap = [0, 0, 0, 0, 0, 0, 0, 0]
                })
             activityView.stopAnimating()
            
        }
    }
    
    // MARK: - Dismiss keyboard on return key tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Show keyboard below text field by shifting view
    @objc func keyboardWillShow(_ notification: Notification) {
        self.orderButton.isEnabled = false
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    // MARK: - Hides keyboard and fixes view
    @objc func keyboardWillHide(_ notification: Notification) {
        self.orderButton.isEnabled = true
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardHeight
            }
        }
    }
    
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.detailTextLabel?.text = "$" + String(format:"%.2f", dataPrices[indexPath.row])
        cell.imageView?.image = UIImage(named: "app")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        bitmap[indexPath.row] = 1
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        bitmap[indexPath.row] = 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = .none
    }
    
    
}
