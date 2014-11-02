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

public protocol SpearalConfigurable {
}

public protocol SpearalRepeatable: SpearalConfigurable {
}

public protocol SpearalCoder {
    
    func encode(encoder:SpearalExtendedEncoder, value:Any)
}
public protocol SpearalCoderProvider: SpearalRepeatable {
    
    func coder(any:Any) -> SpearalCoder?
}

@objc(SpearalConverterContext)
public protocol SpearalConverterContext {
    
}

@objc(SpearalConverterContextRoot)
public protocol SpearalConverterContextRoot: SpearalConverterContext {
}

@objc(SpearalConverterContextObject)
public protocol SpearalConverterContextObject: SpearalConverterContext {
    
    var type:AnyClass { get }
    var property:String { get }
}

@objc(SpearalConverterContextCollection)
public protocol SpearalConverterContextCollection: SpearalConverterContext {
    
    var index:Int { get }
}

@objc(SpearalConverterContextMapKey)
public protocol SpearalConverterContextMapKey: SpearalConverterContext {
}

@objc(SpearalConverterContextMapValue)
public protocol SpearalConverterContextMapValue: SpearalConverterContext {
    
    var key:NSObject { get }
}

public protocol SpearalConverter {
    
    func convert(value:Any?, context:SpearalConverterContext) -> Any?
}
public protocol SpearalConverterProvider: SpearalRepeatable {
    
    func converter(any:Any?) -> SpearalConverter?
}

public typealias SpearalClassNameAliaser = (String) -> String
public protocol SpearalAliasStrategy {
    
    init(localToRemoteClassNames:[String: String])
    init(localToRemoteAliaser:SpearalClassNameAliaser, remoteToLocalAliaser:SpearalClassNameAliaser)
    
    func setPropertiesAlias(localClassName:String, localToRemoteProperties:[String: String])

    func localToRemoteClassName(localClassName:String) -> String
    func remoteToLocalClassName(remoteClassName:String) -> String
    
    func localToRemoteProperties(localClassName:String) -> [String: String]
    func remoteToLocalProperties(localClassName:String) -> [String: String]
}

public protocol SpearalIntrospectorClassInfo {
    
    var type:AnyClass { get }
    var supertype:SpearalIntrospectorClassInfo? { get }
    var properties:[String] { get }
    var declaredProperties:[String] { get }
}

public protocol SpearalIntrospector: SpearalConfigurable {
    
    func introspect(cls:AnyClass) -> SpearalIntrospectorClassInfo
    
    func classNameOfAny(any:Any) -> String?
    func classNameOfAnyObject(anyObject:AnyObject) -> String?
    func classNameOfAnyClass(cls:AnyClass) -> String
    
    func classForName(name:String) -> AnyClass?
    func protocolForName(name:String) -> Protocol?
}

public protocol SpearalPropertyFilter {
    
    func add(cls:AnyClass, propertyNames:String...)
    func get(cls:AnyClass) -> [String]
}

public protocol SpearalContext {

    func configure(introspector:SpearalIntrospector) -> SpearalContext
    func configure(aliasStrategy:SpearalAliasStrategy) -> SpearalContext
    func configure(coderProvider:SpearalCoderProvider, append:Bool) -> SpearalContext
    func configure(converterPropvider:SpearalConverterProvider, append:Bool) -> SpearalContext

    func getIntrospector() -> SpearalIntrospector?
    func getAliasStrategy() -> SpearalAliasStrategy?
    func getCoderFor(any:Any) -> SpearalCoder?
    func getConverterFor(any:Any?) -> SpearalConverter?
    
    func convert(any:Any?, context:SpearalConverterContext) -> Any?
}

@objc(SpearalUnsupportedClassInstance)
public class SpearalUnsupportedClassInstance: NSObject {
    
    public let className:String
    public var properties:[String: AnyObject?]
    
    public init(_ className:String) {
        self.className = className
        self.properties = [String: AnyObject?]()
    }
}


@objc(SpearalEnum)
public class SpearalEnum: NSObject {
    
    public let className:String
    public let valueName:String
    
    public init(_ className:String, valueName:String) {
        self.className = className
        self.valueName = valueName
    }
}

@objc(SpearalBigIntegral)
public protocol SpearalBigNumber {
    
    var representation:String { get }
}

@objc(SpearalBigIntegral)
public class SpearalBigIntegral: NSObject, SpearalBigNumber {
    
    public let representation:String
    
    public init(_ representation:String) {
        self.representation = representation
    }
}

@objc(SpearalBigFloating)
public class SpearalBigFloating: NSObject, SpearalBigNumber {
    
    public let representation:String
    
    public init(_ representation:String) {
        self.representation = representation
    }
}
