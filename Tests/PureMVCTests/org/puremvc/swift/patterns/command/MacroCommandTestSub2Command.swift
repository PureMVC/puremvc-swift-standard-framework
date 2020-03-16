//
//  MacroCommandTestSub2Command.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2020 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

@testable import PureMVC

public class MacroCommandTestSub2Command: SimpleCommand {
    
    public override init() {
        super.init()
    }
    
    /**
    Fabricate a result by multiplying the input by itself
    
    - parameter event: the `IEvent` carrying the `MacroCommandTestVO`
    */
    public override func execute(_ notification: INotification) {
        let vo = notification.body as! MacroCommandTestVO
        
        // Fabricate a result
        vo.result2 = vo.input * vo.input
    }
    
}
