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


public protocol SpearalInput {
    
    func read() -> UInt8
    func read(count:Int) -> [UInt8]
}

public class SpearalNSDataInput: SpearalInput {
    
    private let data:NSData
    private let bytes:UnsafePointer<UInt8>
    private let length:Int
    private var index:Int = 0
    
    public init(data:NSData) {
        self.data = data
        self.bytes = UnsafePointer<UInt8>(data.bytes)
        self.length = data.length
    }
    
    public func read() -> UInt8 {
        assert(index < length, "EOF")
        
        return bytes[index++]
    }
    
    public func read(count:Int) -> [UInt8] {
        assert(index + count <= data.length, "EOF")
        
        var bytes = [UInt8](count: count, repeatedValue: 0)
        data.getBytes(&bytes, range: NSRange(location: index, length: count))
        index += count
        return bytes
    }
}

public protocol SpearalDecoder {
    
    func readAny() -> Any?
}