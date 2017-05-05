//
//  SecondViewController.swift
//  BackgroundNotifications
//
//  Created by Matthew Hayes on 5/5/17.
//  Copyright © 2017 Matthew Hayes. All rights reserved.
//

import UIKit

@available(iOS, deprecated: 9.0)
class NotificationManager {
    
    static let standard = NotificationManager()
    
    static var notificationAction : String = "local.notification"
    static var notificationTitle : String = "Local"
    static var notificationBody : String = "Notification!"
    
    var notification : UILocalNotification?
    var timer : Timer?
    
    var triggerDate : Date? {
        set(newValue) {
            _updateNotification(date: newValue)
        }
        get {
            return self.notification?.fireDate
        }
    }
    
    private let notificationKey = "notificationTriggerDate"
    
    init() {
        
        guard let scheduledLocalNotifications = UIApplication.shared.scheduledLocalNotifications else { return }
        
        for notification in scheduledLocalNotifications {
            if notification.alertAction == NotificationManager.notificationAction {
                self.notification = notification
                break
            }
        }
        
    }
    
    private func _updateNotification(date: Date?) {
        
        
        if let date = date {
            
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            components.setValue(0, for: .second)
            if let fullMinuteDate = calendar.date(from: components) {
                
                if let notification = notification {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
                notification = UILocalNotification()
                notification?.repeatInterval = .day
                
                if let notification = notification {
                    notification.fireDate = fullMinuteDate
                    notification.alertAction = NotificationManager.notificationAction
                    notification.alertTitle = NotificationManager.notificationTitle
                    notification.alertBody = NotificationManager.notificationBody
                    
                    UIApplication.shared.scheduleLocalNotification(notification)
                    
                }
                
                if let timer = timer {
                    timer.invalidate()
                }
                timer = Timer(fire: fullMinuteDate, interval: 0, repeats: false, block: { (timer) in
                    NotificationManager.notificationFired()
                })
            }
            
        } else {
            
            if let notification = notification {
                UIApplication.shared.cancelLocalNotification(notification)
            }
            timer?.invalidate()
            timer = nil
            
        }
    }
    
    static func notificationFired(notification: UILocalNotification? = NotificationManager.standard.notification) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let alert = UIAlertController(title: notificationTitle, message: notificationBody, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: notificationAction, style: .default, handler: nil))
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
}

@available(iOS, deprecated:9.0)
class SecondViewController: UIViewController, UIPickerViewDelegate {

    @IBOutlet weak var toggleContainer: UIView!
    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var selectionContainer: UIView!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var pickerHideConstraint : NSLayoutConstraint?
    var timeHideConstraint : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = NotificationManager.standard.triggerDate ?? Date()
        _refreshUI(withDate: NotificationManager.standard.triggerDate)
        
        _setBorder(toggleContainer)
        _setBorder(selectionContainer)
        _setBorder(datePicker)
    }

    @IBAction func toggleToggled(_ sender: Any) {
        
        if toggle.isOn {
            _setDate(datePicker.date)
        } else {
            _setDate(nil)
        }
        
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        _setDate(datePicker.date)
        toggle.setOn(true, animated: true)
    }
    
    private func _setBorder(_ view: UIView) {
        view.layer.borderColor = UIColor(colorLiteralRed: 0.3, green: 0.3, blue: 0.3, alpha: 1).cgColor
        view.layer.borderWidth = 0.5
    }
    
    private func _setDate(_ date: Date?) {
        
        NotificationManager.standard.triggerDate = date
        _refreshUI(withDate: date)
        
    }
    
    private func _refreshUI(withDate date: Date?) {
        if let date = date {
            toggle.setOn(true, animated: true)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            selectionLabel.text = formatter.string(from: date)
            selectionLabel.textColor = UIColor.darkGray
            
            if let pickerHideConstraint = pickerHideConstraint {
                view.removeConstraint(pickerHideConstraint)
            }
            if let timeHideConstraint = timeHideConstraint {
                view.removeConstraint(timeHideConstraint)
            }
        } else {
            toggle.setOn(false, animated: true)
            selectionLabel.text = "--:--"
            selectionLabel.textColor = UIColor.darkGray
            NotificationManager.standard.triggerDate = nil
            
            pickerHideConstraint = NSLayoutConstraint(item: datePicker, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            view.addConstraint(pickerHideConstraint!)
            
            timeHideConstraint = NSLayoutConstraint(item: selectionLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            view.addConstraint(timeHideConstraint!)
        }
        
        view.setNeedsLayout()
    }
}

