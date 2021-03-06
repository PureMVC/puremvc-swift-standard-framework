//
//  ViewTestMediator4.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2020 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

@testable import PureMVC

/**
A Mediator class used by ViewTest.

`@see org.puremvc.swift.multicore.core.view.ViewTest ViewTest`
*/
public class ViewTestMediator4: Mediator {

    /**
    The Mediator name
    */
    public override class var NAME: String { return "ViewTestMediator4" }
    
    public init(viewComponent: AnyObject?) {
        super.init(name: ViewTestMediator4.NAME, viewComponent: viewComponent)
    }
    
    public override func onRegister() {
        viewTest.onRegisterCalled = true
    }
    
    public override func onRemove() {
        viewTest.onRemoveCalled = true
    }
    
    public var viewTest: ViewTest {
        return viewComponent as! ViewTest
    }
    
}
