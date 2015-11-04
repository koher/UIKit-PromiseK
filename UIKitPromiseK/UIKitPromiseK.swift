import UIKit

extension UIView {
    public class func promisedAnimate(duration duration: NSTimeInterval, delay: NSTimeInterval = 0.0, options: UIViewAnimationOptions = [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.TransitionNone], animations: () -> Void) -> Promise<Bool> {
        return Promise<Bool> { resolve in
            UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations) { finished in
                resolve(Promise(finished))
            }
        }
    }
}

@available(iOS 8.0, *)
extension UIViewController {
    public func promisedPresentAlertController<T>(title title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle, buttons: [(title: String, style: UIAlertActionStyle, value: T)]) -> Promise<T> {
        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 {
            let (cancelButton, destructiveButton, buttons) : (cancelButton: (title: String, style: UIAlertActionStyle, value: T)?, destructiveButton: (title: String, style: UIAlertActionStyle, value: T)?, buttons: [(title: String, style: UIAlertActionStyle, value: T)]) = buttons.reduce((cancelButton: nil, destructiveButton: nil, buttons: [])) { (var result, button) in
                switch button.style {
                case .Default:
                    result.buttons.append(button)
                    break
                case .Cancel:
                    result.cancelButton = button
                    break
                case .Destructive:
                    result.destructiveButton = button
                    break
                }
                return result
            }
            
            switch preferredStyle {
            case .Alert:
                return UIAlertView.promisedShow(title: title, message: message, cancelButtonTitle: cancelButton?.title, buttonTitles: buttons.map { $0.title }).map { $0 - (cancelButton != nil ? 1 : 0) }.map { buttonIndex in
                    switch buttonIndex {
                    case -1:
                        return cancelButton!.value
                    default:
                        return buttons[buttonIndex].value
                    }
                }
            case .ActionSheet:
                return UIActionSheet.promisedShowInView(self.view, title: title, cancelButtonTitle: cancelButton?.title, destructiveButtonTitle: destructiveButton?.title, buttonTitles: buttons.map { $0.title }).map { $0 - (destructiveButton != nil ? 1 : 0) }.map { buttonIndex in
                    switch buttonIndex {
                    case -1:
                        return destructiveButton!.value
                    case buttons.count:
                        return cancelButton!.value
                    default:
                        return buttons[buttonIndex].value
                    }
                }
            }
        }
        
        return Promise { resolve in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for button in buttons {
                alertController.addAction(UIAlertAction(title: button.title, style: button.style) { action in
                    resolve(Promise(button.value))
                })
            }
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

extension UIAlertView {
    public func promisedShow() -> Promise<Int> {
        let delegate = AlertViewDelegate()
        self.delegate = delegate
        show()
        return delegate.promise
    }
    
    public class func promisedShow(title title: String? = nil, message: String? = nil, cancelButtonTitle: String? = nil, buttonTitles: [String]) -> Promise<Int> {
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        for buttonTitle in buttonTitles {
            alertView.addButtonWithTitle(buttonTitle)
        }
        return alertView.promisedShow()
    }
}

class AlertViewDelegate: NSObject, UIAlertViewDelegate {
    private var zelf: AlertViewDelegate!
    
    private var resolve: (Promise<Int> -> Void)!
    private var promise: Promise<Int>!
    
    override init() {
        super.init()
        
        zelf = self
        promise = Promise<Int> { resolve in
            self.resolve = resolve
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        resolve(Promise(buttonIndex))
        
        resolve = nil
        dispatch_async(dispatch_get_main_queue()) {
            self.zelf = nil
        }
    }
}

extension UIActionSheet {
    public func promisedShowInView(view: UIView) -> Promise<Int> {
        let delegate = ActionSheetDelegate()
        self.delegate = delegate
        showInView(view)
        return delegate.promise
    }

    public class func promisedShowInView(view: UIView, title: String? = nil, cancelButtonTitle: String? = nil, destructiveButtonTitle: String? = nil, buttonTitles: [String]) -> Promise<Int> {
        let actionSheet = UIActionSheet(title: title, delegate: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if let title = destructiveButtonTitle {
            actionSheet.destructiveButtonIndex = actionSheet.addButtonWithTitle(title)
        }
        for buttonTitle in buttonTitles {
            actionSheet.addButtonWithTitle(buttonTitle)
        }
        if let title = cancelButtonTitle {
            actionSheet.cancelButtonIndex = actionSheet.addButtonWithTitle(title)
        }
        return actionSheet.promisedShowInView(view)
    }
}

class ActionSheetDelegate: NSObject, UIActionSheetDelegate {
    private var zelf: ActionSheetDelegate!
    
    private var resolve: (Promise<Int> -> Void)!
    private var promise: Promise<Int>!
    
    override init() {
        super.init()
        
        zelf = self
        promise = Promise { resolve in
            self.resolve = resolve
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        resolve(Promise(buttonIndex))

        resolve = nil
        dispatch_async(dispatch_get_main_queue()) {
            self.zelf = nil
        }
    }
}