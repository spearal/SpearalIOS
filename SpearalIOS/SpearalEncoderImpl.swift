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

class SpearalEncoderImpl : SpearalEncoder {
    
    let output:SpearalOutput
    
    required init(output: SpearalOutput) {
        self.output = output
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
        default:
            _stdlib_getTypeName(any!)
            println("???: \(reflect(any).valueType)")
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
            output.write(SpearalType.INTEGRAL.toRaw() | 7)
            output.write(0x80)
            output.write(0x00)
            output.write(0x00)
            output.write(0x00)
            output.write(0x00)
            output.write(0x00)
            output.write(0x00)
            output.write(0x00)
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
        
        let data = doubleToUInt8Pointer(&value)
        
        output.write(SpearalType.FLOATING.toRaw())
        output.write(data[7])
        output.write(data[6])
        output.write(data[5])
        output.write(data[4])
        output.write(data[3])
        output.write(data[2])
        output.write(data[1])
        output.write(data[0])
    }
    
    private func doubleToUInt8Pointer(doublePointer:UnsafePointer<Double>) -> UnsafePointer<UInt8> {
        return UnsafePointer<UInt8>(doublePointer)
    }
    
    func writeString(value:String) {
        writeStringData(SpearalType.STRING, value: value)
    }
    
    private func writeStringData(type:SpearalType, value:String) {
        if value.isEmpty {
            output.write(type.toRaw())
            output.write(0)
            return
        }
        
        var bytes = [UInt8]()
        bytes.extend(value.utf8)
        writeTypeUnsignedInt32(type, value: bytes.count)
        output.write(bytes)
    }
    
    private func writeTypeUnsignedInt32(type:SpearalType, value:Int) {
        let length0 = unsignedIntLength0(value)
        output.write(type.toRaw() | length0)
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