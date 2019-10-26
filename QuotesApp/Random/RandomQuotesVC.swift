//
//  RandomQuotesVC.swift
//  QuotesApp
//
//  Created by Absoluit on 19/10/2019.
//  Copyright © 2019 Absoluit. All rights reserved.
//

import UIKit

class RandomQuotesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var randomTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.randomTableView.dequeueReusableCell(withIdentifier: "RandomCell") as! RandomCell
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
}
