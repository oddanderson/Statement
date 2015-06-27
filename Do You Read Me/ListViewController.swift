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
  private var storedItems: [BigText]?
  private var curState = 0
  private var animate = false
  private var blankImage: UIImageView!
  
  let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  

  override func viewDidLoad() {
    super.viewDidLoad()
    blankImage = UIImageView()
    blankImage.image = UIImage(named: "ListBlankState")
    blankImage.contentMode = UIViewContentMode.ScaleAspectFit
    blankImage.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 400)
    updateList()
    tableView.tableFooterView = UIView.new()
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
    var error: NSError?
    if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [BigText] {
      storedItems = fetchResults.sorted({ (item1: BigText, item2: BigText) -> Bool in return item1.lastOpened.timeIntervalSince1970 > item2.lastOpened.timeIntervalSince1970 })
      if (storedItems!.count > 0) {
        tableView.tableFooterView = UIView.new()
      } else {
        tableView.tableFooterView = blankImage
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var item = sender! as! BigText
    var detailVC = segue.destinationViewController as! DetailViewController
    if (count(item.text) > 0) {
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
    var item : BigText! = storedItems![indexPath.row] as BigText
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
    var cell : UITableViewCell?
    cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
    
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
      cell?.backgroundColor = UIColor.clearColor()
      cell?.textLabel?.textColor = UIColor.whiteColor()
      cell?.textLabel?.numberOfLines = 0
      cell?.textLabel?.font = UIFont.systemFontOfSize(25)
    }
    
    var item : BigText! = storedItems![indexPath.row] as BigText
    cell!.textLabel?.text = item.text
    
    return cell!
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    var item : BigText! = storedItems![indexPath.row] as BigText
    item.lastOpened = NSDate()
    managedObjectContext?.save(nil)
    self.performSegueWithIdentifier("PushBigText", sender: item)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func pulsateButton() {
    var timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("updateButton"), userInfo: nil, repeats: true)
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

