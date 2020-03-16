//
//  ViewTestMediator.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2020 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

@testable import PureMVC

/**
A Mediator class used by ViewTest.
*
`@see org.puremvc.swift.multicore.core.view.ViewTest ViewTest
*/
public class ViewTestMediator: Mediator {
    
    /**
    The Mediator name
    */
    public override class var NAME: String { return "ViewTestMediator" }
    
    /**
    Constructor
    */
    public init(viewComponent: AnyObject?) {
        super.init(name: ViewTestMediator.NAME, viewComponent: viewComponent)
    }

    public override func listNotificationInterests() -> [String] {
        // be sure that the mediator has some Observers created
        // in order to test removeMediator
        return ["ABC", "DEF", "GHI"]
    }
    
}
