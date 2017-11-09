import UIKit
import PromiseK

extension UIView {
    public class func promisedAnimate(withDuration duration: TimeInterval, delay: TimeInterval = 0.0, options: UIViewAnimationOptions = [UIViewAnimationOptions.curveEaseInOut], animations: @escaping () -> Void) -> Promise<Bool> {
        return Promise<Bool> { fulfill in
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations) { finished in
                fulfill(finished)
            }
        }
    }
}

extension UIViewController {
    public func promisedPresentAlertController<T>(withTitle title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle, buttons: [(title: String, style: UIAlertActionStyle, value: T)], configurePopoverPresentation: ((UIPopoverPresentationController) -> ())? = nil) -> Promise<T> {
        return Promise { fulfill in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for button in buttons {
                alertController.addAction(UIAlertAction(title: button.title, style: button.style) { action in
                    fulfill(button.value)
                })
            }
            _ = alertController.popoverPresentationController.map { configurePopoverPresentation?($0) }
            
            self.present(alertController, animated: true, completion: nil)
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
    
    public class func promisedShow(withTitle title: String? = nil, message: String? = nil, cancelButtonTitle: String? = nil, buttonTitles: [String]) -> Promise<Int> {
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        for buttonTitle in buttonTitles {
            alertView.addButton(withTitle: buttonTitle)
        }
        return alertView.promisedShow()
    }
}

class AlertViewDelegate: NSObject, UIAlertViewDelegate {
    fileprivate var zelf: AlertViewDelegate!
    
    fileprivate var fulfill: ((Int) -> Void)!
    fileprivate var promise: Promise<Int>!
    
    override init() {
        super.init()
        
        zelf = self
        promise = Promise<Int> { fulfill in
            self.fulfill = fulfill
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        fulfill(buttonIndex)
        
        fulfill = nil
        DispatchQueue.main.async {
            self.zelf = nil
        }
    }
}

extension UIActionSheet {
    public func promisedShow(in view: UIView) -> Promise<Int> {
        let delegate = ActionSheetDelegate()
        self.delegate = delegate
        show(in: view)
        return delegate.promise
    }

    public class func promisedShow(in view: UIView, withTitle title: String? = nil, cancelButtonTitle: String? = nil, destructiveButtonTitle: String? = nil, buttonTitles: [String]) -> Promise<Int> {
        let actionSheet = UIActionSheet(title: title, delegate: nil, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if let title = destructiveButtonTitle {
            actionSheet.destructiveButtonIndex = actionSheet.addButton(withTitle: title)
        }
        for buttonTitle in buttonTitles {
            actionSheet.addButton(withTitle: buttonTitle)
        }
        if let title = cancelButtonTitle {
            actionSheet.cancelButtonIndex = actionSheet.addButton(withTitle: title)
        }
        return actionSheet.promisedShow(in: view)
    }
}

class ActionSheetDelegate: NSObject, UIActionSheetDelegate {
    fileprivate var zelf: ActionSheetDelegate!
    
    fileprivate var fulfill: ((Int) -> Void)!
    fileprivate var promise: Promise<Int>!
    
    override init() {
        super.init()
        
        zelf = self
        promise = Promise { fulfill in
            self.fulfill = fulfill
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        fulfill(buttonIndex)

        fulfill = nil
        DispatchQueue.main.async {
            self.zelf = nil
        }
    }
}
