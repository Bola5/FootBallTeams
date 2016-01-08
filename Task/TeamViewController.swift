//
//  TeamViewController.swift
//  Task
//
//  Created by bola fayez on 1/8/16.
//  Copyright (c) 2016 Bola Fayez. All rights reserved.
//

import Foundation
import UIKit

class TeamViewController: UIViewController {
    
    // #pragma MARK: - Controllers
    
    @IBOutlet weak var tableTeam:       UITableView!
    @IBOutlet weak var progressLoading: UIActivityIndicatorView!
    @IBOutlet weak var navegationTitle: UINavigationItem!
    
    // #pragma MARK: - values
    
    var strNameTeam    :String!
    var strURLFixtures :String!
    
    var arrayResponseFromWebServiceResult :NSMutableArray = NSMutableArray()
    
    var count          :Int!
    
    var arrayUrlImageHomeTeam              :NSMutableArray = NSMutableArray()
    var arrayUrlImageAwayTeam              :NSMutableArray = NSMutableArray()

    // #pragma MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        
        // get values from TeamsViewController
        // set title
        
        navegationTitle.title = strNameTeam
        
        // calling WebSerives methods
        
        self.methodGetfixtures(url: strURLFixtures) { (succeeded: Bool, msg: String) -> () in
            println("happen error")
        }
        
    }
    
    // #pragma MARK: - Table View Delegate and Data Sourese methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayResponseFromWebServiceResult.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:CustomCellTableTeam = tableView.dequeueReusableCellWithIdentifier("cellTeam", forIndexPath: indexPath) as! CustomCellTableTeam
        
        let row                    = indexPath.row
        
        var obj:AnyObject          = self.arrayResponseFromWebServiceResult[row]
        
        let result                 = obj.valueForKey("result")            as! NSArray
        
        let resultHome             = result.valueForKey("homeTeamResult") as! String
        let resultAway             = result.valueForKey("awayTeamResult") as! String
        
        var objUrlHome             = self.arrayUrlImageHomeTeam[row]      as! String
        var objUrlAway             = self.arrayUrlImageAwayTeam[row]      as! String
        
        let urlImageHome          = NSURL(string: objUrlHome)
        let dataHome              = NSData(contentsOfURL: urlImageHome!)
        
        let urlImageAway          = NSURL(string: resultAway)
        let dataAway              = NSData(contentsOfURL: urlImageAway!)
        
        cell.labelResult.text     = resultHome + "." + resultAway
        cell.imageHome.image      = UIImage(data: dataHome!)
        cell.imageAway.image      = UIImage(data: dataAway!)
        
        // progress
        
        progressLoading.stopAnimating()
        progressLoading.hidden = true
        
        return cell
    }

    
    // #pragma MARK: - methods Calling WebService 
    
    func methodGetfixtures(#url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        
        // progress
        
        self.progressLoading.hidden = false
        self.progressLoading.startAnimating()
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        var err: NSError?
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var dateResponse = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments,
                error:&parseError)
            
            let json = parsedObject as! NSDictionary
                        
            let fixtures = json.valueForKey("fixtures")   as! NSArray
            
            self.count   = json.valueForKey("count")      as! Int
            
            let _links   = fixtures.valueForKey("_links") as! NSArray
            
            let homeTeam = _links.valueForKey("homeTeam") as! NSArray
            
            let awayTeam = _links.valueForKey("awayTeam") as! NSArray
            
            for (itemValue) in homeTeam.valueForKey("href") as! NSArray {
                
                self.methodGethomeTeamANDawayHome(url: itemValue as! String, flag: "home") { (succeeded: Bool, msg: String) -> () in
                    println("happen error")
                }
                
            }
            
            for (itemValue) in awayTeam.valueForKey("href") as! NSArray {
                
                self.methodGethomeTeamANDawayHome(url: itemValue as! String, flag: "away") { (succeeded: Bool, msg: String) -> () in
                    println("happen error")
                }
                
            }
            
            for (itemValue) in fixtures.valueForKey("result") as! NSArray {
                
                self.arrayResponseFromWebServiceResult.addObject(itemValue)
                
            }
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // progress
                
                self.progressLoading.hidden = true
                self.progressLoading.stopAnimating()
                
            })
            
        })
        task.resume()
    }
    
    func methodGethomeTeamANDawayHome(#url : String,flag: String , postCompleted : (succeeded: Bool, msg: String) -> ()) {
        
        // progress
        
        self.progressLoading.hidden = false
        self.progressLoading.startAnimating()
        
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        var err: NSError?
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            var dateResponse = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments,
                error:&parseError)
            
            let json = parsedObject as! NSDictionary
            
            let crestUrl = json.valueForKey("crestUrl") as! NSString
            
            if flag == "home" {
                
                self.arrayUrlImageHomeTeam.addObject(crestUrl)
                
                println(self.arrayUrlImageHomeTeam)
                println(self.arrayUrlImageHomeTeam.count)
                
            }else if flag == "away" {
                
                self.arrayUrlImageAwayTeam.addObject(crestUrl)
                
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // progress
                
                self.progressLoading.hidden = true
                self.progressLoading.stopAnimating()
                
                // Load data into TableView
                
                self.tableTeam.reloadData()
                
            })
            
        })
        task.resume()
    }

    
}
