//
//  RealLinksTableViewController.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 27/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import UIKit
import Ocarina

class RealLinksTableViewController: UITableViewController {

    public var usePrefetcher = true
    
    private var prefetcher: OcarinaPrefetcher?
    
    private var links: [URL] = [URL]() {
        didSet {
            self.prefetcher?.cancel()
            if self.usePrefetcher {
                self.prefetcher = OcarinaPrefetcher(urls: self.links)
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadLinks()
        
        self.tableView.estimatedRowHeight = 78+16
        self.tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func downloadLinks() {
        guard let url = URL(string: "https://reddit.com/r/news/hot.json?limit=100") else {
            fatalError("Failed to create URL")
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    guard let data = json?["data"] as? [String: Any], let children = data["children"] as? [[String: Any]] else {
                        print("Invalid reddit json")
                        return
                    }
                    let links = children.flatMap({ (post) -> URL? in
                        guard let data = post["data"] as? [String: Any] else {
                            return nil
                        }
                        guard let urlString = data["url"] as? String else {
                            return nil
                        }
                        return URL(string: urlString)
                    })
                    DispatchQueue.main.async {
                        self.links = links
                    }
                } catch {
                    print("Error parsing JSON \(error)")
                }
                
            }
        }
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.links.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "linkCell", for: indexPath)

        let link = self.links[indexPath.row]

        if let previewCell = cell as? LinkPreviewTableViewCell {
            previewCell.previewView.changeLink(link: link)
        } else {
            cell.textLabel?.text = link.host
        }

        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
