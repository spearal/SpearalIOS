//
//  Test.swift
//  SpearalIOS
//
//  Created by Franck Wolff on 10/2/14.
//  Copyright (c) 2014 Spearal. All rights reserved.
//

import Foundation

class Test: NSObject {
    
}

@objc(Test2)
class Test2: NSObject {
    
    var abc:String = ""
    var opts:String? = "opts"
    var intp:Int = 0
    let def:Int = 0
    
    private var bla:String = "bla"
}

protocol ReflectableEnum {
    
    func className() -> String
}

enum MyEnum /*: ReflectableEnum*/ {

    case BLA
    case BLO
    
    /*
    func className() -> String {
        return "MyEnum"
    }
    
    static func valueOf(literal:String) -> MyEnum? {
        switch literal {
            case "BLA":
                return BLA
            case "BLO":
                return BLO
            default:
                return nil
        }
    }
    */
}