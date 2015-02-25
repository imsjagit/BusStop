//
//  DutyControllerViewController.swift
//  BusStop
//
//  Created by Hans Scheurlen on 10.02.15.
//  Copyright (c) 2015 Hans Scheurlen. All rights reserved.
//

import UIKit

class DutyViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tblView:UITableView?
    @IBOutlet weak var lblMonth:UILabel?
    private var duties:[PFObject]?
    private var currentMonth = 0
    private var formatter = NSDateFormatter()
    
    private let monthNames = ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
    private let weekDays = ["MO","DI","MI","DO","FR","SA","SO"]
    ///////////////////////////////////////////
    // View methods
    ///////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.duties = [PFObject]()
        
        self.formatter.dateFormat = "dd.MM.yyyy"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onDataLoaded", name: kEventDataDownloadSuccess, object: nil)
        
        //Load local data
        self.currentMonth = DutyManager.currentMonth()
        self.loadDataForMonth(self.currentMonth)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    ///////////////////////////////////////////
    // Callback methods
    ///////////////////////////////////////////
    
    func onChangeMonth(sender:AnyObject){
        
    }
    
    func onDataLoaded(){
        self.loadDataForMonth(self.currentMonth)
    }
    
    private func loadDataForMonth(month: Int){
        DutyManager.dutiesForMonth(month, callback: {(duties:[PFObject]) in
            self.duties = duties
            
            //Set title
            self.lblMonth!.text = self.monthNames[self.currentMonth]
            self.tblView!.reloadData()
        })
    }
    
    @IBAction func onPrevious(){
        self.currentMonth = self.currentMonth > 1 ? self.currentMonth - 1 : 0
        self.loadDataForMonth(self.currentMonth)
    }
    
    @IBAction func onNext(){
        self.currentMonth = (self.currentMonth + 1) % 12
        self.loadDataForMonth(self.currentMonth)
    }
    
    @IBAction func onRefresh(){
        HUDController.sharedController.contentView = HUDContentView.ProgressView()
        HUDController.sharedController.show()
        
        //Load data
        NSOperationQueue().addOperationWithBlock({
            DutyManager.loadDataFromParse()
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                HUDController.sharedController.hide()
                
                self.onDataLoaded()
            })
        })
    }
    
    ///////////////////////////////////////////
    // UITableViewDataSource methods
    ///////////////////////////////////////////
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.duties!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("DutyCell") as UITableViewCell
        let schedule = ScheduleManager.defaultInstance.currentSchedule()
        
        let duty = self.duties![indexPath.row]
        let drivers = DutyManager.driversForDuty(duty)
        let driver1 = drivers[0] as PFObject
        let driver2 = drivers[1] as PFObject
        let weekDay = DutyManager.weekDayForDuty(duty)
        let date = duty["date"] as NSDate
        
        var lblDayName = cell.viewWithTag(100) as UILabel;lblDayName.text = self.weekDays[weekDay]
        var lblDayDate = cell.viewWithTag(101) as UILabel;lblDayDate.text = self.formatter.stringFromDate(date)
        var lblJob1 = cell.viewWithTag(102) as UILabel;lblJob1.text = driver1["name"] as? String
        var lblJob2 = cell.viewWithTag(103) as UILabel;lblJob2.text = driver2["name"] as? String
        var imgJob1 = cell.viewWithTag(104) as UIImageView;
        var imgJob2 = cell.viewWithTag(105) as UIImageView;
        DutyManager.loadImageForParseObject(driver1, callCack: {(image:UIImage) in
            imgJob1.image = image
        })
        DutyManager.loadImageForParseObject(driver2, callCack: {(image:UIImage) in
            imgJob2.image = image
        })
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
