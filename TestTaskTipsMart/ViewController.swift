//
//  ViewController.swift
//  TestTaskTipsMart
//
//  Created by olli on 08.08.19.
//  Copyright © 2019 Oli Poli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var coverView = UIView()
    var webView = UIWebView()
    var webViewIsPresented = false
    
    var repositoriesArray : [Repository] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        if webViewIsPresented {
            let touchPoint = sender.location(in: self.view)
            
            if !webView.frame.contains(touchPoint) {
                webView.removeFromSuperview()
                coverView.removeFromSuperview()
                self.webViewIsPresented = false
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if (self.repositoriesArray.count != 0) {
            self.tableView.separatorStyle = .singleLine
            return 1
            
        } else {
            let messageLabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            
            messageLabel.text = "I am ready to search!"
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "Avenir", size: 20.0)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = .none;
        }
        
        return 0;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if repositoriesArray.count != 0 {
            return repositoriesArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as! CustomTableViewCell
        
        if repositoriesArray.count != 0 {
            cell.starsLabel.text = String(repositoriesArray[indexPath.row].starsCount)
            cell.authorLabel.text = repositoriesArray[indexPath.row].ownerLogin?.croppedToThirtyCharacters()
            cell.descriptionLabel.text = repositoriesArray[indexPath.row].repoDescription?.croppedToThirtyCharacters()
            cell.nameLabel.text = repositoriesArray[indexPath.row].name?.croppedToThirtyCharacters()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if repositoriesArray.count != 0 {
            coverView = UIView(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            coverView.backgroundColor = UIColor.darkGray
            coverView.alpha = 0.5
            
            self.view.addSubview(coverView)
            
            webView = UIWebView(frame: CGRect.init(x: 40, y: 40, width: self.view.bounds.size.width - 80, height: self.view.bounds.size.height - 80))
            webView.loadRequest(URLRequest(url: URL(string: repositoriesArray[indexPath.row].htmlURL!)!))
            
            webViewIsPresented = true
            self.view.addSubview(webView)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        
        if ServerManager.shared.isConnected {
            ServerManager.shared.deleteFromCoreData()
            ServerManager.shared.operationQueuesWithKeyword(keyword: searchBar.text!, completionBlock: {
                self.repositoriesArray = ServerManager.shared.printSortedArray()
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                }
            })
        } else {
            let alertVC = UIAlertController(title: "Error", message: "Sorry, you have problems with internet connection!", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
}

