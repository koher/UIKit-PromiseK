UIKit-PromiseK
=======================

_UIKit-PromiseK_ provides extensions of _UIKit_ to collaborate with [_PromiseK_](https://github.com/koher/PromiseK/).

```swift
UIView.promisedAnimate(duration: 0.5) {
    self.square.frame.origin.x += 100
}.flatMap { finished in
    UIView.promisedAnimate(duration: 0.5) {
        self.square.frame.origin.y += 100
    }
}.flatMap { finished in
    UIView.promisedAnimate(duration: 0.5) {
        self.square.alpha = 0.0
    }
}

promisedPresentAlertController(
    title: "Title",
    message: "Message",
     preferredStyle: .Alert,
    buttons: [
        (title: "No", style: .Cancel, value: false),
        (title: "Yes", style: .Default, value: true),
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
