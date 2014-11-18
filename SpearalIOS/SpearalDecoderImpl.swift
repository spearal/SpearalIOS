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

private class SpearalConverterContextRootImpl: SpearalConverterContextRoot {
}

private class SpearalConverterContextObjectImpl: SpearalConverterContextObject {
    
    let type:AnyClass
    
    private var _property:String?
    var property:String {
        get { return _property! }
    }
    
    init(_ type:AnyClass) {
        self.type = type
    }
}

private class SpearalConverterContextCollectionImpl: SpearalConverterContextCollection {
    
    private var _index:Int?
    var index:Int {
        get { return _index! }
    }
}

private class SpearalConverterContextMapKeyImpl: SpearalConverterContextMapKey {
}

private class SpearalConverterContextMapValueImpl: SpearalConverterContextMapValue {
    
    private var _key:NSObject?
    var key:NSObject {
        get { return _key! }
    }
}

class SpearalDecoderImpl: SpearalDecoder {
    
    let context:SpearalContext
    let input:SpearalInput
    let printer:SpearalPrinter?

    private var sharedStrings:[String]
    private var sharedObjects:[Any]
    private var depth:Int
    
    private let calendar:NSCalendar
    
    init(context:SpearalContext, input:SpearalInput, printer:SpearalPrinter? = nil) {
        self.context = context
        self.input = input
        self.printer = printer

        self.sharedStrings = [String]()
        self.sharedObjects = [Any]()
        self.depth = 0
        
        self.calendar = NSCalendar(identifier:NSGregorianCalendar)!
    }
    
    func readAny() -> Any? {
        var value:Any?
        
        let parameterizedType = input.read()
        
        ++depth
        
        if let type = SpearalType.valueOf(parameterizedType) {
            switch type {
            case .NULL:
                value = nil
                printer?.printNil()
            case .TRUE:
                value = true
                printer?.printBoolean(true)
            case .FALSE:
                value = false
                printer?.printBoolean(false)

            case .INTEGRAL:
                value = readIntegral(parameterizedType)
            case .BIG_INTEGRAL:
                value = readBigIntegral(parameterizedType)
                
            case .FLOATING:
                value = readFloating(parameterizedType)
            case .BIG_FLOATING:
                value = readBigFloating(parameterizedType)
                
            case .STRING:
                value = readString(parameterizedType)
                
            case .BYTE_ARRAY:
                value = readByteArray(parameterizedType)
                
            case .DATE_TIME:
                value = readDateTime(parameterizedType)
                
            case .COLLECTION:
                value = readCollection(parameterizedType)
            case .MAP:
                value = readMap(parameterizedType)
                
            case .ENUM:
                value = readEnum(parameterizedType)
            case .CLASS:
                value = readClass(parameterizedType)
            case .BEAN:
                value = readBean(parameterizedType)
            }
        }
        
        if --depth == 0 {
            value = context.convert(value, context: SpearalConverterContextRootImpl())
            
            //println((printer as SpearalStringPrinter).representation)
        }

        return value
    }
    
    func readIntegral(parameterizedType:UInt8) -> Int {
        let length0 = (parameterizedType & 0x07)
        
        var value:Int = 0
        switch length0 {
        case 7:
            value |= (Int(input.read()) << 56)
            value |= (Int(input.read()) << 48)
            value |= (Int(input.read()) << 40)
            value |= (Int(input.read()) << 32)
            value |= (Int(input.read()) << 24)
            value |= (Int(input.read()) << 16)
            value |= (Int(input.read()) << 8)
        case 6:
            value |= (Int(input.read()) << 48)
            value |= (Int(input.read()) << 40)
            value |= (Int(input.read()) << 32)
            value |= (Int(input.read()) << 24)
            value |= (Int(input.read()) << 16)
            value |= (Int(input.read()) << 8)
        case 5:
            value |= (Int(input.read()) << 40)
            value |= (Int(input.read()) << 32)
            value |= (Int(input.read()) << 24)
            value |= (Int(input.read()) << 16)
            value |= (Int(input.read()) << 8)
        case 4:
            value |= (Int(input.read()) << 32)
            value |= (Int(input.read()) << 24)
            value |= (Int(input.read()) << 16)
            value |= (Int(input.read()) << 8)
        case 3:
            value |= (Int(input.read()) << 24)
            value |= (Int(input.read()) << 16)
            value |= (Int(input.read()) << 8)
        case 2:
            value |= (Int(input.read()) << 16)
            value |= (Int(input.read()) << 8)
        case 1:
            value |= (Int(input.read()) << 8)
        default:
            break
        }
        value |= Int(input.read())
        
        if (parameterizedType & 0x08) != 0 {
            value = -value;
        }
        
        printer?.printIntegral(value)
        
        return value
    }
    
    func readBigIntegral(parameterizedType:UInt8) -> SpearalBigIntegral {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        var value:SpearalBigIntegral
        
        if SpearalDecoderImpl.isStringReference(parameterizedType) {
            value = SpearalBigIntegral(sharedStrings[indexOrLength])
        }
        else {
            value = SpearalBigIntegral(readBigNumberData(indexOrLength))
        }
        
        printer?.printBigIntegral(value.representation)
        
        return value
    }
    
    func readFloating(parameterizedType:UInt8) -> Double {
        var value:Double = Double.NaN
        
        if (parameterizedType & 0x08) != 0 {
            let length0 = (parameterizedType & 0x03)
            var intValue:Int = readUnsignedIntegerValue(length0)
            if (parameterizedType & 0x04) != 0 {
                intValue = -intValue
            }
            value = Double(intValue) / 1000.0
        }
        else {
            let pointer = doubleToUInt8MutablePointer(&value)
            pointer[7] = input.read()
            pointer[6] = input.read()
            pointer[5] = input.read()
            pointer[4] = input.read()
            pointer[3] = input.read()
            pointer[2] = input.read()
            pointer[1] = input.read()
            pointer[0] = input.read()
        }
        
        printer?.printFloating(value)
        
        return value
    }
    
    func readBigFloating(parameterizedType:UInt8) -> SpearalBigFloating {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        var value:SpearalBigFloating
        
        if SpearalDecoderImpl.isStringReference(parameterizedType) {
            value = SpearalBigFloating(sharedStrings[indexOrLength])
        }
        else {
            value = SpearalBigFloating(readBigNumberData(indexOrLength))
        }
        
        printer?.printBigFloating(value.representation)
        
        return value
    }
    
    func readString(parameterizedType:UInt8) -> String {
        let value = readStringData(parameterizedType)
        printer?.printString(value)
        return value
    }
    
    func readByteArray(parameterizedType:UInt8) -> [UInt8] {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        var value:[UInt8]
        
        if SpearalDecoderImpl.isObjectReference(parameterizedType) {
            printer?.printByteArrayReference(indexOrLength)
            value = sharedObjects[indexOrLength] as [UInt8]
        }
        else {
            value = input.read(indexOrLength)
            printer?.printByteArray(value, referenceIndex: sharedObjects.count)
            sharedObjects.append(value)
        }
        
        return value
    }
    
    func readDateTime(parameterizedType:UInt8) -> NSDate {
        var components = NSDateComponents()

        if (parameterizedType & 0x08) != 0 {
            let month = input.read()
            components.month = Int(month & 0x0f)
            components.day = Int(input.read())

            components.year = readUnsignedIntegerValue((month >> 4) & 0x03)
            if (month & 0x80) != 0 {
                components.year = -components.year
            }
            components.year += 2000
        }
        
        if (parameterizedType & 0x04) != 0 {
            let hours = input.read()
            components.hour = Int(hours & 0x1f)
            components.minute = Int(input.read())
            components.second = Int(input.read())
            
            let subsecondsType = (parameterizedType & 0x03)
            if subsecondsType != 0 {
                components.nanosecond = readUnsignedIntegerValue(hours >> 5)
                if subsecondsType == 2 {
                    components.nanosecond *= 1000;
                }
                else if subsecondsType == 3 {
                    components.nanosecond *= 1000000;
                }
            }
        }
        
        let value = calendar.dateFromComponents(components)!
        printer?.printDateTime(value)
        return value
    }
    
    func readCollection(parameterizedType:UInt8) -> [AnyObject] {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        if SpearalDecoderImpl.isObjectReference(parameterizedType) {
            printer?.printCollectionReference(indexOrLength)
            return sharedObjects[indexOrLength] as [AnyObject]
        }
        
        let null = NSNull()

        var collection = [AnyObject](count: indexOrLength, repeatedValue: null)
        printer?.printStartCollection(sharedObjects.count)
        sharedObjects.append(collection)
        
        let converterContext = SpearalConverterContextCollectionImpl()
        
        let max = (indexOrLength - 1)
        for i in 0...max {
            converterContext._index = i
            let value = context.convert(readAny(), context: converterContext)
            collection[i] = value as? NSObject ?? null
        }
        
        printer?.printEndCollection()
        
        return collection
    }
    
    func readMap(parameterizedType:UInt8) -> [NSObject: AnyObject] {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        if SpearalDecoderImpl.isObjectReference(parameterizedType) {
            printer?.printMapReference(indexOrLength)
            return sharedObjects[indexOrLength] as [NSObject: AnyObject]
        }
        
        let null = NSNull()
        
        var map = [NSObject: AnyObject](minimumCapacity: indexOrLength)
        printer?.printStartMap(sharedObjects.count)
        sharedObjects.append(map)
        
        let converterKeyContext = SpearalConverterContextMapKeyImpl()
        let converterValueContext = SpearalConverterContextMapValueImpl()
        
        let max = (indexOrLength - 1)
        for i in 0...max {
            let key:NSObject = context.convert(readAny(), context: converterKeyContext) as? NSObject ?? null

            converterValueContext._key = key
            let val:NSObject = context.convert(readAny(), context: converterValueContext) as? NSObject ?? null
            
            map[key] = val
        }
        
        printer?.printEndMap()
        
        return map
    }
    
    func readEnum(parameterizedType:UInt8) -> SpearalEnum {
        let remoteClassName = readStringData(parameterizedType)
        let valueName =  readString(input.read())
        
        printer?.printEnum(remoteClassName, valueName: valueName)
        
        let localClassName = context.getAliasStrategy()?.remoteToLocalClassName(remoteClassName) ?? remoteClassName
        
        return SpearalEnum(localClassName, valueName: valueName)
    }
    
    func readClass(parameterizedType:UInt8) -> AnyClass? {
        let name = readStringData(parameterizedType)
        
        printer?.printClass(name)
        
        return context.getIntrospector()!.classForName(name)
    }
    
    func readBean(parameterizedType:UInt8) -> Any {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        if SpearalDecoderImpl.isObjectReference(parameterizedType) {
            printer?.printBeanReference(indexOrLength)
            return sharedObjects[indexOrLength]
        }
        
        let description = readStringData(parameterizedType, indexOrLength: indexOrLength)
        let (remoteClassName, localClassName, remotePropertyNames, localPropertyNames) = parseDescription(description)
        
        printer?.printStartBean(remoteClassName, referenceIndex: sharedObjects.count)
        
        if let cls = NSClassFromString(localClassName) as? NSObject.Type {
            let instance = cls()
            sharedObjects.append(instance as NSObject as Any)
            
            let converterContext = SpearalConverterContextObjectImpl(cls)
            let properties = context.getIntrospector()!.introspect(cls).properties
            
            for (i, localPropertyName) in enumerate(localPropertyNames) {
                printer?.printBeanProperty(remotePropertyNames[i])
                
                let any = readAny()
                
                if contains(properties, localPropertyName) {
                    converterContext._property = localPropertyName
                    let value:AnyObject? = context.convert(any, context: converterContext) as? NSObject as AnyObject?
                    instance.setValue(value, forKey: localPropertyName)
                }
            }
            
            printer?.printEndBean()
            
            return instance
        }
        
        let instance = SpearalUnsupportedClassInstance(localClassName)
        sharedObjects.append(instance)

        for remotePropertyName in remotePropertyNames {
            printer?.printBeanProperty(remotePropertyName)
            instance.properties[remotePropertyName] = readAny() as? NSObject as AnyObject?
        }
        
        printer?.printEndBean()
        
        return instance
    }
    
    private func parseDescription(description:String) -> (String, String, [String], [String]) {
        let aliasStrategy = context.getAliasStrategy()
        let classNamePropertyNames = description.componentsSeparatedByString("#")
        
        let remoteClassName = classNamePropertyNames[0]
        let localClassName = aliasStrategy?.remoteToLocalClassName(remoteClassName) ?? remoteClassName
        
        if classNamePropertyNames.count == 1 || classNamePropertyNames[1].isEmpty {
            return (remoteClassName, localClassName, [], [])
        }
        
        let remotePropertyNames = classNamePropertyNames[1].componentsSeparatedByString(",").filter({
            (elt:String) -> Bool in return !elt.isEmpty
        })
        
        if remotePropertyNames.isEmpty {
            return (remoteClassName, localClassName, [], [])
        }
        
        let aliases = aliasStrategy?.remoteToLocalProperties(localClassName) ?? [String: String]()
        
        let localPropertyNames:[String] = aliases.isEmpty ? remotePropertyNames : (
            remotePropertyNames.map { (remotePropertyName) -> String in
                return aliases[remotePropertyName] ?? remotePropertyName
            }
        )
        
        return (remoteClassName, localClassName, remotePropertyNames, localPropertyNames)
    }
    
    private func readStringData(parameterizedType:UInt8) -> String {
        let indexOrLength = readIndexOrLength(parameterizedType)
        return readStringData(parameterizedType, indexOrLength: indexOrLength)
    }

    private func readStringData(parameterizedType:UInt8, indexOrLength:Int) -> String {
        if SpearalDecoderImpl.isStringReference(parameterizedType) {
            return sharedStrings[indexOrLength]
        }
        
        if indexOrLength == 0 {
            return ""
        }
        
        let utf8:[UInt8] = input.read(indexOrLength)
        let value = NSString(bytes: utf8, length: utf8.count, encoding: NSUTF8StringEncoding) as String
        sharedStrings.append(value)
        return value
    }
    
    private func doubleToUInt8MutablePointer(pointer:UnsafeMutablePointer<Double>) -> UnsafeMutablePointer<UInt8> {
        return UnsafeMutablePointer<UInt8>(pointer)
    }
    
    private func readIndexOrLength(parameterizedType:UInt8) -> Int {
        let length0 = (parameterizedType & 0x03);
        return readUnsignedIntegerValue(length0);
    }
    
    private func readUnsignedIntegerValue(length0:UInt8) -> Int {
        var value:Int = 0
        switch length0 {
        case 3:
            value |= (Int(input.read()) << 24)
            value |= (Int(input.read()) << 16)
            value |= (Int(input.read()) << 8)
        case 2:
            value |= (Int(input.read()) << 16)
            value |= (Int(input.read()) << 8)
        case 1:
            value |= (Int(input.read()) << 8)
        default:
            break
        }
        value |= Int(input.read())
        return value
    }
    
    private class func isObjectReference(parameterizedType:UInt8) -> Bool {
        return ((parameterizedType & 0x08) != 0)
    }
    
    private class func isStringReference(parameterizedType:UInt8) -> Bool {
        return ((parameterizedType & 0x04) != 0)
    }
    
    private func readBigNumberData(length:Int) -> String {
        let count = (length / 2) + (length % 2)
        
        var chars = [UInt8](count: length, repeatedValue: 0)
        var iChar = 0
        for i in 0...count {
            var b = input.read()
            chars[iChar++] = BIG_NUMBER_ALPHA[Int((b & 0xf0) >> 4)]
            if iChar == length {
                break
            }
            chars[iChar++] = BIG_NUMBER_ALPHA[Int(b & 0x0f)]
        }
        
        let value = NSString(bytes: chars, length: chars.count, encoding: NSUTF8StringEncoding) as String
        sharedStrings.append(value)
        return value
    }
}