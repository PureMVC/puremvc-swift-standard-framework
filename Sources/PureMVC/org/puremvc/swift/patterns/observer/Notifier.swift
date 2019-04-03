//
//  Notifier.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
A Base `INotifier` implementation.

`MacroCommand, Command, Mediator` and `Proxy`
all have a need to send `Notifications`. 

The `INotifier` interface provides a common method called
`sendNotification` that relieves implementation code of
the necessity to actually construct `Notifications`.

The `Notifier` class, which all of the above mentioned classes
extend, provides an initialized reference to the `Facade`
Singleton, which is required for the convienience method
for sending `Notifications`, but also eases implementation as these
classes have frequent `Facade` interactions and usually require
access to the facade anyway.

`@see org.puremvc.swift.patterns.facade.Facade Facade`

`@see org.puremvc.swift.patterns.mediator.Mediator Mediator`

`@see org.puremvc.swift.patterns.proxy.Proxy Proxy`

`@see org.puremvc.swift.patterns.command.SimpleCommand SimpleCommand`

`@see org.puremvc.swift.patterns.command.MacroCommand MacroCommand`
*/
open class Notifier : INotifier {

    /// Reference to the Facade Singleton
    open var facade:IFacade = Facade.getInstance() { Facade() }
    
    /// Constructor
    public init() {
        
    }
    
    /**
    Create and send an `INotification`.
    
    Keeps us from having to construct new INotification
    instances in our implementation code.
    
    - parameter notificationName: the name of the notiification to send
    - parameter body: the body of the notification (optional)
    - parameter type: the type of the notification (optional)
    */
    open func sendNotification(_ notificationName: String, body: Any?=nil, type: String?=nil) {
        facade.sendNotification(notificationName, body: body, type: type)
    }
    
}
