//
//  View.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Foundation

/**
A Singleton `IView` implementation.

In PureMVC, the `View` class assumes these responsibilities:

* Maintain a cache of `IMediator` instances.
* Provide methods for registering, retrieving, and removing `IMediators`.
* Notifiying `IMediators` when they are registered or removed.
* Managing the observer lists for each `INotification` in the application.
* Providing a method for attaching `IObservers` to an `INotification`'s observer list.
* Providing a method for broadcasting an `INotification`.
* Notifying the `IObservers` of a given `INotification` when it broadcast.

`@see org.puremvc.swift.patterns.mediator.Mediator Mediator`

`@see org.puremvc.swift.patterns.observer.Observer Observer`

`@see org.puremvc.swift.patterns.observer.Notification Notification`
*/
open class View: IView {
    
    // Mapping of Mediator names to Mediator instances
    fileprivate var mediatorMap: [String: IMediator]
    
    // Concurrent queue for mediatorMap
    // for speed and convenience of running concurrently while reading, and thread safety of blocking while mutating
    fileprivate let mediatorMapQueue: DispatchQueue = DispatchQueue(label: "org.puremvc.view.mediatorMapQueue", attributes: DispatchQueue.Attributes.concurrent)
    
    // Mapping of Notification names to Observer lists
    fileprivate var observerMap: [String: Array<IObserver>]
    
    // Concurrent queue for singleton instance
    fileprivate static let instanceQueue = DispatchQueue(label: "org.puremvc.view.instanceQueue", attributes: DispatchQueue.Attributes.concurrent)
    
    // Concurrent queue for observerMap
    // for speed and convenience of running concurrently while reading, and thread safety of blocking while mutating
    fileprivate let observerMapQueue: DispatchQueue = DispatchQueue(label: "org.puremvc.view.observerMapQueue", attributes: DispatchQueue.Attributes.concurrent)
    
    // Singleton instance
    fileprivate static var instance: IView?
    
    /// Message constant
    open static let SINGLETON_MSG = "View Singleton already constructed!"
    
    /**
    Constructor.
    
    This `IView` implementation is a Singleton,
    so you should not call the constructor
    directly, but instead call the static Singleton
    Factory method `View.getInstance()`
    
    @throws Error if Singleton instance has already been constructed
    */
    public init() {
        assert(View.instance == nil, View.SINGLETON_MSG)
        mediatorMap = [:]
        observerMap = [:]
        View.instance = self
        initializeView()
    }
    
    /**
    Initialize the Singleton View instance.
    
    Called automatically by the constructor, this
    is your opportunity to initialize the Singleton
    instance in your subclass without overriding the
    constructor.
    */
    open func initializeView() {
        
    }
    
    /**
    View Singleton Factory method.
    
    - parameter closure: reference that returns `IView`
    - returns: the Singleton instance of `View`
    */
    open class func getInstance(_ closure: () -> IView) -> IView {
        instanceQueue.sync(flags: .barrier, execute: {
            if(View.instance == nil) {
                View.instance = closure()
            }
        })
        return instance!
    }
    
    /**
    Register an `IObserver` to be notified
    of `INotifications` with a given name.
    
    - parameter notificationName: the name of the `INotifications` to notify this `IObserver` of
    - parameter observer: the `IObserver` to register
    */
    open func registerObserver(_ notificationName: String, observer: IObserver) {
        observerMapQueue.sync(flags: .barrier, execute: {
            if self.observerMap[notificationName] != nil {
                self.observerMap[notificationName]!.append(observer)
            } else {
                self.observerMap[notificationName] = [observer]
            }
        }) 
    }

    /**
    Notify the `IObservers` for a particular `INotification`.
    
    All previously attached `IObservers` for this `INotification`'s
    list are notified and are passed a reference to the `INotification` in
    the order in which they were registered.
    
    - parameter notification: the `INotification` to notify `IObservers` of.
    */
    open func notifyObservers(_ notification: INotification) {
        var observers: [IObserver]?
        
        observerMapQueue.sync {
            // observers_ref is an immutable/constant reference to the observers list for this notification name
            // Swift Arrays are copied by value, and observers in this case a constant/immutable array
            // The original array may change during the notification loop but irrespective of that all observers will be notified
            if let observers_ref = self.observerMap[notification.name] {
                observers = observers_ref
            }
        }
        
        // Notify Observers
        if observers != nil {
            for observer in observers! {
                observer.notifyObserver(notification)
            }
        }
    }
    
    /**
    Remove the observer for a given notifyContext from an observer list for a given Notification name.
    
    - parameter notificationName: which observer list to remove from
    - parameter notifyContext: remove the observer with this object as its notifyContext
    */
    open func removeObserver(_ notificationName: String, notifyContext: AnyObject) {
        observerMapQueue.sync(flags: .barrier, execute: {
            // the observer list for the notification under inspection
            if let observers = self.observerMap[notificationName] {
                
                // find the observer for the notifyContext
                for (index, _) in observers.enumerated() {
                    if observers[index].compareNotifyContext(notifyContext) {
                        // there can only be one Observer for a given notifyContext
                        // in any given Observer list, so remove it and break
                        self.observerMap[notificationName]!.remove(at: index)
                        break;
                    }
                }
                
                // Also, when a Notification's Observer list length falls to
                // zero, delete the notification key from the observer map
                if observers.isEmpty {
                    self.observerMap.removeValue(forKey: notificationName);
                }
            }
        }) 
    }
    
    /**
    Register an `IMediator` instance with the `View`.
    
    Registers the `IMediator` so that it can be retrieved by name,
    and further interrogates the `IMediator` for its
    `INotification` interests.
    
    If the `IMediator` returns any `INotification`
    names to be notified about, an `Observer` is created encapsulating
    the `IMediator` instance's `handleNotification` method
    and registering it as an `Observer` for all `INotifications` the
    `IMediator` is interested in.
    
    - parameter mediatorName: the name to associate with this `IMediator` instance
    - parameter mediator: a reference to the `IMediator` instance
    */
    open func registerMediator(_ mediator: IMediator) {
        // do not allow re-registration (you must removeMediator first)
        if (hasMediator(mediator.mediatorName)) {
            return
        }
        
        mediatorMapQueue.sync(flags: .barrier, execute: {
            // Register the Mediator for retrieval by name
            self.mediatorMap[mediator.mediatorName] = mediator
            
            // Get Notification interests, if any.
            let interests = mediator.listNotificationInterests()
            
            // Register Mediator as an observer for each notification of interests
            if !interests.isEmpty {
                // Create Observer referencing this mediator's handlNotification method
                
                let observer = Observer(notifyMethod: {notification in mediator.handleNotification(notification)}, notifyContext: mediator as! Mediator)
                
                // Register Mediator as Observer for its list of Notification interests
                for notificationName in interests {
                    self.registerObserver(notificationName, observer: observer)
                }
            }
            
            // alert the mediator that it has been registered
            mediator.onRegister()
        }) 
    }

    /**
    Retrieve an `IMediator` from the `View`.
    
    - parameter mediatorName: the name of the `IMediator` instance to retrieve.
    - returns: the `IMediator` instance previously registered with the given `mediatorName`.
    */
    open func retrieveMediator(_ mediatorName: String) -> IMediator? {
        var mediator: IMediator?
        mediatorMapQueue.sync {
            mediator = self.mediatorMap[mediatorName]
        }
        return mediator
    }

    /**
    Remove an `IMediator` from the `View`.
    
    - parameter mediatorName: name of the `IMediator` instance to be removed.
    - returns: the `IMediator` that was removed from the `View`
    */
    open func removeMediator(_ mediatorName: String) -> IMediator? {
        var removed: IMediator?
        mediatorMapQueue.sync(flags: .barrier, execute: {
            if let mediator = self.mediatorMap[mediatorName] {
                // for every notification this mediator is interested in...
                let interests = mediator.listNotificationInterests()
                
                for notificationName in interests {
                    // remove the observer linking the mediator
                    // to the notification interest
                    self.removeObserver(notificationName, notifyContext: mediator as! Mediator)
                }
                
                // remove the mediator from the map
                removed = self.mediatorMap.removeValue(forKey: mediatorName)
                
                // alert the mediator that it has been removed
                mediator.onRemove()
            }
        }) 
        return removed
    }
    
    /**
    Check if a Mediator is registered or not
    
    - parameter mediatorName:
    - returns: whether a Mediator is registered with the given `mediatorName`.
    */
    open func hasMediator(_ mediatorName: String) -> Bool {
        var result = false
        mediatorMapQueue.sync {
            result = self.mediatorMap[mediatorName] != nil
        }
        return result
    }

}
