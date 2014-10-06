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
    
    private let stringCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeString(value as String)
    }
    
    private let intCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeInt(value as Int)
    }
    
    private let boolCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeBool(value as Bool)
    }
    
    private let doubleCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeDouble(value as Double)
    }
    
    private let uint8ArrayCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeUInt8Array(value as [UInt8])
    }
    
    private let nsDataCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeNSData(value as NSData)
    }
    
    private let nsDateCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeNSDate(value as NSDate)
    }
    
    private let anyClassCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeAnyClass(value as AnyClass)
    }
    
    private let nsObjectCoder:SpearalCoder = { (encoder:SpearalExtendedEncoder, value:Any) in
        encoder.writeNSObject(value as NSObject)
    }
    
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
            return anyClassCoder
        default:
            return nil
        }
    }
}


