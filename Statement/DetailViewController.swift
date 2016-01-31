//
//  DetailViewController.swift
//  BigText
//
//  Created by Todd Anderson on 5/16/15.
//  Copyright (c) 2015 Todd Anderson. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak private var textView: UITextView!
  @IBOutlet weak private var label: UILabel!
  @IBOutlet weak private var leftButton: UIButton!
  @IBOutlet weak private var leftLabel: UILabel!
  @IBOutlet weak private var rightButton: UIButton!
  @IBOutlet weak private var rightLabel: UILabel!
  @IBOutlet weak private var toolbar: UIView!
  @IBOutlet weak private var toolbarConstraint: NSLayoutConstraint!
  @IBOutlet weak private var blankStateImage: UIImageView!
    @IBOutlet weak private var actionImage: UIImageView!
  
  let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  
  var readOnly: Bool = false
  var isSaved: Bool = false
  var item: BigText!
  
  deinit {
    
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    label.adjustsFontSizeToFitWidth = true
  }
  
  override func viewWillAppear(animated: Bool) {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil);
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil);
    label.lineBreakMode = NSLineBreakMode.ByWordWrapping
    textView.text = item.text
    label.text = item.text
    updateImage(item.text)
    setupForReadOnly(readOnly, isSaved: isSaved)
    if (!readOnly) {
      textView.becomeFirstResponder()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func viewDidLayoutSubviews() {
    updateTextFont()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  func keyboardWillShow(notification: NSNotification) {
    readOnly = false
    setupForReadOnly(readOnly, isSaved: isSaved)
    if let userInfo = notification.userInfo {
      let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
      let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
      let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
      
      toolbarConstraint?.constant = endFrame?.size.height ?? 0
      UIView.animateWithDuration(duration,
        delay: NSTimeInterval(0),
        options: animationCurve,
        animations: {
          self.view.layoutIfNeeded()
        },
        completion: nil)
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    readOnly = true
    setupForReadOnly(readOnly, isSaved: isSaved)
    if let userInfo = notification.userInfo {
      _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
      let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
      let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
      
      toolbarConstraint?.constant = 0
      UIView.animateWithDuration(duration,
        delay: NSTimeInterval(0),
        options: animationCurve,
        animations: {
          self.view.layoutIfNeeded()
          self.updateImage(self.label.text!)
        },
        completion: nil)
    }  }
  
  func setupForReadOnly(readOnly: Bool, isSaved: Bool) {
    updateTextFont()
    if (readOnly) {
      label.text = textView.text
      textView.text = ""
      label.alpha = 1
      if (item.text == label.text!) {
        leftLabel.text = "Back"
        rightLabel.text = "Delete"
      } else {
        leftLabel.text = "Cancel"
        rightLabel.text = "Save"
      }
    } else {
      textView.text = label.text
      label.alpha = 0
      leftLabel.text = "Cancel"
      rightLabel.text = "Clear"
    }
  }
  
  @IBAction func leftButtonPressed(sender: UIButton?) {
    if (!isSaved) {
      managedObjectContext!.deleteObject(item as NSManagedObject)
        do {
            try managedObjectContext!.save()
        } catch _ as NSError {
            
        }
      
    }
    self.navigationController?.popViewControllerAnimated(true)
  }
  
    @IBAction func rightButtonPressed(sender: UIButton) {
        if (readOnly) {
            let length = (label.text! as NSString).length
            var save = false
            if (item.text == label.text!) {
                managedObjectContext!.deleteObject(item as NSManagedObject)
                save = true
                actionImage.image = UIImage(named: "Deleted")
            } else if (length > 0) {
                item.text = label.text!
                save = true
                actionImage.image = UIImage(named: "Saved")
            }
            if (save) {
                do {
                    try managedObjectContext!.save()
                } catch _ as NSError {
                    
                }
            }
            UIView.animateWithDuration(0.3,
                animations: {
                    self.label.alpha = 0
                    self.actionImage.alpha = 1
                },
                completion: { (value: Bool) in
                    self.delay(0.5) {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
            })
      
        } else {
            textView.text = ""
            updateImage(textView.text)
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
    updateImage(newText)
    if (text == "\n") {
      textView.resignFirstResponder()
    }
    return true
  }
  
  func updateImage(text: String) {
    
    if ((text as NSString).length == 0) {
      blankStateImage.alpha = 1
    } else {
      blankStateImage.alpha = 0
    }
  }
  
  
  func updateTextFont() {
    if (label.text!.isEmpty || CGSizeEqualToSize(label.bounds.size, CGSizeZero)) {
      return;
    }
    let fontSizeForOneWord = minimumFontSizeForText(label.text!)
    let textViewSize = label.frame.size;
    let fixedWidth = textViewSize.width - 10;
    let expectSize = label.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)));
    
    var expectFont = label.font;
    if (expectSize.height > textViewSize.height) {
      var newSize = label.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
      while (newSize.height > textViewSize.height) {
        newSize = label.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT)))
        expectFont = label.font.fontWithSize(label.font.pointSize - 1)
        label.font = expectFont
      }
    }
    else {
      while (label.sizeThatFits(CGSizeMake(fixedWidth, CGFloat(MAXFLOAT))).height < textViewSize.height) {
        expectFont = label.font;
        label.font = label.font.fontWithSize(label.font.pointSize + 1)
      }
      label.font = expectFont
    }
    
    let curFontSize = label.font.pointSize
    if (fontSizeForOneWord < curFontSize) {
      label.font = UIFont.systemFontOfSize(fontSizeForOneWord)
    }
  }
  
  func minimumFontSizeForText(text: String) -> CGFloat {
    let largestWord = largestWordInText(label.text!) as String!
    let max_str = NSString(string: largestWord)
    let min_str = NSString(string: "h\nb")
    label.font = UIFont.systemFontOfSize(300)
    var minFontSize = label.font.pointSize
    while (true) {
      let twoRowsSize = min_str.boundingRectWithSize(label.frame.size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(minFontSize)], context: nil)
      let curStrSize = max_str.boundingRectWithSize(label.frame.size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(minFontSize)], context: nil)
      if (curStrSize.height < twoRowsSize.height) {
        return minFontSize
      }
      minFontSize--
      if (minFontSize < 20) {
        break
      }
    }
    return 20
  }
  
  func largestWordInText(text: String) -> String {
    let words = text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) as [String]
    var largestWord = ""
    for word in words {
      if (word as NSString).length > (largestWord as NSString).length {
        largestWord = word
      }
    }
    return largestWord
  }

}

