//
//  ViewController.swift
//  TestPanda
//
//  Created by Toseef on 4/21/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var templates: [Template] = []

    let cellID = "CellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Templates"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        PandaDocAPIManager.shared.getTemplates { (result) in
            switch result {
            case .success(let data):
                print(data)
                self.templates = data
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let template = templates[indexPath.row]
        cell.textLabel?.text = template.name
        cell.detailTextLabel?.text = template.id
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detaiVC = (storyboard?.instantiateViewController(identifier: "DocCreateViewController"))! as DocCreateViewController
        detaiVC.template = templates[indexPath.row]
        self.navigationController?.pushViewController(detaiVC, animated: true)
    }
}

