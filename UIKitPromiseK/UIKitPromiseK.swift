import UIKit
import PromiseK

extension UIView {
    public class func promisedAnimate(# duration: NSTimeInterval, delay: NSTimeInterval = 0.0, options: UIViewAnimationOptions = UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.TransitionNone, animations: () -> Void) -> Promise<Bool> {
        return Promise<Bool> { resolve in
            UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations) { finished in
                resolve(Promise(finished))
            }
        }
    }
}

extension UIViewController {
    public func promisedPresentAlertController<T>(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle, buttons: [(title: String, style: UIAlertActionStyle, value: T)]) -> Promise<T> {
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
    
    public class func promisedShow(title: String? = nil, message: String? = nil, cancelButtonTitle: String? = nil, buttonTitles: [String]) -> Promise<Int> {
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