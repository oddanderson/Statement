//
//  ViewController.swift
//  BigText
//
//  Created by Todd Anderson on 5/16/15.
//  Copyright (c) 2015 Todd Anderson. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var createButton: UIButton!
    @IBOutlet weak private var blankStateImageView: UIImageView!
    private var storedItems: [BigText]?
    private var curState = 0
    private var animate = false
  
  let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
   

  override func viewDidLoad() {
    super.viewDidLoad()
    updateList()
    tableView.tableFooterView = UIView.init()
    pulsateButton()
  }
  
  override func viewWillAppear(animated: Bool) {
    updateList()
    tableView.reloadData()
    animate = true
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func viewWillDisappear(animated: Bool) {
    animate = false
  }
  
  func updateList() {
    let fetchRequest = NSFetchRequest(entityName: "BigText")
    do {
        let fetchResults = try managedObjectContext!.executeFetchRequest(fetchRequest) as? [BigText]
        storedItems = fetchResults!.sort({ (item1: BigText, item2: BigText) -> Bool in return item1.lastOpened.timeIntervalSince1970 > item2.lastOpened.timeIntervalSince1970 })
        // success ...
    } catch let error as NSError {
        // failure
        print("Fetch failed: \(error.localizedDescription)")
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let item = sender! as! BigText
    let detailVC = segue.destinationViewController as! DetailViewController
    let length = (item.text as NSString).length
    if (length > 0) {
      detailVC.readOnly = true
      detailVC.isSaved = true
    }
    detailVC.item = item
  }
  
  @IBAction func createBigText(sender: UIButton) {
    let newItem = BigText.createInManagedObjectContext(managedObjectContext!, text: "")
    performSegueWithIdentifier("PushBigText", sender: newItem)
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return storedItems!.count
  }
  
  
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let item : BigText! = storedItems![indexPath.row] as BigText
    if let ns_str:NSString = item.text as NSString? {
      
      let sizeOfString = ns_str.boundingRectWithSize(
        CGSizeMake(self.view.frame.size.width - 20, CGFloat.infinity),
        options: NSStringDrawingOptions.UsesLineFragmentOrigin,
        attributes: [NSFontAttributeName: UIFont.systemFontOfSize(25)],
        context: nil).size
      return fmax(70.0, sizeOfString.height + 20)
    }
    return 70.0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell?
    
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
      cell?.backgroundColor = UIColor(red: 50/255.0, green: 38/255.0, blue: 51/255.0, alpha: 0.65)
      cell?.textLabel?.textColor = UIColor.whiteColor()
      cell?.textLabel?.numberOfLines = 0
      cell?.textLabel?.font = UIFont.systemFontOfSize(25)
    }
    
    let item : BigText! = storedItems![indexPath.row] as BigText
    cell!.textLabel?.text = item.text
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let item : BigText! = storedItems![indexPath.row] as BigText
    item.lastOpened = NSDate()
    do {
        try managedObjectContext?.save()
        self.performSegueWithIdentifier("PushBigText", sender: item)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    } catch let error as NSError {
        // failure
        print("Save failed: \(error.localizedDescription)")
    }
  }
  
  func pulsateButton() {
    _ = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("updateButton"), userInfo: nil, repeats: true)
  }
  
  func updateButton() {
    if (!animate) {
      return
    }
    curState++
    if (curState > 5) {
      curState = 0
    }
    let button = createButton as UIButton!
    let newColor = colorForState(curState)
    UIView.animateWithDuration(3.0,
      delay: 0,
      options: UIViewAnimationOptions.AllowUserInteraction,
      animations: {
        button.backgroundColor = newColor
    },
      completion: nil)
  }
  
  func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
  
  func colorForState(state: Int) -> UIColor {
    switch state {
    case 0:
      return UIColorFromRGB(0x50E3C2)
    case 1:
      return UIColorFromRGB(0x50E393)
    case 2:
      return UIColorFromRGB(0xB8E986)
    case 3:
      return UIColorFromRGB(0xE2E986)
    case 4:
      return UIColorFromRGB(0xB8E986)
    case 5:
      return UIColorFromRGB(0x50E393)
    default:
      return UIColorFromRGB(0x50E3C2)
    }
  }


}

