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

class SpearalStandardCoderProvider: SpearalCoderProvider {
    
    class StringCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeString(value as String)
    }}
    
    class IntCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeInt(value as Int)
    }}
    
    class BoolCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeBool(value as Bool)
    }}
    
    class DoubleCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeDouble(value as Double)
    }}
    
    class UInt8ArrayCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeUInt8Array(value as [UInt8])
    }}
    
    class NSDataCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeNSData(value as NSData)
    }}
    
    class NSDateCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeNSDate(value as NSDate)
    }}
    
    class AnyClassCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeAnyClass(value as AnyClass)
    }}
    
    class NSObjectCoder: SpearalCoder { func encode(encoder:SpearalExtendedEncoder, value:Any) {
        encoder.writeNSObject(value as NSObject)
    }}
    
    private let stringCoder:SpearalCoder = StringCoder()
    private let intCoder:SpearalCoder = IntCoder()
    private let boolCoder:SpearalCoder = BoolCoder()
    private let doubleCoder:SpearalCoder = DoubleCoder()
    private let uint8ArrayCoder:SpearalCoder = UInt8ArrayCoder()
    private let nsDataCoder:SpearalCoder = NSDataCoder()
    private let nsDateCoder:SpearalCoder = NSDateCoder()
    private let anyClassCoder:SpearalCoder = AnyClassCoder()
    private let nsObjectCoder:SpearalCoder = NSObjectCoder()
    
    func coder(any:Any) -> SpearalCoder? {
        switch any {
        case let value as String:
            return stringCoder
        case let value as Int:
            return intCoder
        case let value as Bool:
            return boolCoder
        case let value as Double:
            return doubleCoder
        case let value as [UInt8]:
            return uint8ArrayCoder
        case let value as NSData:
            return nsDataCoder
        case let value as NSDate:
            return nsDateCoder
        case let value as AnyClass:
            return anyClassCoder
        case let value as NSObject:
            return nsObjectCoder
        default:
            return nil
        }
    }
}


