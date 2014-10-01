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

import UIKit
import XCTest

class InMemorySpearalOutput: SpearalOutput {
    
    let data = NSMutableData()
    
    func write(var byte:UInt8) {
        data.appendBytes(&byte, length: 1)
    }
    
    func write(var byte:UInt64) {
        data.appendBytes(&byte, length: 1)
    }
    
    func write(var byte:Int) {
        data.appendBytes(&byte, length: 1)
    }
    
    func write(var bytes:[UInt8]) {
        data.appendBytes(&bytes, length: bytes.count)
    }
}

class InMemorySpearalInput: SpearalInput {
    
    private let data:NSData
    private let bytes:UnsafePointer<UInt8>
    private let length:Int
    private var index:Int = 0
    
    init(data:NSData) {
        self.data = data
        self.bytes = UnsafePointer<UInt8>(data.bytes)
        self.length = data.length
    }
    
    func read() -> UInt8 {
        assert(index < length, "EOF")
        return bytes[index++]
    }
    
    func read(count:Int) -> [UInt8] {
        var bytes = [UInt8](count: count, repeatedValue: 0)
        data.getBytes(&bytes, range: NSRange(location: index, length: count))
        index += count
        return bytes
    }
}

class SpearalIOSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSpearalType() {
        for i in 0x00...0xff {
            if let type = SpearalType.valueOf(UInt8(i)) {

                /*
                switch type {
                case .NULL:
                    println("NULL");
                case .TRUE:
                    println("TRUE");
                case .FALSE:
                    println("FALSE");
                    
                case .INTEGRAL:
                    println("INTEGRAL");
                case .BIG_INTEGRAL:
                    println("BIG_INTEGRAL");
                    
                case .FLOATING:
                    println("FLOATING");
                case .BIG_FLOATING:
                    println("BIG_FLOATING");
                    
                case .STRING:
                    println("STRING");
                    
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
                */
                
                if i < 0x10 {
                    XCTAssertEqual(type.toRaw(), UInt8(i))
                }
                else {
                    XCTAssertEqual(type.toRaw(), UInt8(i & 0xf0))
                }
            }
            else {
                if i < 0x10 {
                    XCTAssertTrue(SpearalType.fromRaw(UInt8(i)) == nil)
                }
                else {
                    XCTAssertTrue(SpearalType.fromRaw(UInt8(i & 0xf0)) == nil)
                }
            }
        }
    }
    
    func testNil() {
        XCTAssertTrue(encodeDecode(nil, expectedSize: 1) == nil)
    }
    
    func testBool() {
        XCTAssertTrue(encodeDecode(true, expectedSize: 1) as Bool)
        XCTAssertFalse(encodeDecode(false, expectedSize: 1) as Bool)
    }
    
    func xtestInt() {
        XCTAssertEqual(encodeDecode(Int.min, expectedSize: 9) as Int, Int.min)
        XCTAssertEqual(encodeDecode(Int.min + 1, expectedSize: 9) as Int, Int.min + 1)
        
        XCTAssertEqual(encodeDecode(-0x0100000000000000, expectedSize: 9) as Int, -0x0100000000000000)
        XCTAssertEqual(encodeDecode(-0x00ffffffffffffff, expectedSize: 8) as Int, -0x00ffffffffffffff)
        
        XCTAssertEqual(encodeDecode(-0x0001000000000000, expectedSize: 8) as Int, -0x0001000000000000)
        XCTAssertEqual(encodeDecode(-0x0000ffffffffffff, expectedSize: 7) as Int, -0x0000ffffffffffff)
        
        XCTAssertEqual(encodeDecode(-0x0000010000000000, expectedSize: 7) as Int, -0x0000010000000000)
        XCTAssertEqual(encodeDecode(-0x000000ffffffffff, expectedSize: 6) as Int, -0x000000ffffffffff)
        
        XCTAssertEqual(encodeDecode(-0x0000000100000000, expectedSize: 6) as Int, -0x0000000100000000)
        XCTAssertEqual(encodeDecode(-0x00000000ffffffff, expectedSize: 5) as Int, -0x00000000ffffffff)
        
        XCTAssertEqual(encodeDecode(-0x0000000001000000, expectedSize: 5) as Int, -0x0000000001000000)
        XCTAssertEqual(encodeDecode(-0x0000000000ffffff, expectedSize: 4) as Int, -0x0000000000ffffff)
        
        XCTAssertEqual(encodeDecode(-0x0000000000010000, expectedSize: 4) as Int, -0x0000000000010000)
        for i in -0xffff...(-0x100) {
            XCTAssertEqual(encodeDecode(i, expectedSize: 3) as Int, i)
        }
        
        for i in -0xff...0xff {
            XCTAssertEqual(encodeDecode(i, expectedSize: 2) as Int, i)
        }
        
        for i in 0x100...0xffff {
            XCTAssertEqual(encodeDecode(i, expectedSize: 3) as Int, i)
        }
        XCTAssertEqual(encodeDecode(0x0000000000010000, expectedSize: 4) as Int, 0x0000000000010000)
        
        XCTAssertEqual(encodeDecode(0x0000000000ffffff, expectedSize: 4) as Int, 0x0000000000ffffff)
        XCTAssertEqual(encodeDecode(0x0000000001000000, expectedSize: 5) as Int, 0x0000000001000000)
        
        XCTAssertEqual(encodeDecode(0x00000000ffffffff, expectedSize: 5) as Int, 0x00000000ffffffff)
        XCTAssertEqual(encodeDecode(0x0000000100000000, expectedSize: 6) as Int, 0x0000000100000000)
        
        XCTAssertEqual(encodeDecode(0x000000ffffffffff, expectedSize: 6) as Int, 0x000000ffffffffff)
        XCTAssertEqual(encodeDecode(0x0000010000000000, expectedSize: 7) as Int, 0x0000010000000000)
        
        XCTAssertEqual(encodeDecode(0x0000ffffffffffff, expectedSize: 7) as Int, 0x0000ffffffffffff)
        XCTAssertEqual(encodeDecode(0x0001000000000000, expectedSize: 8) as Int, 0x0001000000000000)

        XCTAssertEqual(encodeDecode(0x00ffffffffffffff, expectedSize: 8) as Int, 0x00ffffffffffffff)
        XCTAssertEqual(encodeDecode(0x0100000000000000, expectedSize: 9) as Int, 0x0100000000000000)

        XCTAssertEqual(encodeDecode(Int.max - 1, expectedSize: 9) as Int, Int.max - 1)
        XCTAssertEqual(encodeDecode(Int.max, expectedSize: 9) as Int, Int.max)
    }
    
    func testDouble() {

        // Various double values
        
        XCTAssertEqual(encodeDecode(-Double.infinity, expectedSize: 9) as Double, -Double.infinity)
        XCTAssertEqual(encodeDecode(-1.7976931348623157e+308, expectedSize: 9) as Double, -1.7976931348623157e+308)
        XCTAssertEqual(encodeDecode(-M_PI, expectedSize: 9) as Double, -M_PI)
        XCTAssertEqual(encodeDecode(-M_E, expectedSize: 9) as Double, -M_E)
        XCTAssertEqual(encodeDecode(-4.9e-324, expectedSize: 9) as Double, -4.9e-324)
        XCTAssertEqual(encodeDecode(-0.0, expectedSize: 9) as Double, -0.0)
        XCTAssertTrue((encodeDecode(-0.0, expectedSize: 9) as Double).floatingPointClass == FloatingPointClassification.NegativeZero)
        XCTAssertTrue((encodeDecode(Double.NaN, expectedSize: 9) as Double).isNaN)
        XCTAssertEqual(encodeDecode(0.0, expectedSize: 2) as Int, 0)
        XCTAssertEqual(encodeDecode(4.9e-324, expectedSize: 9) as Double, 4.9e-324)
        XCTAssertEqual(encodeDecode(M_E, expectedSize: 9) as Double, M_E)
        XCTAssertEqual(encodeDecode(M_PI, expectedSize: 9) as Double, M_PI)
        XCTAssertEqual(encodeDecode(1.7976931348623157e+308, expectedSize: 9) as Double, 1.7976931348623157e+308)
        XCTAssertEqual(encodeDecode(Double.infinity, expectedSize: 9) as Double, Double.infinity)
        
        // Integral values encoded as Int
        
        for i in 0x01...0xFF {
            XCTAssertEqual(encodeDecode(Double(-i), expectedSize: 2) as Int, -i)
            XCTAssertEqual(encodeDecode(Double(i), expectedSize: 2) as Int, i)
        }
        
        var min = 0x100;
        var max = 0xFFFF;
        for i in 3...7 {
            XCTAssertEqual(encodeDecode(Double(-min), expectedSize: i) as Int, -min)
            XCTAssertEqual(encodeDecode(Double(min), expectedSize: i) as Int, min)
            
            XCTAssertEqual(encodeDecode(Double(-max), expectedSize: i) as Int, -max)
            XCTAssertEqual(encodeDecode(Double(max), expectedSize: i) as Int, max)
            
            min = (min << 8)
            max = (max << 8) | 0xff
        }
        
        XCTAssertEqual(encodeDecode(Double(-0x000fffffffffffff), expectedSize: 8) as Int, -0x000fffffffffffff)
        XCTAssertEqual(encodeDecode(Double(0x000fffffffffffff), expectedSize: 8) as Int, 0x000fffffffffffff)
        
        // Integral values as Double
        
        XCTAssertEqual(encodeDecode(Double(-0x0010000000000000), expectedSize: 9) as Double, Double(-0x0010000000000000))
        XCTAssertEqual(encodeDecode(Double(0x0010000000000000), expectedSize: 9) as Double, Double(0x0010000000000000))
        
        XCTAssertEqual(encodeDecode(Double(-0x00ffffffffffffff), expectedSize: 9) as Double, Double(-0x00ffffffffffffff))
        XCTAssertEqual(encodeDecode(Double(0x00ffffffffffffff), expectedSize: 9) as Double, Double(0x00ffffffffffffff))
        
        XCTAssertEqual(encodeDecode(Double(-0x0fffffffffffffff), expectedSize: 9) as Double, Double(-0x0fffffffffffffff))
        XCTAssertEqual(encodeDecode(Double(0x0fffffffffffffff), expectedSize: 9) as Double, Double(0x0fffffffffffffff))
        
        XCTAssertEqual(encodeDecode(Double(Int.min), expectedSize: 9) as Double, Double(Int.min))
        XCTAssertEqual(encodeDecode(Double(Int.max), expectedSize: 9) as Double, Double(Int.max))
        
        // Values with 4 decimals max, variable integral length
        
        XCTAssertEqual(encodeDecode(-0.1, expectedSize: 2) as Double, -0.1)
        XCTAssertEqual(encodeDecode( 0.1, expectedSize: 2) as Double, 0.1)
        
        XCTAssertEqual(encodeDecode(-0.2, expectedSize: 2) as Double, -0.2)
        XCTAssertEqual(encodeDecode( 0.2, expectedSize: 2) as Double, 0.2)
        
        XCTAssertEqual(encodeDecode(-0.255, expectedSize: 2) as Double, -0.255)
        XCTAssertEqual(encodeDecode( 0.255, expectedSize: 2) as Double, 0.255)
        
        XCTAssertEqual(encodeDecode(-0.256, expectedSize: 3) as Double, -0.256)
        XCTAssertEqual(encodeDecode( 0.256, expectedSize: 3) as Double, 0.256)
        
        XCTAssertEqual(encodeDecode(-0.3, expectedSize: 3) as Double, -0.3)
        XCTAssertEqual(encodeDecode( 0.3, expectedSize: 3) as Double, 0.3)
        
        XCTAssertEqual(encodeDecode(-0.4, expectedSize: 3) as Double, -0.4)
        XCTAssertEqual(encodeDecode( 0.4, expectedSize: 3) as Double, 0.4)
        
        XCTAssertEqual(encodeDecode(-0.9, expectedSize: 3) as Double, -0.9)
        XCTAssertEqual(encodeDecode( 0.9, expectedSize: 3) as Double, 0.9)
        
        XCTAssertEqual(encodeDecode(-0.999, expectedSize: 3) as Double, -0.999)
        XCTAssertEqual(encodeDecode( 0.999, expectedSize: 3) as Double, 0.999)
        
        XCTAssertEqual(encodeDecode(-4294967.295, expectedSize: 5) as Double, -4294967.295)
        XCTAssertEqual(encodeDecode( 4294967.295, expectedSize: 5) as Double, 4294967.295)
        
        // Values with 4 decimals max, plain double
        
        XCTAssertEqual(encodeDecode(-4294967.296, expectedSize: 9) as Double, -4294967.296)
        XCTAssertEqual(encodeDecode( 4294967.296, expectedSize: 9) as Double, 4294967.296)
    }
    
    func testString() {
        XCTAssertEqual(encodeDecode("", expectedSize: 2) as String, "")
        
        // All printable ascii characters
        
        var s = String()
        for i in 0x20...0x7e {
            s.append(UnicodeScalar(i))
        }
        
        XCTAssertEqual(encodeDecode(s, expectedSize: 97) as String, s)
        
        // All UTF-8 valid characters

        s = String()
        for i in 0...0xd7ff {
            s.append(UnicodeScalar(i))
        }
        for i in 0xe000...0xfffe {
            s.append(UnicodeScalar(i))
        }
        for i in 0x10000...0x1ffff { // should be ...0x10ffff (unsupported: EXC_BAD_INSTRUCTION)
            s.append(UnicodeScalar(i))
        }
        
        XCTAssertEqual(encodeDecode(s) as String, s)
        
        // Test references
        
        let s1 = String("abc")
        let s2 = String("abc")
        
        XCTAssertFalse(s1 as NSString === s2 as NSString)
        var (sc1, sc2) = encodeDecode(s1, any2: s2)
        XCTAssertEqual(sc1 as String, s1)
        XCTAssertEqual(sc2 as String, s2)
        XCTAssertTrue(sc1 as NSString === sc2 as NSString)
        
        XCTAssertTrue(s1 as NSString === s1 as NSString)
        (sc1, sc2) = encodeDecode(s1, any2: s1)
        XCTAssertEqual(sc1 as String, s1)
        XCTAssertEqual(sc2 as String, s1)
        XCTAssertTrue(sc1 as NSString === sc2 as NSString)
   }
    
    private func encodeDecode(any:Any?, expectedSize:Int = -1) -> Any? {
        let out = InMemorySpearalOutput()
        let encoder:SpearalEncoder = SpearalEncoderImpl(output: out)
        encoder.writeAny(any)
        
        if expectedSize != -1 {
            XCTAssertEqual(out.data.length, expectedSize)
        }
        
        let decoder:SpearalDecoder = SpearalDecoderImpl(input: InMemorySpearalInput(data: out.data))
        return decoder.readAny()
    }
    
    private func encodeDecode(any1:Any?, any2:Any?, expectedSize:Int = -1) -> (Any?, Any?) {
        let out = InMemorySpearalOutput()
        let encoder:SpearalEncoder = SpearalEncoderImpl(output: out)
        encoder.writeAny(any1)
        encoder.writeAny(any2)
        
        if expectedSize != -1 {
            XCTAssertEqual(out.data.length, expectedSize)
        }
        
        let decoder:SpearalDecoder = SpearalDecoderImpl(input: InMemorySpearalInput(data: out.data))
        return (decoder.readAny(), decoder.readAny())
    }
}
