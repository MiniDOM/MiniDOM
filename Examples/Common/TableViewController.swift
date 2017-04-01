//
//  TableViewController.swift
//  MiniDOM Example
//
//  Created by Paul Calnan on 3/30/17.
//  Copyright © 2017 Anodized Software, Inc. All rights reserved.
//

import MiniDOM
import UIKit

class TableViewController: UITableViewController {

    private var feed: Feed?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let url = URL(string: "https://www.eff.org/rss/updates.xml") else {
            return
        }

        let alert = UIAlertController(title: "Loading, please wait", message: nil, preferredStyle: .alert)
        present(alert, animated: true)

        DispatchQueue.global(qos: .background).async {
            let parser = Parser(contentsOf: url)
            let result = parser?.parse()

            guard let document = result?.value else {
                print("parse problem")
                return
            }

            self.feed = Feed(document: document)
            print("feed with \(self.feed?.items.count ?? 0) item(s)")

            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed?.items.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = feed?.items[indexPath.row].title

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < feed?.items.count ?? 0,
              let item = feed?.items[indexPath.row]
        else {
            return
        }

        UIApplication.shared.open(item.link)
    }
}
