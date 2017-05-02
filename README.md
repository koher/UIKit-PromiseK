UIKit-PromiseK
=======================

_UIKit-PromiseK_ provides extensions of _UIKit_ to collaborate with [_PromiseK_](https://github.com/koher/PromiseK/).

```swift
_ = UIView.promisedAnimate(withDuration: 0.5) {
    self.square.frame.origin.x += 100
}.flatMap { finished in
    UIView.promisedAnimate(withDuration: 0.5) {
        self.square.frame.origin.y += 100
    }
}.flatMap { finished in
    UIView.promisedAnimate(withDuration: 0.5) {
        self.square.alpha = 0.0
    }
}

_ = promisedPresentAlertController(
    withTitle: "Title",
    message: "Message",
    preferredStyle: .alert,
    buttons: [
        (title: "No", style: .cancel, value: false),
        (title: "Yes", style: .default, value: true),
    ]
).map { answer -> Void in
    if answer {
        self.doSomething()
    }
}
```

License
-----------------------

[The MIT License](LICENSE)
