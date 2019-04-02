//
//  ICommand.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
The interface definition for a PureMVC Notifier.

`MacroCommand, Command, Mediator` and `Proxy`
all have a need to send `Notifications`.

The `INotifier` interface provides a common method called
`sendNotification` that relieves implementation code of
the necessity to actually construct `Notifications`.

The `Notifier` class, which all of the above mentioned classes
extend, also provides an initialized reference to the `Facade`
Singleton, which is required for the convienience method
for sending `Notifications`, but also eases implementation as these
classes have frequent `Facade` interactions and usually require
access to the facade anyway.

`@see org.puremvc.swift.interfaces.IFacade IFacade`

`@see org.puremvc.swift.interfaces.INotification INotification`
*/
public protocol INotifier {
    
    /**
    Send a `INotification`.
    
    Convenience method to prevent having to construct new
    notification instances in our implementation code.
    
    - parameter notificationName: the name of the notification to send
    - parameter body: the body of the notification (optional)
    - parameter type: the type of the notification (optional)
    */
    func sendNotification(_ notificationName: String, body: Any?, type: String?)
    
}
