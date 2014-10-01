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

class SpearalEncoderImpl : SpearalEncoder {
    
    let output:SpearalOutput
    private let sharedStrings:StringIndexMap
    
    required init(output: SpearalOutput) {
        self.output = output
        self.sharedStrings = StringIndexMap()
    }
    
    func writeAny(any:Any?) {
        switch any {
        case nil:
            writeNil()
        case let value as Bool:
            writeBool(value)
        case let value as Int:
            writeInt(value)
        case let value as Double:
            writeDouble(value)
        case let value as String:
            writeString(value)
        case let value as [UInt8]:
            writeByteArray(value)
        default:
            println("???: \(reflect(any).valueType) / \(_stdlib_getTypeName(any!))")
        }
    }
    
    func writeNil() {
        output.write(SpearalType.NULL.toRaw())
    }
    
    func writeBool(value:Bool) {
        output.write((value ? SpearalType.TRUE : SpearalType.FALSE).toRaw())
    }
    
    func writeInt(var value:Int) {
        
        if value == Int.min {
            output.write([SpearalType.INTEGRAL.toRaw() | 7, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
            return
        }
        
        var inverse:UInt8 = 0
        if value < 0 {
            inverse = 0x08
            value = -value
        }
        let length0 = unsignedIntLength0(value)
        
        output.write(SpearalType.INTEGRAL.toRaw() | inverse | length0)
        
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
    
    func writeDouble(var value:Double) {
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
                            output.write(SpearalType.FLOATING.toRaw() | 0x08 | inverse | length0)
                            writeUnsignedInt32Value(intValue, length0: length0)
                            return
                        }
                    }
                }
            }
        }
        
        let doubleToLongBits:UInt64 = unsafeBitCast(value, UInt64.self)
        
        output.write(SpearalType.FLOATING.toRaw())
        output.write(doubleToLongBits >> 56)
        output.write(doubleToLongBits >> 48)
        output.write(doubleToLongBits >> 40)
        output.write(doubleToLongBits >> 32)
        output.write(doubleToLongBits >> 24)
        output.write(doubleToLongBits >> 16)
        output.write(doubleToLongBits >> 8)
        output.write(doubleToLongBits)
    }
    
    func writeString(value:String) {
        writeStringData(SpearalType.STRING, value: value)
    }
    
    func writeByteArray(value:[UInt8]) {
        writeTypeUnsignedInt32(SpearalType.BYTE_ARRAY.toRaw(), value: value.count)
        output.write(value)
    }
    
    private func writeStringData(type:SpearalType, value:String) {
        if value.isEmpty {
            output.write(type.toRaw())
            output.write(0)
            return
        }
        
        if !putAndWriteStringReference(type, s: value) {
            var bytes = [UInt8]()
            bytes.extend(value.utf8)
            writeTypeUnsignedInt32(type.toRaw(), value: bytes.count)
            output.write(bytes)
        }
    }
    
    private func putAndWriteStringReference(type:SpearalType, s:String) -> Bool {
        let index = sharedStrings.putIfAbsent(s)
        if index != -1 {
            writeTypeUnsignedInt32(type.toRaw() | 0x04, value: index)
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
        output.write(UInt8(value >> 56))
        //output.write((value >> 56) as? UInt8)
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