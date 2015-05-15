//
//  IObserver.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
The interface definition for a PureMVC Observer.

In PureMVC, `IObserver` implementors assume these responsibilities:

* Encapsulate the notification (callback) method of the interested object.
* Encapsulate the notification context (self) of the interested object.
* Provide methods for setting the interested object' notification method and context.
* Provide a method for notifying the interested object.

PureMVC does not rely upon underlying event
models such as the one provided with Flash,
and ActionScript 3 does not have an inherent
event model.

The Observer Pattern as implemented within
PureMVC exists to support event driven communication
between the application and the actors of the
MVC triad.

An Observer is an object that encapsulates information
about an interested object with a notification method that
should be called when an `INotification` is broadcast. The Observer then
acts as a proxy for notifying the interested object.

Observers can receive `Notification`s by having their
`notifyObserver` method invoked, passing
in an object implementing the `INotification` interface, such
as a subclass of `Notification`.

`@see org.puremvc.swift.interfaces.IView IView`

`@see org.puremvc.swift.interfaces.INotification INotification`
*/
public protocol IObserver {
    
    /**
    Set the notification method.
    
    The notification method should take one parameter of type `INotification`
    
    :param: notifyMethod the notification (callback) method of the interested object
    */
    var notifyMethod: ((notification: INotification) -> ())? { get set }
    
    /// Get or set the notification context (self) of the interested object.
    var notifyContext: AnyObject? { get set }
    
    /**
    Notify the interested object.
    
    :param: notification the `INotification` to pass to the interested object's notification method
    */
    func notifyObserver(notification: INotification)
    
    /**
    Compare the given object to the notificaiton context object.
    
    :param: object the object to compare.
    :returns: boolean indicating if the notification context and the object are the same.
    */
    func compareNotifyContext(object: AnyObject) -> Bool
    
}
