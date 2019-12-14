//
//  SettingsViewController.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var authorizeHealthDataLabel: UILabel!
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var userId: UILabel!
    @IBOutlet var iotEndpointHostname: UITextField!
    @IBOutlet var iotEndpointPort: UITextField!
    @IBOutlet var certificateFileName: UILabel!
    @IBOutlet var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHeartRate(notification:)), name: .newHeartRateWatch, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // create user id if there is none
        if ConfigManager.userId() == "" {
            ConfigManager.setUserId(userId: UUID().uuidString)
            print("User ID: \(ConfigManager.userId())")
        }
        
        userNameTextField.text = ConfigManager.userName()
        passwordTextField.text = ConfigManager.password()
        userId.text = ConfigManager.userId()
        certificateFileName.text = ConfigManager.certificateFileName()! + ".p12"
        heartRateLabel.text = "--"
        iotEndpointHostname.text = ConfigManager.iotEndpointHostname()
        iotEndpointPort.text = String(ConfigManager.iotEndpointPort())
        
    }   
    
    @IBAction func textFieldShouldEndEditing(_ sender: UITextField) {
        if sender == userNameTextField {
            ConfigManager.setUserName(userName: userNameTextField.text)
        } else if sender == passwordTextField {
            ConfigManager.setPassword(password: passwordTextField.text ?? "")
        } else if sender == iotEndpointHostname {
            ConfigManager.setIoTEndpointHostname(hostname: iotEndpointHostname.text ?? "")
        } else if sender == iotEndpointPort {
            ConfigManager.setIoTEndpointPort(port: UInt16(iotEndpointPort.text ?? "") ?? 8883)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            //Authorize health data
            HealthDataManager.sharedInstance.requestAuthorization { (success) in
                DispatchQueue.main.async {
                    let message = success ? "Authorized health data access." : "Failed to authorize health data access."
                    let alertController = UIAlertController(title: "Health Data", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func updateHeartRate(notification:Notification) {
        if let heartRate = notification.object as? Double {
            DispatchQueue.main.async {
                self.heartRateLabel.text = String(format: "%.0f", heartRate)
            }
        }
    }
}
