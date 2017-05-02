import UIKit
import PromiseK

extension UIView {
    public class func promisedAnimate(withDuration duration: TimeInterval, delay: TimeInterval = 0.0, options: UIViewAnimationOptions = [UIViewAnimationOptions.curveEaseInOut], animations: @escaping () -> Void) -> Promise<Bool> {
        return Promise<Bool> { resolve in
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations) { finished in
                resolve(Promise(finished))
            }
        }
    }
}

extension UIViewController {
    public func promisedPresentAlertController<T>(title: String? = nil, message: String? = nil, preferredStyle: UIAlertControllerStyle, buttons: [(title: String, style: UIAlertActionStyle, value: T)], configurePopoverPresentation: ((UIPopoverPresentationController) -> ())? = nil) -> Promise<T> {
        return Promise { resolve in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for button in buttons {
                alertController.addAction(UIAlertAction(title: button.title, style: button.style) { action in
                    resolve(Promise(button.value))
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
    
    public class func promisedShow(title: String? = nil, message: String? = nil, cancelButtonTitle: String? = nil, buttonTitles: [String]) -> Promise<Int> {
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle)
        for buttonTitle in buttonTitles {
            alertView.addButton(withTitle: buttonTitle)
        }
        return alertView.promisedShow()
    }
}

class AlertViewDelegate: NSObject, UIAlertViewDelegate {
    fileprivate var zelf: AlertViewDelegate!
    
    fileprivate var resolve: ((Promise<Int>) -> Void)!
    fileprivate var promise: Promise<Int>!
    
    override init() {
        super.init()
        
        zelf = self
        promise = Promise<Int> { resolve in
            self.resolve = resolve
        }
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        resolve(Promise(buttonIndex))
        
        resolve = nil
        DispatchQueue.main.async {
            self.zelf = nil
        }
    }
}

extension UIActionSheet {
    public func promisedShowInView(_ view: UIView) -> Promise<Int> {
        let delegate = ActionSheetDelegate()
        self.delegate = delegate
        show(in: view)
        return delegate.promise
    }

    public class func promisedShowInView(_ view: UIView, title: String? = nil, cancelButtonTitle: String? = nil, destructiveButtonTitle: String? = nil, buttonTitles: [String]) -> Promise<Int> {
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
        return actionSheet.promisedShowInView(view)
    }
}

class ActionSheetDelegate: NSObject, UIActionSheetDelegate {
    fileprivate var zelf: ActionSheetDelegate!
    
    fileprivate var resolve: ((Promise<Int>) -> Void)!
    fileprivate var promise: Promise<Int>!
    
    override init() {
        super.init()
        
        zelf = self
        promise = Promise { resolve in
            self.resolve = resolve
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        resolve(Promise(buttonIndex))

        resolve = nil
        DispatchQueue.main.async {
            self.zelf = nil
        }
    }
}
