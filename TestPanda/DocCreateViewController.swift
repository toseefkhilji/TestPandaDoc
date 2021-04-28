//
//  DocCreateViewController.swift
//  TestPanda
//
//  Created by Toseef on 4/26/21.
//

import UIKit
import Alamofire

class DocCreateViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    @IBOutlet weak var txtDocName: UITextField!
    @IBOutlet weak var loadingStackView: UIStackView!
    @IBOutlet weak var btnSEnd: UIButton!

    @IBOutlet weak var stackViewControlls: UIStackView!

    @IBOutlet weak var activityLabel: UILabel!
    var template: Template?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Document"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setData()
    }

    private func setData() {
        if let template = template {
            txtDocName.text = template.name
        }
        loadingStackView.isHidden = true
        btnSEnd.isEnabled = true
        stackViewControlls.alpha = 1
    }

    @IBAction func sendDocument(_ sender: Any) {
        loadingStackView.isHidden = false
        btnSEnd.isEnabled = false
        stackViewControlls.alpha = 0.5

        let email = txtEmail.text ?? txtEmail.placeholder ?? "email1@domain.com"
        var param: Parameters = [:]
        param["name"] = txtDocName.text ?? "Document"
        param["template_uuid"] = template?.id ?? ""

        var resparam: Parameters = [:]
        resparam["email"] = email
        resparam["first_name"] = txtFname.text ?? txtFname.placeholder
        resparam["last_name"] = txtLname.text ?? txtLname.placeholder
        resparam["role"] = "role1"
        param["recipients"] = [resparam]
        activityLabel.text = "Creating Document..."
        PandaDocAPIManager.shared.createDoc(param: param) { res in

            if case let .success(data) = res {
                debugPrint(data)
                if let dataDict = data as? [String: Any], let did = dataDict["id"] as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.sendDocument(with: did, and: email)
                    }
                } else {
                    print("error in create")
                    self.loadingStackView.isHidden = true
                    self.btnSEnd.isEnabled = true
                    self.stackViewControlls.alpha = 1
                    self.showAlert(alertButtonTitles: "Error in create doc") {
                        
                    }
                }
            } else if case let .failure(error) = res {
                debugPrint(error)
            }
        }
    }

    private func sendDocument(with id: String, and email: String) {

        var param: Parameters = [:]
        param["message"] = "This doc is sent from iOS App with API"
        param["silent"] = true
        activityLabel.text = "Sending Document..."
        PandaDocAPIManager.shared.sendDocument(docID: id, param: param) { res in
            if case let .success(data) = res {
                debugPrint(data)
                if let dataDict = data as? [String: Any], let did = dataDict["id"] as? String {
                    self.shareDocument(with: did, and: email)
                } else {
                    print("error in send")
                }

            } else if case let .failure(error) = res {
                debugPrint(error)
            }
        }
    }

    private func shareDocument(with id: String, and email: String) {

        var param: Parameters = [:]
        param["recipient"] = email
        param["lifetime"] = 3600
        activityLabel.text = "Creating Session Link..."
        PandaDocAPIManager.shared.shareDocument(docID: id, param: param) { res in
            if case let .success(data) = res {
                debugPrint(data)
                if let dataDict = data as? [String: Any], let sid = dataDict["id"] as? String {
                    let urlStr = PandaDocAPIManager.shared.sessionURL + sid
                    if let url = URL(string: urlStr) {
                        let webVC = IFrameViewController()
                        webVC.url = url
                        webVC.title = "PandaDoc"
                        self.navigationController?.pushViewController(webVC, animated: true)
                    }
                }
            } else if case let .failure(error) = res {
                debugPrint(error)
            }
        }
    }
}
