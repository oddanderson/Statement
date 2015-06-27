//
//  BigText.swift
//  Do You Read Me
//
//  Created by Todd Anderson on 6/27/15.
//  Copyright (c) 2015 Todd Anderson. All rights reserved.
//

import Foundation
import CoreData

class BigText: NSManagedObject {

    @NSManaged var created: NSDate
    @NSManaged var lastOpened: NSDate
    @NSManaged var text: String
  
  
  class func createInManagedObjectContext(moc: NSManagedObjectContext, text: String) -> BigText {
    let newItem = NSEntityDescription.insertNewObjectForEntityForName("BigText", inManagedObjectContext: moc) as! BigText
    newItem.text = text
    newItem.created = NSDate()
    newItem.lastOpened = NSDate()
    
    return newItem
  }

}
