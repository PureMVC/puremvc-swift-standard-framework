//
//  Facade.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Foundation

/**
A base Multiton `IFacade` implementation.

`@see org.puremvc.swift.core.model.Model Model`

`@see org.puremvc.swift.core.view.View View`

`@see org.puremvc.swift.core.controller.Controller Controller`

`@see org.puremvc.swift.patterns.observer.Notification Notification`

`@see org.puremvc.swift.patterns.mediator.Mediator Mediator`

`@see org.puremvc.swift.patterns.proxy.Proxy Proxy`

`@see org.puremvc.swift.patterns.command.SimpleCommand SimpleCommand`

`@see org.puremvc.swift.patterns.command.MacroCommand MacroCommand`
*/
public class Facade: IFacade {
    
    // References to Model, View and Controller
    private var controller: IController?
    private var model: IModel?
    private var view: IView?
    
    // The Singleton Facade instance
    private static var instance: IFacade?
    
    // to ensure operation happens only once
    static var token: dispatch_once_t = 0
    
    /// Message Constant
    public static let SINGLETON_MSG = "Facade Singleton already constructed!"
    
    /**
    Constructor.
    
    This `IFacade` implementation is a Singleton,
    so you should not call the constructor
    directly, but instead call the static Singleton
    Factory method, passing the closure that
    returns the `IFacade` implementation. `Facade.getInstance() { Facade() }`
    
    @throws Error Error if Singleton instance has already been constructed
    */
    public init() {
        assert(Facade.instance == nil, Facade.SINGLETON_MSG)
        Facade.instance = self
        initializeFacade()
    }
    
    /**
    Initialize the Singleton `Facade` instance.
    
    Called automatically by the constructor. Override in your
    subclass to do any subclass specific initializations. Be
    sure to call `super.initializeFacade()`, though.
    */
    public func initializeFacade() {
        initializeModel()
        initializeController()
        initializeView()
    }
    
    /**
    Facade Singleton Factory method

    - parameter closure: reference that returns `IFacade`
    - returns: the Singleton instance of the `IFacade`
    */
    public class func getInstance(closure: (() -> IFacade)) -> IFacade {
        dispatch_once(&self.token) {
            self.instance = closure()
        }
        return instance!
    }
    
    /**
    Initialize the `Controller`.
    
    Called by the `initializeFacade` method.
    Override this method in your subclass of `Facade`
    if one or both of the following are true:
    
    * You wish to initialize a different `IController`.
    * You have `Commands` to register with the `Controller` at startup. 
    
    If you don't want to initialize a different `IController`,
    call `super.initializeController()` at the beginning of your
    method, then register `Commands`.
    */
    public func initializeController() {
        if controller != nil {
            return
        }
        controller = Controller.getInstance { Controller() }
    }
    
    /**
    Initialize the `Model`.
    
    Called by the `initializeFacade` method.
    Override this method in your subclass of `Facade`
    if one or both of the following are true: 
    
    * You wish to initialize a different `IModel`.
    * You have `Proxy`s to register with the Model that do not
    retrieve a reference to the Facade at construction time.
    
    If you don't want to initialize a different `IModel`,
    call `super.initializeModel()` at the beginning of your
    method, then register `Proxy`s.
    
    Note: This method is *rarely* overridden; in practice you are more
    likely to use a `Command` to create and register `Proxy`s
    with the `Model`, since `Proxy`s with mutable data will likely
    need to send `INotification`s and thus will likely want to fetch a reference to
    the `Facade` during their construction.
    */
    public func initializeModel() {
        if model != nil {
            return
        }
        model = Model.getInstance { Model() }
    }
    
    /**
    Initialize the `View`.
    
    Called by the `initializeFacade` method.
    Override this method in your subclass of `Facade`
    if one or both of the following are true:
    
    * You wish to initialize a different `IView`.
    * You have `Observers` to register with the `View`
    
    If you don't want to initialize a different `IView`,
    call `super.initializeView()` at the beginning of your
    method, then register `IMediator` instances.
    
    Note: This method is *rarely* overridden; in practice you are more
    likely to use a `Command` to create and register `Mediator`s
    with the `View`, since `IMediator` instances will need to send
    `INotifications` and thus will likely want to fetch a reference
    to the `Facade` during their construction.
    */
    public func initializeView() {
        if view != nil {
            return
        }
        view = View.getInstance { View() }
    }
    
    /**
    Register an `ICommand` with the `Controller` by Notification name.
    
    - parameter notificationName: the name of the `INotification` to associate the `ICommand` with
    - parameter closure: reference that returns `ICommand`
    */
    public func registerCommand(notificationName: String, closure: () -> ICommand) {
        controller!.registerCommand(notificationName, closure: closure)
    }
    
    /**
    Remove a previously registered `ICommand` to `INotification` mapping from the Controller.
    
    - parameter notificationName: the name of the `INotification` to remove the `ICommand` mapping for
    */
    public func removeCommand(notificationName: String) {
        controller!.removeCommand(notificationName)
    }
    
    /**
    Check if a Command is registered for a given Notification
    
    - parameter notificationName:
    - returns: whether a Command is currently registered for the given `notificationName`.
    */
    public func hasCommand(notificationName: String) -> Bool {
        return controller!.hasCommand(notificationName)
    }
    
    /**
    Register an `IProxy` with the `Model` by name.
    
    - parameter proxyName: the name of the `IProxy`.
    - parameter proxy: the `IProxy` instance to be registered with the `Model`.
    */
    public func registerProxy(proxy: IProxy) {
        model!.registerProxy(proxy)
    }
    
    /**
    Retrieve an `IProxy` from the `Model` by name.
    
    - parameter proxyName: the name of the proxy to be retrieved.
    - returns: the `IProxy` instance previously registered with the given `proxyName`.
    */
    public func retrieveProxy(proxyName: String) -> IProxy? {
        return model!.retrieveProxy(proxyName)
    }
    
    /**
    Remove an `IProxy` from the `Model` by name.
    
    - parameter proxyName: the `IProxy` to remove from the `Model`.
    - returns: the `IProxy` that was removed from the `Model`
    */
    public func removeProxy(proxyName: String) -> IProxy? {
        return model!.removeProxy(proxyName)
    }
    
    /**
    Check if a Proxy is registered
    
    - parameter proxyName:
    - returns: whether a Proxy is currently registered with the given `proxyName`.
    */
    public func hasProxy(proxyName: String) -> Bool {
        return model!.hasProxy(proxyName)
    }
    
    /**
    Register a `IMediator` with the `View`.
    
    - parameter mediatorName: the name to associate with this `IMediator`
    - parameter mediator: a reference to the `IMediator`
    */
    public func registerMediator(mediator: IMediator) {
        view!.registerMediator(mediator)
    }
    
    /**
    Retrieve an `IMediator` from the `View`.
    
    - parameter mediatorName:
    - returns: the `IMediator` previously registered with the given `mediatorName`.
    */
    public func retrieveMediator(mediatorName: String) -> IMediator? {
        return view!.retrieveMediator(mediatorName)
    }
    
    /**
    Remove an `IMediator` from the `View`.
    
    - parameter mediatorName: name of the `IMediator` to be removed.
    - returns: the `IMediator` that was removed from the `View`
    */
    public func removeMediator(mediatorName: String) -> IMediator? {
        return view!.removeMediator(mediatorName)
    }
    
    /**
    Check if a Mediator is registered or not
    
    - parameter mediatorName:
    - returns: whether a Mediator is registered with the given `mediatorName`.
    */
    public func hasMediator(mediatorName: String) -> Bool {
        return view!.hasMediator(mediatorName)
    }
    
    /**
    Notify `Observer`s.
    
    This method is left public mostly for backward
    compatibility, and to allow you to send custom
    notification classes using the facade.
    
    Usually you should just call sendNotification
    and pass the parameters, never having to
    construct the notification yourself.
    
    - parameter notification: the `INotification` to have the `View` notify `Observers` of.
    */
    public func sendNotification(notificationName: String, body: Any?=nil, type: String?=nil) {
        notifyObservers(Notification(name: notificationName, body: body, type: type))
    }
    
    /**
    Notify `Observer`s.
    
    This method is left public mostly for backward
    compatibility, and to allow you to send custom
    notification classes using the facade.
    
    Usually you should just call sendNotification
    and pass the parameters, never having to
    construct the notification yourself.
    
    - parameter notification: the `INotification` to have the `View` notify `Observers` of.
    */
    public func notifyObservers(notification: INotification) {
        view!.notifyObservers(notification)
    }

}
