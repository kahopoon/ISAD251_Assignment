//
//  ViewController.swift
//  Kaho Bar
//
//  Created by Johnson on 12/2/2020.
//  Copyright © 2020 Johnson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: BaseViewController {

    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        guard   let email = textFieldEmail.text, email.count > 0,
                let password = textFieldPassword.text, password.count > 0 else {
                return
        }
        Users().login(email: email, password: password) { (user) in
            if let loggedUser = user, loggedUser.errorCode == nil {
                CacheManager.sharedInstance.currentUser = loggedUser
                var vcIdentifier = ""
                switch loggedUser.role {
                case .administrator:
                    vcIdentifier = "AdminTabViewController"
                default:
                    vcIdentifier = "TabViewController"
                }
                DispatchQueue.main.async {
                    let showsProductVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: vcIdentifier)
                    showsProductVC.modalPresentationStyle = .fullScreen
                    self.present(showsProductVC, animated: true) {
                    }
                }
            }
        }
    }

}

