import UIKit
import PromiseK
import UIKitPromiseK

class ViewController: UIViewController {
    @IBOutlet var square: UIView!
    @IBOutlet var actionButton: UIButton!
    
    fileprivate enum Action {
        case animation, alertController, alertView, actionSheet, cancel
    }
    
    @IBAction func onPressActionButton(_ sender: UIButton) {
        _ = promisedPresentAlertController(title: "Actions", message: "Select an action.", preferredStyle: .actionSheet, buttons: [
            (title: "Animation", style: UIAlertActionStyle.default, value: Action.animation),
            (title: "AlertController", style: UIAlertActionStyle.default, value: Action.alertController),
            (title: "AlertView", style: UIAlertActionStyle.default, value: Action.alertView),
            (title: "ActionSheet", style: UIAlertActionStyle.default, value: Action.actionSheet),
            (title: "Cancel", style: UIAlertActionStyle.cancel, value: Action.cancel),
        ]) { popoverPresentationController in
                popoverPresentationController.sourceView = self.actionButton
                popoverPresentationController.sourceRect = self.actionButton.bounds
        }.map { (action: Action) -> Void in
            switch action {
            case .animation:
                self.doAnimate()
            case .alertController:
                self.doPresentAlertController()
            case .alertView:
                self.doShowAlertView()
            case .actionSheet:
                self.doShowActionSheet()
            case .cancel:
                break
            }
        }
    }
    
    fileprivate func doAnimate() {
        actionButton.isEnabled = false
        
        _ = UIView.promisedAnimate(withDuration: 0.5) {
            self.square.frame.origin.x += 100
        }.flatMap { finished in
            UIView.promisedAnimate(withDuration: 0.5) {
                self.square.frame.origin.y += 100
            }
        }.flatMap { finished in
            UIView.promisedAnimate(withDuration: 0.6) {
                self.square.frame.origin.x -= 200
            }
        }.flatMap { finished in
            UIView.promisedAnimate(withDuration: 0.6) {
                self.square.frame.origin.y -= 200
            }
        }.flatMap { finished in
            UIView.promisedAnimate(withDuration: 0.6) {
                self.square.frame.origin.x += 200
            }
        }.flatMap { finished in
            UIView.promisedAnimate(withDuration: 0.5) {
                self.square.frame.origin.y += 100
            }
        }.flatMap { finished in
            UIView.promisedAnimate(withDuration: 0.5) {
                self.square.frame.origin.x -= 100
            }
        }.flatMap { finished in
            UIView.promisedAnimate(withDuration: 0.5) {
                self.square.alpha = 0.0
            }
        }.flatMap { finished in
            UIView.promisedAnimate(withDuration: 0.5, delay: 0.5) {
                self.square.alpha = 1.0
            }
        }.map { finished in
            self.actionButton.isEnabled = true
        }
    }
    
    fileprivate func doPresentAlertController() {
        _ = promisedPresentAlertController(title: "Confirmation", message: "Do you want to animate the square?", preferredStyle: .alert, buttons: [
            (title: "No", style: .cancel, value: false),
            (title: "Yes", style: .default, value: true),
        ]).map { answer -> Void in
            if answer {
                self.doAnimate()
            }
        }
    }
    
    fileprivate func doShowAlertView() {
        _ = UIAlertView.promisedShow(title: "Confirmation", message: "Do you want to animate the square?", cancelButtonTitle: "No", buttonTitles: ["Yes"]).map { buttonIndex -> Void in
            if buttonIndex == 1 {
                self.doAnimate()
            }
        }
    }
    
    fileprivate func doShowActionSheet() {
        _ = UIActionSheet.promisedShowInView(view, title: "Color of the square", cancelButtonTitle: "Cancel", buttonTitles: ["Red", "Green", "Blue"]).map { buttonIndex in
            switch buttonIndex {
            case 0:
                return UIColor.red
            case 1:
                return UIColor.green
            case 2:
                return UIColor.blue
            default:
                return nil
            }
        }.map { (colorOrNil: UIColor?) -> Void in
            if let color = colorOrNil {
                self.square.backgroundColor = color
            }
        }
    }
}
