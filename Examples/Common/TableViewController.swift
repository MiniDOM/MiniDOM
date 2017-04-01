//
//  TableViewController.swift
//  MiniDOM Example
//
//  Copyright 2017 Anodized Software, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
