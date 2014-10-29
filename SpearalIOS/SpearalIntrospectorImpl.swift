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

class SpearalIntrospectorClassInfoImpl: SpearalIntrospectorClassInfo {
    
    let type:AnyClass
    let supertype:SpearalIntrospectorClassInfo?
    let declaredProperties:[String]
    
    init(type:AnyClass, supertype:SpearalIntrospectorClassInfo?, declaredProperties:[String]) {
        self.type = type
        self.supertype = supertype
        self.declaredProperties = declaredProperties
    }
    
    var properties:[String] {
        get {
            if supertype == nil {
                return declaredProperties
            }
            return declaredProperties + supertype!.properties
        }
    }
}

class SpearalIntrospectorImpl: SpearalIntrospector {
    
    private var cache:[UnsafePointer<Void>: SpearalIntrospectorClassInfo]
    
    init() {
        cache = [(UnsafePointer<Void>): SpearalIntrospectorClassInfo]()
        cache[unsafeAddressOf(NSObject.self)] = SpearalIntrospectorClassInfoImpl(type: NSObject.self, supertype: nil, declaredProperties: [String]())
    }
    
    func introspect(cls:AnyClass) -> SpearalIntrospectorClassInfo {
        let key:UnsafePointer = unsafeAddressOf(cls)
        
        if let info = cache[key] {
            return info
        }
        
        let supertype = introspect(class_getSuperclass(cls))
        let declaredProperties = getDeclaredProperties(cls)
        
        let info = SpearalIntrospectorClassInfoImpl(type: cls, supertype: supertype, declaredProperties: declaredProperties)
        cache[key] = info
        return info
    }
    
    func classNameOfAny(any:Any) -> String? {
        if any is AnyClass {
            return classNameOfAnyClass(any as AnyClass)
        }
        if any is NSObject {
            return classNameOfAnyClass((any as NSObject).dynamicType)
        }
        
        let name = _stdlib_getDemangledTypeName(any)
        if !name.isEmpty {
            return name
        }
        if any is AnyClass {
            return "Swift.AnyClass"
        }
        if reflect(any).disposition == MirrorDisposition.Tuple {
            return "Swift.Tuple"
        }
        return nil
    }
    
    func classNameOfAnyObject(anyObject:AnyObject) -> String? {
        return classNameOfAnyClass(anyObject.dynamicType)
    }

    func classNameOfAnyClass(anyClass:AnyClass) -> String {
        var name = NSStringFromClass(anyClass)
        if name.hasPrefix("NSKVONotifying_") {
            name = NSStringFromClass(class_getSuperclass(anyClass))
        }
        return name
    }
    
    func classForName(name:String) -> AnyClass? {
        return NSClassFromString(name)
    }
    
    func protocolForName(name:String) -> Protocol? {
        return NSProtocolFromString(name)
    }
    
    private func getDeclaredProperties(type:AnyClass) -> [String] {
        var propertyNames = [String]()
        
        var count:CUnsignedInt = 0
        let list:UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(type, &count)
        
        for var i:Int = 0; i < Int(count); i++ {
            let property = list[i]
            if property_copyAttributeValue(property, "R") == nil {
                propertyNames.append(String.fromCString(property_getName(property))!)
            }
        }
        
        return propertyNames
    }
}
