//
//  ViewController.swift
//  Task
//
//  Created by bola fayez on 1/8/16.
//  Copyright (c) 2016 Bola Fayez. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    // #pragma MARK: - controllers
    
    @IBOutlet weak var tableTeams:      UITableView!
    @IBOutlet weak var progressLoading: UIActivityIndicatorView!
    
    // #pragma MARK: - values
    
    var numberOfTeams:Int!
    
    var arrayResponseFromWebserviceGetTeams:NSMutableArray         = NSMutableArray()
    
    // #pragma MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check Network
        
        if Reachability.isConnectedToNetwork() == true {
            
            // calling web service
            
            self.methodGetTeams(url: "http://api.football-data.org/alpha/soccerseasons/351/teams") { (succeeded: Bool, msg: String) -> () in
                println("happen error")
            }
            
        } else {

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert     = UIAlertView()
                alert.title   = "Error"
                alert.message = "Error occured!"
                alert.addButtonWithTitle("OK")
                alert.show()
            })
        
        }
        
    }

    // #pragma MARK: - didReceiveMemoryWarning()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // #pragma MARK: - Segue to TeamViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "segueTeam"{
            
            if let Index:Int = tableTeams.indexPathForSelectedRow()?.row {
                
                let obj:AnyObject = self.arrayResponseFromWebserviceGetTeams[Index]
                
                let teamsName     = obj.valueForKey("name")        as! NSString

                let _links        = obj.valueForKey("_links")      as! NSDictionary
                
                let fixtures      = _links.valueForKey("fixtures") as! NSDictionary
                
                let href          = fixtures.valueForKey("href")   as! String
                                
                let controller = segue.destinationViewController as! TeamViewController

                controller.strNameTeam    = teamsName as String
                controller.strURLFixtures = href
                
            }
            
        }
    }
    
    // #pragma MARK: - Table View Delegate && Data Source Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayResponseFromWebserviceGetTeams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:CustomCellTableTeams = tableView.dequeueReusableCellWithIdentifier("cellTeams", forIndexPath: indexPath) as! CustomCellTableTeams
        
        let row                   = indexPath.row
        
        var obj:AnyObject         = self.arrayResponseFromWebserviceGetTeams[row]
        
        let teamsName             = obj.valueForKey("name")         as! NSString
        let urlLogos:AnyObject    = obj.valueForKey("crestUrl")!
        
        // http://lorempixel.com/150/232/city/id-1
        
        let url                   = NSURL(string: urlLogos as! String)
        let data                  = NSData(contentsOfURL: url!)
        
        cell.imageLogoTeams.image = UIImage(data: data!)
        cell.lableNameTeams.text  = teamsName as String

        // progress
        
        progressLoading.stopAnimating()
        progressLoading.hidden = true
        
        return cell
    }
    
    // #pragma MARK: - methods Calling WebService
    
    func methodGetTeams(#url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        
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
            
            for (itemValue) in json["teams"] as! NSArray {
                
                self.arrayResponseFromWebserviceGetTeams.addObject(itemValue)
                
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                // Load data into TableView
                
                self.tableTeams.reloadData()
                
                // progress
                
                self.progressLoading.hidden = true
                self.progressLoading.stopAnimating()
                
            })
            
        })
        task.resume()
    }


}

