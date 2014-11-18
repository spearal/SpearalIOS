/**
 * == @Spearal ==>
 *
 * Copyright (C) 2014 Franck WOLFF & William DRAI (http://www.spearal.io)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// author: Franck WOLFF

import Foundation

public protocol SpearalPrinterOutput {
    
    func print(value:String) -> SpearalPrinterOutput
}

public class SpearalPrinterStringOutput: SpearalPrinterOutput {
    
    private var _value:String = ""
    
    public var value:String {
        return _value
    }
    
    public init() {
    }
    
    public func print(value:String) -> SpearalPrinterOutput {
        _value += value
        return self
    }
}

public protocol SpearalPrinter {
    
    var output:SpearalPrinterOutput { get }
    
    init(_ output:SpearalPrinterOutput)
    
    func printNil()
    func printBoolean(value:Bool)
    
    func printIntegral(value:Int)
    func printBigIntegral(value:String)
    func printFloating(value:Double)
    func printBigFloating(value:String)
    
    func printString(value:String)
    
    func printByteArrayReference(referenceIndex:Int)
    func printByteArray(value:[UInt8], referenceIndex:Int)
    
    func printDateTime(value:NSDate)
    
    func printCollectionReference(referenceIndex:Int)
    func printStartCollection(referenceIndex:Int)
    func printEndCollection()
    
    func printMapReference(referenceIndex:Int)
    func printStartMap(referenceIndex:Int)
    func printEndMap()
    
    func printEnum(className:String, valueName:String)
    func printClass(value:String)
    
    func printBeanReference(referenceIndex:Int)
    func printStartBean(className:String, referenceIndex:Int)
    func printBeanProperty(name:String)
    func printEndBean()
}

public class SpearalDefaultPrinter: SpearalPrinter {
    
    private class Context {
        var first:Bool = true
    }
    
    private class Collection: Context {
    }
    
    private class Bean: Context {
        var name:Bool = true
    }
    
    private class Map: Context {
        var key:Bool = true
    }
    
    public let output:SpearalPrinterOutput
    private var contexts = [Context]()
    
    public required init(_ output:SpearalPrinterOutput) {
        self.output = output
    }
    
    public func printNil() {
        indentValue("nil")
    }
    
    public func printBoolean(value:Bool) {
        indentValue("\(value)")
    }
    
    public func printIntegral(value:Int) {
        indentValue("\(value)")
    }
    
    public func printBigIntegral(value:String) {
        indentValue(value)
    }
    
    public func printFloating(value:Double) {
        indentValue("\(value)")
    }
    
    public func printBigFloating(value:String) {
        indentValue(value)
    }
    
    public func printString(value:String) {
        indentValue("\"\(value)\"")
    }
    
    public func printByteArrayReference(referenceIndex:Int) {
        indentValue("@\(referenceIndex)")
    }
    
    public func printByteArray(value:[UInt8], referenceIndex:Int) {
        indentValue("#\(referenceIndex) \(value)")
    }
    
    public func printDateTime(value:NSDate) {
        indentValue("\(value)")
    }
    
    public func printCollectionReference(referenceIndex:Int) {
        indentValue("@\(referenceIndex)")
    }
    
    public func printStartCollection(referenceIndex:Int) {
        indentValue("#\(referenceIndex) [")
        contexts.append(Collection())
    }
    
    public func printEndCollection() {
        contexts.removeLast()
        indentEnd("]")
    }
    
    public func printMapReference(referenceIndex:Int) {
        indentValue("@\(referenceIndex)")
    }
    
    public func printStartMap(referenceIndex:Int) {
        indentValue("#\(referenceIndex) {")
        contexts.append(Map())
    }
    
    public func printEndMap() {
        contexts.removeLast()
        indentEnd("}")
    }
    
    public func printEnum(className:String, valueName:String) {
        indentValue("\(className).\(valueName)")
    }
    public func printClass(value:String) {
        indentValue(value)
    }
    
    public func printBeanReference(referenceIndex:Int) {
        indentValue("@\(referenceIndex)")
    }
    public func printStartBean(className:String, referenceIndex:Int) {
        indentValue("#\(referenceIndex) \(className) {")
        contexts.append(Bean())
    }
    public func printBeanProperty(name:String) {
        indentValue(name)
    }
    public func printEndBean() {
        contexts.removeLast()
        indentEnd("}")
    }
    
    private func indentValue(value:String) {
        if contexts.isEmpty {
            output.print(value)
            return
        }
        
        switch contexts.last {
        case let collection as Collection:
            if collection.first {
                collection.first = false
            }
            else {
                output.print(",")
            }
            output.print("\n\(spaces())\(value)")
            
        case let bean as Bean:
            if bean.name {
                if bean.first {
                    bean.first = false
                }
                else {
                    output.print(",")
                }
                output.print("\n\(spaces())\(value): ")
            }
            else {
                output.print(value)
            }
            bean.name = !bean.name
            
        case let map as Map:
            if map.key {
                if map.first {
                    map.first = false
                }
                else {
                    output.print(",")
                }
                output.print("\n\(spaces())")
            }
            output.print(value)
            if map.key {
                output.print(": ")
            }
            map.key = !map.key
            
        default:
            println("[SpearalPrinterImpl] Unexpected context: \(contexts.last)")
            break
        }
    }
    
    private func spaces() -> String {
        return String(count: contexts.count, repeatedValue: Character("\t"))
    }
    
    private func indentEnd(value:String) {
        output.print("\n")
        output.print(String(count: contexts.count, repeatedValue: Character("\t")))
        output.print(value)
    }
}
