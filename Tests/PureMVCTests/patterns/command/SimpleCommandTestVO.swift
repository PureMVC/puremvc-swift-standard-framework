//
//  SimpleCommandTestVO.swift
//  PureMVC SWIFT Standard
//
//  Copyright(c) 2020 Saad Shams <saad.shams@puremvc.org>
//  Your reuse is governed by the Creative Commons Attribution 3.0 License
//

/**
A utility class used by SimpleCommandTest.

`@see org.puremvc.swift.multicore.patterns.command.SimpleCommandTest SimpleCommandTest`

`@see org.puremvc.swift.multicore.patterns.command.SimpleCommandTestCommand SimpleCommandTestCommand`
*/
public class SimpleCommandTestVO {
    
    public var input: Int
    public var result: Int?
    
    /**
    Constructor.
    
    - parameter input: the number to be fed to the SimpleCommandTestCommand
    */
    init(input: Int) {
        self.input = input;
    }

}
