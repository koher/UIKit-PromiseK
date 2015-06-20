import UIKit
import PromiseK
import UIKitPromiseK

class ViewController: UIViewController {
    @IBOutlet var square: UIView!
    @IBOutlet var actionButton: UIButton!
    
    private enum Action {
        case Animation, AlertController, AlertView, ActionSheet, Cancel
    }
    
    @IBAction func onPressActionButton(sender: UIButton) {
        promisedPresentAlertController(title: "Actions", message: "Select an action.", preferredStyle: .ActionSheet, buttons: [
            (title: "Animation", style: UIAlertActionStyle.Default, value: Action.Animation),
            (title: "AlertController", style: UIAlertActionStyle.Default, value: Action.AlertController),
            (title: "AlertView", style: UIAlertActionStyle.Default, value: Action.AlertView),
            (title: "ActionSheet", style: UIAlertActionStyle.Default, value: Action.ActionSheet),
            (title: "Cancel", style: UIAlertActionStyle.Cancel, value: Action.Cancel),
        ]).map { action -> Void in
            switch action {
            case .Animation:
                self.doAnimate()
            case .AlertController:
                self.doPresentAlertController()
            case .AlertView:
                self.doShowAlertView()
            case .ActionSheet:
                self.doShowActionSheet()
            case .Cancel:
                break
            }
        }
    }
    
    private func doAnimate() {
        actionButton.enabled = false
        
        UIView.promisedAnimate(duration: 0.5) {
            self.square.frame.origin.x += 100
        }.flatMap { finished in
            UIView.promisedAnimate(duration: 0.5) {
                self.square.frame.origin.y += 100
            }
        }.flatMap { finished in
            UIView.promisedAnimate(duration: 0.6) {
                self.square.frame.origin.x -= 200
            }
        }.flatMap { finished in
            UIView.promisedAnimate(duration: 0.6) {
                self.square.frame.origin.y -= 200
            }
        }.flatMap { finished in
            UIView.promisedAnimate(duration: 0.6) {
                self.square.frame.origin.x += 200
            }
        }.flatMap { finished in
            UIView.promisedAnimate(duration: 0.5) {
                self.square.frame.origin.y += 100
            }
        }.flatMap { finished in
            UIView.promisedAnimate(duration: 0.5) {
                self.square.frame.origin.x -= 100
            }
        }.flatMap { finished in
            UIView.promisedAnimate(duration: 0.5) {
                self.square.alpha = 0.0
            }
        }.flatMap { finished in
            UIView.promisedAnimate(duration: 0.5, delay: 0.5) {
                self.square.alpha = 1.0
            }
        }.map { finished in
            self.actionButton.enabled = true
        }
    }
    
    private func doPresentAlertController() {
        promisedPresentAlertController(title: "Confirmation", message: "Do you want to animate the square?", preferredStyle: .Alert, buttons: [
            (title: "No", style: .Cancel, value: false),
            (title: "Yes", style: .Default, value: true),
        ]).map { answer -> Void in
            if answer {
                self.doAnimate()
            }
        }
    }
    
    private func doShowAlertView() {
        UIAlertView.promisedShow(title: "Confirmation", message: "Do you want to animate the square?", cancelButtonTitle: "No", buttonTitles: ["Yes"]).map { buttonIndex -> Void in
            if buttonIndex == 1 {
                self.doAnimate()
            }
        }
    }
    
    private func doShowActionSheet() {
        UIActionSheet.promisedShowInView(view, title: "Color of the square", buttonTitles: ["Red", "Green", "Blue"]).map { buttonIndex in
            switch buttonIndex {
            case 0:
                return UIColor.redColor()
            case 1:
                return UIColor.greenColor()
            case 2:
                return UIColor.blueColor()
            default:
                fatalError("Never reaches here.")
            }
        }.map { color in
            self.square.backgroundColor = color
        }
    }
}
