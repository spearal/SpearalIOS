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

private class StringIndexMap {
    
    private var references:Dictionary<String, Int> = Dictionary<String, Int>()
    
    func putIfAbsent(item:String) -> Int {
        if let index = references[item] {
            return index
        }
        references[item] = references.count
        return -1
    }
}

private class IdentityIndexMap {
    
    private var references:Dictionary<UnsafePointer<Void>, Int> = Dictionary<UnsafePointer<Void>, Int>()
    
    func putIfAbsent(p:UnsafePointer<Void>) -> Int {
        if let index = references[p] {
            return index
        }
        references[p] = references.count
        return -1;
    }
}

class SpearalEncoderImpl : SpearalExtendedEncoder {
    
    let context:SpearalContext
    let filter:SpearalPropertyFilter
    let output:SpearalOutput

    private let sharedStrings:StringIndexMap
    private let sharedObjects:IdentityIndexMap
    
    private let calendar:NSCalendar
    
    convenience init(context:SpearalContext, output: SpearalOutput) {
        self.init(context: context, filter: SpearalPropertyFilterImpl(context), output: output)
    }
    
    init(context:SpearalContext, filter:SpearalPropertyFilter, output: SpearalOutput) {
        self.context = context
        self.filter = filter
        self.output = output
        
        self.sharedStrings = StringIndexMap()
        self.sharedObjects = IdentityIndexMap()
        
        self.calendar = NSCalendar(identifier: NSGregorianCalendar)!
    }
    
    func writeAny(any:Any?) {
        if any == nil {
            writeNil()
        }
        else if let coder = context.getCoderFor(any!) {
            coder.encode(self, value: any!)
        }
        else {
            println("No coder for value: \(any)")
        }
    }
    
    func writeNil() {
        output.write(SpearalType.NULL.rawValue)
    }
    
    func writeBool(value:Bool) {
        output.write((value ? SpearalType.TRUE : SpearalType.FALSE).rawValue)
    }
    
    func writeInt(var value:Int) {
        
        if value == Int.min {
            output.write([SpearalType.INTEGRAL.rawValue | 7, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
            return
        }
        
        var inverse:UInt8 = 0
        if value < 0 {
            inverse = 0x08
            value = -value
        }
        let length0 = unsignedIntLength0(value)
        
        output.write(SpearalType.INTEGRAL.rawValue | inverse | length0)
        
        if length0 >= 7 {
            output.write(value >> 56)
        }
        if length0 >= 6 {
            output.write(value >> 48)
        }
        if length0 >= 5 {
            output.write(value >> 40)
        }
        if length0 >= 4 {
            output.write(value >> 32)
        }
        if length0 >= 3 {
            output.write(value >> 24)
        }
        if length0 >= 2 {
            output.write(value >> 16)
        }
        if length0 >= 1 {
            output.write(value >> 8)
        }
        output.write(value)
    }
    
    func writeDouble(value:Double) {
        // value != NaN, +/- Infinity and -0.0
        if value.isFinite && value.floatingPointClass != FloatingPointClassification.NegativeZero &&
           value >= Double(Int.min) && value <= Double(Int.max) {
            
            var intValue:Int = Int(value)
            
            if value == Double(intValue) {
                if intValue >= -0x000fffffffffffff && intValue <= 0x000fffffffffffff {
                    writeInt(intValue)
                    return
                }
            }
            else {
                let valueBy1000 = value * 1000.0
                
                if valueBy1000 >= Double(Int.min) && valueBy1000 <= Double(Int.max) {
                    
                    intValue = Int(valueBy1000)
                    
                    if value == (Double(intValue) / 1000.0) || value == (Double(intValue += (intValue < 0 ? -1 : 1)) / 1000.0) {
                        if intValue >= -0xffffffff && intValue <= 0xffffffff {
                            var inverse:UInt8 = 0
                            if intValue < 0 {
                                inverse = 0x04
                                intValue = -intValue
                            }
                            let length0 = unsignedIntLength0(intValue)
                            output.write(SpearalType.FLOATING.rawValue | 0x08 | inverse | length0)
                            writeUnsignedInt32Value(intValue, length0: length0)
                            return
                        }
                    }
                }
            }
        }
        
        output.write(SpearalType.FLOATING.rawValue)
        writeUInt64(unsafeBitCast(value, UInt64.self))
    }
    
    func writeString(value:String) {
        writeStringData(SpearalType.STRING, value: value)
    }
    
    func writeUInt8Array(value:[UInt8]) {
        if !putAndWriteObjectReference(SpearalType.BYTE_ARRAY, id: unsafeBitCast(value, UnsafePointer<Void>.self)) {
            writeTypeUnsignedInt32(SpearalType.BYTE_ARRAY.rawValue, value: value.count)
            output.write(value)
        }
    }
    
    func writeNSData(value:NSData) {
        if !putAndWriteObjectReference(SpearalType.BYTE_ARRAY, id: unsafeAddressOf(value)) {
            var bytes = [UInt8](count: value.length, repeatedValue: 0)
            value.getBytes(&bytes, length: value.length)
            writeTypeUnsignedInt32(SpearalType.BYTE_ARRAY.rawValue, value: bytes.count)
            output.write(bytes)
        }
    }
    
    func writeNSArray(value:NSArray) {
        if !putAndWriteObjectReference(SpearalType.COLLECTION, id: unsafeAddressOf(value)) {
            writeTypeUnsignedInt32(SpearalType.COLLECTION.rawValue, value: value.count)
            for elt in value {
                writeAny(SpearalEncoderImpl.anyObjectToAny(elt))
            }
        }
    }
    
    func writeNSDictionary(value:NSDictionary) {
        if !putAndWriteObjectReference(SpearalType.MAP, id: unsafeAddressOf(value)) {
            writeTypeUnsignedInt32(SpearalType.MAP.rawValue, value: value.count)
            for (key, val) in value {
                writeAny(SpearalEncoderImpl.anyObjectToAny(key))
                writeAny(SpearalEncoderImpl.anyObjectToAny(val))
            }
        }
    }
    
    func writeNSDate(value:NSDate) {
        let components = calendar.components(
            .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay |
            .CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond | .CalendarUnitNanosecond, fromDate: value)
        
        var nanoseconds:Int = components.nanosecond
        
        var parameters:UInt8 = 0x0c
        if nanoseconds != 0 {
            if nanoseconds % 1000 == 0 {
                if (nanoseconds % 1000000 == 0) {
                    nanoseconds /= 1000000;
                    parameters |= 0x03;
                }
                else {
                    nanoseconds /= 1000;
                    parameters |= 0x02;
                }
            }
            else {
                parameters |= 0x01;
            }
        }
        
        output.write(SpearalType.DATE_TIME.rawValue | parameters)

        var inverse:UInt8 = 0x00;
        var year = components.year - 2000;
        if year < 0 {
            inverse = 0x80;
            year = -year;
        }
        var length0:UInt8 = unsignedIntLength0(year);
        output.write(inverse | (length0 << 4) | UInt8(components.month))
        output.write(UInt8(components.day))
        writeUnsignedInt32Value(year, length0: length0);
        
        if nanoseconds == 0 {
            output.write(UInt8(components.hour))
            output.write(UInt8(components.minute))
            output.write(UInt8(components.second))
        }
        else {
            length0 = unsignedIntLength0(nanoseconds);
            output.write((length0 << 5) | UInt8(components.hour))
            output.write(UInt8(components.minute))
            output.write(UInt8(components.second))
            writeUnsignedInt32Value(nanoseconds, length0: length0);
        }
    }
    
    func writeAnyClass(value:AnyClass) {
        let name = context.getIntrospector()!.classNameOfAnyClass(value)
        writeStringData(SpearalType.CLASS, value: name)
    }
    
    func writeNSObject(value:NSObject) {
        if !putAndWriteObjectReference(SpearalType.BEAN, id: unsafeAddressOf(value)) {
            let type = value.dynamicType

            var properties = filter.get(type)
            if let partial  = value as? SpearalPartialable {
                let definedProperties = partial._$definedPropertyNames
                properties = properties.filter({ (elt:String) -> Bool in
                    return contains(definedProperties, elt)
                })
            }
            
            let description:String = createDescription(type, propertyNames: properties)
            
            writeStringData(SpearalType.BEAN, value: description)
            
            for property in properties {
                let anyObject:AnyObject? = value.valueForKey(property)
                writeAny(SpearalEncoderImpl.anyObjectToAny(anyObject))
            }
        }
    }
    
    private class func anyObjectToAny(anyObject:AnyObject?) -> Any? {
        return anyObject as NSObject? as Any?
    }
    
    private func createDescription(type:AnyClass, propertyNames:[String]) -> String {
        let aliasStrategy = self.context.getAliasStrategy()
        let localClassName = self.context.getIntrospector()?.classNameOfAnyClass(type) ?? ""
        let remoteClassName = aliasStrategy?.localToRemoteClassName(localClassName) ?? localClassName
        let propertyNameAliases = aliasStrategy?.localToRemoteProperties(localClassName) ?? [String: String]()
        
        if propertyNameAliases.isEmpty {
            return remoteClassName + "#" + ",".join(propertyNames)
        }

        let remotePropertyNames = propertyNames.map({ (localPropertyName:String) -> String in
            return propertyNameAliases[localPropertyName] ?? localPropertyName
        })
        return remoteClassName + "#" + ",".join(remotePropertyNames)
    }
    
    private func writeStringData(type:SpearalType, value:String) {
        if value.isEmpty {
            output.write(type.rawValue)
            output.write(0)
            return
        }
        
        if !putAndWriteStringReference(type, s: value) {
            var bytes = [UInt8]()
            bytes.extend(value.utf8)
            writeTypeUnsignedInt32(type.rawValue, value: bytes.count)
            output.write(bytes)
        }
    }
    
    private func putAndWriteStringReference(type:SpearalType, s:String) -> Bool {
        let index = sharedStrings.putIfAbsent(s)
        if index != -1 {
            writeTypeUnsignedInt32(type.rawValue | 0x04, value: index)
            return true
        }
        return false
    }
    
    private func putAndWriteObjectReference(type:SpearalType, id:UnsafePointer<Void>) -> Bool {
        let index = sharedObjects.putIfAbsent(id)
        if index != -1 {
            writeTypeUnsignedInt32(type.rawValue | 0x08, value: index)
            return true
        }
        return false
    }
    
    
    private func writeTypeUnsignedInt32(type:UInt8, value:Int) {
        let length0 = unsignedIntLength0(value)
        output.write(type | length0)
        writeUnsignedInt32Value(value, length0: length0)
    }
    
    private func writeUnsignedInt32Value(value:Int, length0:UInt8) {
        if length0 >= 3 {
            output.write(value >> 24)
        }
        if length0 >= 2 {
            output.write(value >> 16)
        }
        if length0 >= 1 {
            output.write(value >> 8)
        }
        output.write(value)
    }
    
    private func writeUInt64(value:UInt64) {
        output.write(value >> 56)
        output.write(value >> 48)
        output.write(value >> 40)
        output.write(value >> 32)
        output.write(value >> 24)
        output.write(value >> 16)
        output.write(value >> 8)
        output.write(value)
    }
    
    private func unsignedIntLength0(value:Int) -> UInt8 {
        if value <= 0xffffffff {
            if value <= 0xffff {
                return (value <= 0xff ? 0 : 1)
            }
            return (value <= 0xffffff ? 2 : 3)
        }
        if value <= 0xffffffffffff {
            return (value <= 0xffffffffff ? 4 : 5)
        }
        return (value <= 0xffffffffffffff ? 6 : 7);
    }
}