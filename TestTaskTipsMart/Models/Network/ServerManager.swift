//
//  ServerManager.swift
//  TestTaskTipsMart
//
//  Created by olli on 08.08.19.
//  Copyright © 2019 Oli Poli. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class ServerManager {
    static let shared = ServerManager()
    // var repository : Repository?
    var managedContext: NSManagedObjectContext!
    
    var isConnected : Bool {
        
        let networkStatus = Reachability.isNowConnectedToNetwork()
        return networkStatus
    }
    
    func startConnection() {
        do {
            Network.reachability = try Reachability(hostname: "www.google.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    // туть
    func initParametersWithKeyword(_ keyword : String, page : Int, perPage : Int) -> Parameters {
        let parameters: Parameters = [
            "q": keyword,
            "sort" : "stars",
            "page" : page,
            "per_page" : perPage
        ]
        
        return parameters
    }
    
    func downloadJSONWithKeyword(_ keyword : String, page : Int, perPage : Int, completionBlock: @escaping () -> ()) {
        let parameters = ServerManager.shared.initParametersWithKeyword(keyword, page: page, perPage: perPage)
        
        Alamofire.request("https://api.github.com/search/repositories", method: .get, parameters: parameters).responseJSON { response in
            
            if let jsonObject = response.result.value {
                let json = JSON(jsonObject)
                
                for i in 0...perPage-1 {
                    let repository = Repository(context: self.managedContext)
                    repository.ownerLogin = json["items"][i]["owner"]["login"].stringValue
                    repository.htmlURL = json["items"][i]["html_url"].stringValue
                    repository.name = json["items"][i]["name"].stringValue
                    repository.repoDescription = json["items"][i]["description"].stringValue
                    repository.starsCount = json["items"][i]["stargazers_count"].int64Value
                    
                }
                completionBlock()
            }
        }
        
    }
    
    func operationQueuesWithKeyword(keyword : String, completionBlock: @escaping () -> ()) {
        let queue = OperationQueue()
        
        let downloadOperation1 = BlockOperation {
            
            self.downloadJSONWithKeyword(keyword, page: 1, perPage: 15, completionBlock: {
                self.saveManagedContext()
            })
        }
        
        let downloadOperation2 = BlockOperation {
            
            self.downloadJSONWithKeyword(keyword, page: 2, perPage: 15, completionBlock: {
                self.saveManagedContext()
                completionBlock()
            })
        }
        
        downloadOperation2.addDependency(downloadOperation1)
        
        queue.addOperation(downloadOperation1)
        queue.addOperation(downloadOperation2)
        
    }
    
    func printSortedArray() -> [Repository] {
        
        var sortedArray = [Repository]()
        let fetchRequest : NSFetchRequest<Repository> = Repository.fetchRequest()
        
        do {
            let repositories = try managedContext.fetch(fetchRequest) as [Repository]
            sortedArray = repositories.sorted(by: {$0.starsCount > $1.starsCount})
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        
        return sortedArray
    }
    
    func deleteFromCoreData() {
        
        let fetchRequest : NSFetchRequest<Repository> = Repository.fetchRequest()
        
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result!
        
        for object in resultData {
            managedContext.delete(object)
        }
        
        saveManagedContext()
        
    }
    
    func saveManagedContext () {
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Save error: \(error), description: \(error.userInfo)")
        }
    }
    
    private init() {
        
    }
    
}
