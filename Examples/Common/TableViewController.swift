//
//  TableViewController.swift
//  MiniDOM Example
//
//  Copyright 2017-2019 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
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
