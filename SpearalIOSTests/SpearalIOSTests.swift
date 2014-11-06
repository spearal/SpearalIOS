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
                if i < 0x10 {
                    XCTAssertEqual(type.rawValue, UInt8(i))
                }
                else {
                    XCTAssertEqual(type.rawValue, UInt8(i & 0xf0))
                }
            }
            else {
                if i < 0x10 {
                    XCTAssertTrue(SpearalType(rawValue: UInt8(i)) == nil)
                }
                else {
                    XCTAssertTrue(SpearalType(rawValue: UInt8(i & 0xf0)) == nil)
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
    
    func testInt() {
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
        XCTAssertEqual(encodeDecode(-0x000000000000ffff, expectedSize: 3) as Int, -0x000000000000ffff)


        XCTAssertEqual(encodeDecode(-0x0000000000000100, expectedSize: 3) as Int, -0x0000000000000100)
        for i in -0xff...0xff {
            XCTAssertEqual(encodeDecode(i, expectedSize: 2) as Int, i)
        }
        XCTAssertEqual(encodeDecode(0x0000000000000100, expectedSize: 3) as Int, 0x0000000000000100)

        XCTAssertEqual(encodeDecode(0x000000000000ffff, expectedSize: 3) as Int, 0x000000000000ffff)
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
    }
    
    func testByteArray() {
        XCTAssertEqual(encodeDecode([UInt8](), expectedSize: 2) as [UInt8], [UInt8]())
        
        var b:[UInt8] = [0]
        for i in 0x00...0xff {
            b[0] = UInt8(i)
            XCTAssertEqual(encodeDecode(b, expectedSize: 3) as [UInt8], b)
        }
        
        b = []
        for i in 0x00...0xff {
            b.append(UInt8(i))
        }
        XCTAssertEqual(encodeDecode(b, expectedSize: b.count + 3) as [UInt8], b)
        
        b = [0, 1, 2]
        let data = NSData(bytes: b, length: b.count)
        XCTAssertEqual(encodeDecode(data, expectedSize: 5) as [UInt8], b)
        
        // Test references
        
        let b1:[UInt8] = [0, 1, 2]
        let b2:[UInt8] = [0, 1, 2]
        
        XCTAssertTrue(unsafeBitCast(b1, UnsafePointer<Void>.self) == unsafeBitCast(b1, UnsafePointer<Void>.self))
        XCTAssertTrue(unsafeBitCast(b1, UnsafePointer<Void>.self) != unsafeBitCast(b2, UnsafePointer<Void>.self))

        var (bc1, bc2) = encodeDecode(b1, any2: b2)
        XCTAssertTrue(unsafeBitCast(bc1 as [UInt8], UnsafePointer<Void>.self) != unsafeBitCast(bc2 as [UInt8], UnsafePointer<Void>.self))
        XCTAssertEqual(bc1 as [UInt8], b1)
        XCTAssertEqual(bc2 as [UInt8], b2)
        
        (bc1, bc2) = encodeDecode(b1, any2: b1)
        XCTAssertTrue(unsafeBitCast(bc1 as [UInt8], UnsafePointer<Void>.self) == unsafeBitCast(bc2 as [UInt8], UnsafePointer<Void>.self))
        XCTAssertEqual(bc1 as [UInt8], b1)
        XCTAssertEqual(bc2 as [UInt8], b1)
    }
    
    func testCollection() {
        let intArray:[Int] = [0, 1, 2, 3]
        var copy = encodeDecode(intArray) as NSArray
        
        XCTAssertEqual(intArray, copy)
        
        let compositeArray:[AnyObject] = [0, "1", NSDate()]
        copy = encodeDecode(compositeArray) as NSArray
        
        XCTAssertEqual(compositeArray, copy)
    }
    
    func testMap() {
        let intMap:[Int: Int] = [0: 1, 2: 3]
        var copy = encodeDecode(intMap) as NSDictionary
        
        XCTAssertEqual(intMap, copy)
        
        let stringIntMap:[String: Int] = ["0": 1, "2": 3]
        copy = encodeDecode(stringIntMap) as NSDictionary
        
        XCTAssertEqual(stringIntMap, copy)
        
        let compositeMap:[NSObject: AnyObject] = ["0": 1, 2: NSDate()]
        copy = encodeDecode(stringIntMap) as NSDictionary
        
        XCTAssertEqual(stringIntMap, copy)
    }
    
    func testDate() {
        var date = NSDate()
        XCTAssertEqual(encodeDecode(date) as NSDate, date)
        
        let format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss SSS"

        date = format.dateFromString("1999-12-03 23:45:59 999")!
        XCTAssertEqual(encodeDecode(date) as NSDate, date)
    }
    
    func testEnum() {
        
        class SalutationCoderProvider: SpearalCoderProvider {
            
            class SalutationCoder: SpearalCoder {
                func encode(encoder:SpearalExtendedEncoder, value:Any) {
                    encoder.writeEnum("Salutation", valueName: (value as Salutation).name)
                }
            }
            
            private let salutationCoder:SpearalCoder = SalutationCoder()
            
            func coder(any:Any) -> SpearalCoder? {
                if any is Salutation {
                    return salutationCoder
                }
                return nil
            }
        }
        
        class SalutationConverterProvider: SpearalConverterProvider {

            class SalutationConverter: SpearalConverter {
                func convert(value:Any?, context:SpearalConverterContext) -> Any? {
                    return Salutation((value as SpearalEnum).valueName)
                }
            }
            
            private let salutationConverter = SalutationConverter()

            func converter(any:Any?) -> SpearalConverter? {
                if (any as? SpearalEnum)?.className == "Salutation" {
                    return salutationConverter
                }
                return nil
            }
        }
        
        let encoderFactory = DefaultSpearalFactory()
        encoderFactory.context.configure(SalutationCoderProvider(), append: false)
        
        let salutation = Salutation.MR
        
        let out = SpearalNSDataOutput()
        let encoder:SpearalEncoder = encoderFactory.newEncoder(out)
        encoder.writeAny(salutation)
        
        let decoderFactory = DefaultSpearalFactory()
        decoderFactory.context.configure(SalutationConverterProvider(), append: false)
        
        let decoder:SpearalDecoder = decoderFactory.newDecoder(SpearalNSDataInput(data: out.data))
        let value = decoder.readAny() as Salutation
        
        XCTAssertTrue(salutation == value)
    }
    
    func testBigIntegral() {
        
        class MyBigIntegral {
            
            let value:String
            
            init(_ value:String) {
                self.value = value
            }
        }
        
        class MyBigIntegralCoderProvider: SpearalCoderProvider {
            
            class MyBigIntegralCoder: SpearalCoder {
                func encode(encoder:SpearalExtendedEncoder, value:Any) {
                    encoder.writeBigIntegral((value as MyBigIntegral).value)
                }
            }
            
            private let myBigIntegralCoder:SpearalCoder = MyBigIntegralCoder()
            
            func coder(any:Any) -> SpearalCoder? {
                if any is MyBigIntegral {
                    return myBigIntegralCoder
                }
                return nil
            }
        }
        
        let encoderFactory = DefaultSpearalFactory()
        encoderFactory.context.configure(MyBigIntegralCoderProvider(), append: false)
        
        let bigIntegral = MyBigIntegral("13712527002344000023401203400000")
        
        let out = SpearalNSDataOutput()
        let encoder:SpearalEncoder = encoderFactory.newEncoder(out)
        encoder.writeAny(bigIntegral)
        
        let decoderFactory = DefaultSpearalFactory()
        let decoder:SpearalDecoder = decoderFactory.newDecoder(SpearalNSDataInput(data: out.data))
        let value = decoder.readAny() as SpearalBigIntegral
        
        XCTAssertEqual("137125270023440000234012034E5", value.representation)
    }
    
    func testBigFloating() {
        
        class MyBigFloating {
            
            let value:String
            
            init(_ value:String) {
                self.value = value
            }
        }
        
        class MyBigFloatingCoderProvider: SpearalCoderProvider {
            
            class MyBigFloatingCoder: SpearalCoder {
                func encode(encoder:SpearalExtendedEncoder, value:Any) {
                    encoder.writeBigFloating((value as MyBigFloating).value)
                }
            }
            
            private let myBigFloatingCoder:SpearalCoder = MyBigFloatingCoder()
            
            func coder(any:Any) -> SpearalCoder? {
                if any is MyBigFloating {
                    return myBigFloatingCoder
                }
                return nil
            }
        }
        
        let encoderFactory = DefaultSpearalFactory()
        encoderFactory.context.configure(MyBigFloatingCoderProvider(), append: false)
        
        let bigIntegral = MyBigFloating("1234567890.948576")
        
        let out = SpearalNSDataOutput()
        let encoder:SpearalEncoder = encoderFactory.newEncoder(out)
        encoder.writeAny(bigIntegral)
        
        let decoderFactory = DefaultSpearalFactory()
        let decoder:SpearalDecoder = decoderFactory.newDecoder(SpearalNSDataInput(data: out.data))
        let value = decoder.readAny() as SpearalBigFloating
        
        XCTAssertEqual("1234567890.948576", value.representation)
    }
    
    func testBean() {
        let aliasStrategy = BasicSpearalAliasStrategy(localToRemoteClassNames: [
            "Person": "com.cortez.samples.javaee7angular.data.Person"
        ])
        aliasStrategy.setPropertiesAlias("Person", localToRemoteProperties: [
            "description_" : "description"
        ])
        
        var person = Person()
        
        XCTAssertFalse(person._$isDefined("firstName"))
        XCTAssertFalse(person._$isDefined("lastName"))
        XCTAssertFalse(person._$isDefined("description_"))
        XCTAssertFalse(person._$isDefined("age"))
        
        var personCopy = encodeDecode(person as NSObject as Any, expectedSize: -1, aliasStrategy: aliasStrategy) as Person
        
        XCTAssertFalse(personCopy._$isDefined("firstName"))
        XCTAssertFalse(personCopy._$isDefined("lastName"))
        XCTAssertFalse(personCopy._$isDefined("description_"))
        XCTAssertFalse(personCopy._$isDefined("age"))

        person = Person(firstName: "John", lastName: "Doo", description: "Good fellow", age: 12)

        XCTAssertTrue(person._$isDefined("firstName"))
        XCTAssertTrue(person._$isDefined("lastName"))
        XCTAssertTrue(person._$isDefined("description_"))
        XCTAssertTrue(person._$isDefined("age"))
        
        personCopy = encodeDecode(person as NSObject as Any, expectedSize: -1, aliasStrategy: aliasStrategy) as Person

        XCTAssertTrue(personCopy._$isDefined("firstName"))
        XCTAssertTrue(personCopy._$isDefined("lastName"))
        XCTAssertTrue(personCopy._$isDefined("description_"))
        XCTAssertTrue(personCopy._$isDefined("age"))
        
        XCTAssertEqual(personCopy.firstName!, person.firstName!)
        XCTAssertEqual(personCopy.lastName!, person.lastName!)
        XCTAssertEqual(personCopy.description_!, personCopy.description_!)
        XCTAssertEqual(personCopy.age!, person.age!)
        
        person = Person()
        
        person.firstName = nil
        
        XCTAssertTrue(person._$isDefined("firstName"))
        XCTAssertFalse(person._$isDefined("lastName"))
        XCTAssertFalse(person._$isDefined("description_"))
        XCTAssertFalse(person._$isDefined("age"))

        XCTAssertNil(person.firstName)
        
        personCopy = encodeDecode(person as NSObject as Any, expectedSize: -1, aliasStrategy: aliasStrategy) as Person
        
        XCTAssertTrue(personCopy._$isDefined("firstName"))
        XCTAssertFalse(personCopy._$isDefined("lastName"))
        XCTAssertFalse(personCopy._$isDefined("description_"))
        XCTAssertFalse(personCopy._$isDefined("age"))
        
        XCTAssertNil(personCopy.firstName)
    }
    
    private func encodeDecode(any:Any?, expectedSize:Int = -1, aliasStrategy:SpearalAliasStrategy? = nil) -> Any? {
        let encoderFactory = DefaultSpearalFactory()
        if aliasStrategy != nil {
            encoderFactory.context.configure(aliasStrategy!)
        }
        
        let decoderFactory = DefaultSpearalFactory()
        if aliasStrategy != nil {
            decoderFactory.context.configure(aliasStrategy!)
        }
        
        let out = SpearalNSDataOutput()
        let encoder:SpearalEncoder = encoderFactory.newEncoder(out)
        encoder.writeAny(any)
        
        if expectedSize != -1 {
            XCTAssertEqual(out.data.length, expectedSize)
        }

        let decoder:SpearalDecoder = decoderFactory.newDecoder(SpearalNSDataInput(data: out.data))
        return decoder.readAny()
    }
    
    private func encodeDecode(any:Any?, expectedSize:Int = -1, encoderFactory:SpearalFactory, decoderFactory:SpearalFactory) -> Any? {
        let out = SpearalNSDataOutput()
        let encoder:SpearalEncoder = encoderFactory.newEncoder(out)
        encoder.writeAny(any)
        
        if expectedSize != -1 {
            XCTAssertEqual(out.data.length, expectedSize)
        }
        
        let decoder:SpearalDecoder = decoderFactory.newDecoder(SpearalNSDataInput(data: out.data))
        return decoder.readAny()
    }
    
    private func encodeDecode(any1:Any?, any2:Any?, expectedSize:Int = -1) -> (Any?, Any?) {
        let out = SpearalNSDataOutput()
        let encoder:SpearalEncoder = DefaultSpearalFactory().newEncoder(out)
        encoder.writeAny(any1)
        encoder.writeAny(any2)
        
        if expectedSize != -1 {
            XCTAssertEqual(out.data.length, expectedSize)
        }
        
        let decoder:SpearalDecoder = DefaultSpearalFactory().newDecoder(SpearalNSDataInput(data: out.data))
        return (decoder.readAny(), decoder.readAny())
    }
}
