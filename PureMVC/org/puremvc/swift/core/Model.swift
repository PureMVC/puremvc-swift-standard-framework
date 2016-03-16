//
//  Model.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2015-2025 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

import Foundation

/**
A Singleton `IModel` implementation.

In PureMVC, the `Model` class provides
access to model objects (Proxies) by named lookup.

The `Model` assumes these responsibilities:

* Maintain a cache of `IProxy` instances.
* Provide methods for registering, retrieving, and removing `IProxy` instances.

Your application must register `IProxy` instances
with the `Model`. Typically, you use an
`ICommand` to create and register `IProxy`
instances once the `Facade` has initialized the Core
actors.

`@see org.puremvc.swift.patterns.proxy.Proxy Proxy`

`@see org.puremvc.swift.interfaces.IProxy IProxy`
*/
public class Model: IModel {
    
    // Mapping of proxyNames to IProxy instances
    private var proxyMap: [String: IProxy]
    
    // Singleton instance
    private static var instance: IModel?
    
    // to ensure operation happens only once
    private static var token: dispatch_once_t = 0
    
    // Concurrent queue for proxyMap
    // for speed and convenience of running concurrently while reading, and thread safety of blocking while mutating
    private let proxyMapQueue = dispatch_queue_create("org.puremvc.model.proxyMapQueue", DISPATCH_QUEUE_CONCURRENT)
    
    /// Message constant
    public static let SINGLETON_MSG = "Model Singleton already constructed!"
    
    /**
    Constructor.
    
    This `IModel` implementation is a Singleton,
    so you should not call the constructor
    directly, but instead call the static Singleton
    Factory method `Model.getInstance()`
    
    @throws Error Error if Singleton instance has already been constructed
    */
    public init() {
        assert(Model.instance == nil, Model.SINGLETON_MSG)
        proxyMap = [:]
        Model.instance = self
        initializeModel()
    }

    /**
    Initialize the Singleton `Model` instance.
    
    Called automatically by the constructor, this
    is your opportunity to initialize the Singleton
    instance in your subclass without overriding the
    constructor.
    */
    public func initializeModel() {
        
    }
    
    /**
    `Model` Singleton Factory method.
    
    - parameter closure: reference that returns `IModel`
    - returns: the Singleton instance
    */
    public class func getInstance(closure: () -> IModel) -> IModel {
        dispatch_once(&self.token) {
            self.instance = closure()
        }
        return instance!
    }
    
    /**
    Register an `IProxy` with the `Model`.
    
    - parameter proxy: an `IProxy` to be held by the `Model`.
    */
    public func registerProxy(proxy: IProxy) {
        dispatch_barrier_sync(proxyMapQueue) {
            self.proxyMap[proxy.proxyName] = proxy
            proxy.onRegister()
        }
    }
    
    /**
    Retrieve an `IProxy` from the `Model`.
    
    - parameter proxyName:
    - returns: the `IProxy` instance previously registered with the given `proxyName`.
    */
    public func retrieveProxy(proxyName: String) -> IProxy? {
        var proxy: IProxy?
        dispatch_sync(proxyMapQueue) {
            proxy = self.proxyMap[proxyName]
        }
        return proxy
    }
    
    /**
    Check if a Proxy is registered
    
    - parameter proxyName:
    - returns: whether a Proxy is currently registered with the given `proxyName`.
    */
    public func hasProxy(proxyName: String) -> Bool {
        var result = false
        dispatch_sync(proxyMapQueue) {
            result = self.proxyMap[proxyName] != nil
        }
        return result
    }
    
    /**
    Remove an `IProxy` from the `Model`.
    
    - parameter proxyName: name of the `IProxy` instance to be removed.
    - returns: the `IProxy` that was removed from the `Model`
    */
    public func removeProxy(proxyName: String) -> IProxy? {
        var removed: IProxy?
        dispatch_barrier_sync(proxyMapQueue) {
            if let proxy = self.proxyMap[proxyName] {
                proxy.onRemove()
                removed = self.proxyMap.removeValueForKey(proxyName)
            }
        }
        return removed
    }
    
}
