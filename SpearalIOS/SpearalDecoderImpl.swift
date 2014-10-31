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
    let input: SpearalInput

    private var sharedStrings:[String]
    private var sharedObjects:[Any]
    private var depth:Int
    
    private let calendar:NSCalendar
    
    required init(context:SpearalContext, input: SpearalInput) {
        self.context = context
        self.input = input

        self.sharedStrings = [String]()
        self.sharedObjects = [Any]()
        self.depth = 0
        
        self.calendar = NSCalendar(identifier: NSGregorianCalendar)!
    }
    
    func readAny() -> Any? {
        var value:Any?
        
        let parameterizedType = input.read()
        
        ++depth
        
        if let type = SpearalType.valueOf(parameterizedType) {
            switch type {
            case .NULL:
                value = nil
            case .TRUE:
                value = true
            case .FALSE:
                value = false

            case .INTEGRAL:
                value = readIntegral(parameterizedType)
            case .BIG_INTEGRAL:
                println("BIG_INTEGRAL")
                
            case .FLOATING:
                value = readFloating(parameterizedType)
            case .BIG_FLOATING:
                println("BIG_FLOATING")
                
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
        }

        return value
    }
    
    func readIntegral(parameterizedType:UInt8) -> Int {
        let length0 = (parameterizedType & 0x07);
        
        var value:Int = 0
        
        if length0 >= 7 {
            value |= (Int(input.read()) << 56)
        }
        if length0 >= 6 {
            value |= (Int(input.read()) << 48)
        }
        if length0 >= 5 {
            value |= (Int(input.read()) << 40)
        }
        if length0 >= 4 {
            value |= (Int(input.read()) << 32)
        }
        if length0 >= 3 {
            value |= (Int(input.read()) << 24)
        }
        if length0 >= 2 {
            value |= (Int(input.read()) << 16)
        }
        if length0 >= 1 {
            value |= (Int(input.read()) << 8)
        }
        value |= Int(input.read())
        
        
        if (parameterizedType & 0x08) != 0 {
            value = -value;
        }
        
        return value
    }
    
    func readFloating(parameterizedType:UInt8) -> Double {
        if (parameterizedType & 0x08) != 0 {
            let length0 = (parameterizedType & 0x03)
            
            var value:Int = 0
            if length0 >= 3 {
                value |= (Int(input.read()) << 24)
            }
            if length0 >= 2 {
                value |= (Int(input.read()) << 16)
            }
            if length0 >= 1 {
                value |= (Int(input.read()) << 8)
            }
            value |= Int(input.read())
            
            if (parameterizedType & 0x04) != 0 {
                value = -value
            }
            
            return Double(value) / 1000.0
        }
        
        var value:Double = Double.NaN
        
        let pointer = doubleToUInt8MutablePointer(&value)
        pointer[7] = input.read()
        pointer[6] = input.read()
        pointer[5] = input.read()
        pointer[4] = input.read()
        pointer[3] = input.read()
        pointer[2] = input.read()
        pointer[1] = input.read()
        pointer[0] = input.read()
        
        return value
    }
    
    func readString(parameterizedType:UInt8) -> String {
        return readStringData(parameterizedType)
    }
    
    func readByteArray(parameterizedType:UInt8) -> [UInt8] {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        if SpearalDecoderImpl.isObjectReference(parameterizedType) {
            return sharedObjects[indexOrLength] as [UInt8]
        }
        
        let value:[UInt8] = input.read(indexOrLength)
        sharedObjects.append(value)
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
                components.nanosecond = readUnsignedIntegerValue(hours >> 5);
                if subsecondsType == 2 {
                    components.nanosecond *= 1000;
                }
                else if subsecondsType == 3 {
                    components.nanosecond *= 1000000;
                }
            }
        }
        
        return calendar.dateFromComponents(components)!
    }
    
    func readCollection(parameterizedType:UInt8) -> [AnyObject] {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        if SpearalDecoderImpl.isObjectReference(parameterizedType) {
            return sharedObjects[indexOrLength] as [AnyObject]
        }
        
        let null = NSNull()

        var collection = [AnyObject](count: indexOrLength, repeatedValue: null)
        sharedObjects.append(collection)
        
        let converterContext = SpearalConverterContextCollectionImpl()
        
        let max = (indexOrLength - 1)
        for i in 0...max {
            converterContext._index = i
            let value = context.convert(readAny(), context: converterContext)
            collection[i] = value as? NSObject ?? null
        }
        
        return collection
    }
    
    func readMap(parameterizedType:UInt8) -> [NSObject : AnyObject] {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        if SpearalDecoderImpl.isObjectReference(parameterizedType) {
            return sharedObjects[indexOrLength] as [NSObject: AnyObject]
        }
        
        let null = NSNull()
        
        var map = [NSObject: AnyObject](minimumCapacity: indexOrLength)
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
        
        return map
    }
    
    func readEnum(parameterizedType:UInt8) -> SpearalEnum {
        let remoteClassName = readStringData(parameterizedType)
        let valueName =  readString(input.read())
        
        let localClassName = context.getAliasStrategy()?.remoteToLocalClassName(remoteClassName) ?? remoteClassName
        return SpearalEnum(localClassName, valueName: valueName)
    }
    
    func readClass(parameterizedType:UInt8) -> AnyClass? {
        let name = readStringData(parameterizedType)
        return context.getIntrospector()!.classForName(name)
    }
    
    func readBean(parameterizedType:UInt8) -> Any {
        let indexOrLength = readIndexOrLength(parameterizedType)
        
        if SpearalDecoderImpl.isObjectReference(parameterizedType) {
            return sharedObjects[indexOrLength]
        }
        
        let description = readStringData(parameterizedType, indexOrLength: indexOrLength)
        let (className, propertyNames) = parseDescription(description)

        let cls = NSClassFromString(className) as NSObject.Type
        
        var instance = cls()
        
        sharedObjects.append(instance as NSObject as Any)
        
        let converterContext = SpearalConverterContextObjectImpl(cls)
        let info = context.getIntrospector()!.introspect(cls)
        let properties = info.properties
        for propertyName in propertyNames {
            if contains(properties, propertyName) {
                converterContext._property = propertyName
                let value:AnyObject? = context.convert(readAny(), context: converterContext) as NSObject? as AnyObject?
                instance.setValue(value, forKey: propertyName)
            }
        }
        return instance
    }
    
    private func parseDescription(description:String) -> (String, [String]) {
        let aliasStrategy = context.getAliasStrategy()
        
        let classNamePropertyNames = description.componentsSeparatedByString("#")
        
        let remoteClassName = classNamePropertyNames[0]
        let localClassName = aliasStrategy?.remoteToLocalClassName(remoteClassName) ?? remoteClassName
        
        if classNamePropertyNames.count == 1 || classNamePropertyNames[1].isEmpty {
            return (localClassName, [])
        }
        
        var propertyNames = classNamePropertyNames[1].componentsSeparatedByString(",").filter({
            (elt: String) -> Bool in return !elt.isEmpty
        })
        
        if aliasStrategy != nil {
            let aliases = aliasStrategy!.remoteToLocalProperties(localClassName)
            
            let max = (propertyNames.count - 1)
            for i in 0...max {
                propertyNames[i] = aliases[propertyNames[i]] ?? propertyNames[i]
            }
        }
        
        return (localClassName, propertyNames)
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
        if length0 >= 3 {
            value |= (Int(input.read()) << 24)
        }
        if length0 >= 2 {
            value |= (Int(input.read()) << 16)
        }
        if length0 >= 1 {
            value |= (Int(input.read()) << 8)
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
}