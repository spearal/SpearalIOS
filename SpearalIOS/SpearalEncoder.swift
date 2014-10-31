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

public protocol SpearalOutput {
    
    func write(byte:UInt8)
    func write(byte:UInt64)
    func write(byte:Int)
    func write(bytes:[UInt8])
}

public protocol SpearalEncoder {
    
    func writeAny(any:Any?)
}

public protocol SpearalExtendedEncoder: SpearalEncoder {
    
    func writeBool(value:Bool)
    func writeInt(value:Int)
    func writeDouble(value:Double)
    func writeString(value:String)
    func writeUInt8Array(value:[UInt8])
    func writeNSData(value:NSData)
    func writeNSArray(value:NSArray)
    func writeNSDictionary(value:NSDictionary)
    func writeNSDate(value:NSDate)
    func writeEnum(className:String, valueName:String)
    func writeAnyClass(value:AnyClass)
    func writeNSObject(value:NSObject)
}