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

class SpearalDecoderImpl: SpearalDecoder {
    
    let input: SpearalInput
    
    required init(input: SpearalInput) {
        self.input = input
    }
    
    func readAny() -> Any? {
        let parameterizedType = input.read()
        
        if let type = SpearalType.valueOf(parameterizedType) {
            switch type {
            case .NULL:
                return nil
            case .TRUE:
                return true
            case .FALSE:
                return false

            case .INTEGRAL:
                return readIntegral(parameterizedType)
            case .BIG_INTEGRAL:
                println("BIG_INTEGRAL");
                
            case .FLOATING:
                return readFloating(parameterizedType)
            case .BIG_FLOATING:
                println("BIG_FLOATING");
                
            case .STRING:
                return readString(parameterizedType)
                
            case .BYTE_ARRAY:
                println("BYTE_ARRAY");
                
            case .DATE_TIME:
                println("DATE_TIME");
                
            case .COLLECTION:
                println("COLLECTION");
            case .MAP:
                println("MAP");
                
            case .ENUM:
                println("ENUM");
            case .CLASS:
                println("CLASS");
            case .BEAN:
                println("BEAN");
            }
        }

        return "???"
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
        let count = readIndexOrLength(parameterizedType)
        if count == 0 {
            return ""
        }
        
        let utf8:[UInt8] = input.read(count)
        return NSString(bytes: utf8, length: utf8.count, encoding: NSUTF8StringEncoding) as String
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
}