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

class SpearalIntrospectorPropertyImpl: SpearalIntrospectorProperty {
    
    let name:String
    let get:SpearalIntrospectorGetter
    let set:SpearalIntrospectorSetter
    
    init(name:String, get:SpearalIntrospectorGetter, set:SpearalIntrospectorSetter) {
        self.name = name
        self.get = get
        self.set = set
    }
}

class SpearalIntrospectorClassImpl: SpearalIntrospectorClass {
    
    let cls:AnyClass
    let name:String
    let properties:[String: SpearalIntrospectorProperty]
    
    init(_ cls:AnyClass) {
        self.cls = cls
        self.name = NSStringFromClass(cls)
        self.properties = __getProperties(cls)
    }
}

class SpearalIntrospectorImpl: SpearalIntrospector {
    
    private var classesCache:[String: SpearalIntrospectorClass]
    
    init() {
        self.classesCache = [String: SpearalIntrospectorClass]()
    }
    
    func introspect(cls:AnyClass) -> SpearalIntrospectorClass {
        let name = NSStringFromClass(cls)
        
        if let info = classesCache[name] {
            return info
        }
        
        let info = SpearalIntrospectorClassImpl(cls)
        classesCache[name] = info
        return info
    }
    
    /// Get the qualified class name of a value. If the value is a class, this method returns
    /// "Swift.AnyClass". If value is a tuple, it returns "Swift.Tuple". Otherwise, nil is
    /// returned.
    ///
    /// :param: any the value from which to get class name
    /// :returns: the class name, prefixed with its namespace if any
    func classNameOf(any:Any) -> String? {
        return __getClassName(any)
    }

    func classNameOf(cls:AnyClass) -> String {
        return NSStringFromClass(cls)
    }
    
    func classForName(name:String) -> AnyClass? {
        return NSClassFromString(name)
    }
    
    func protocolForName(name:String) -> Protocol? {
        return NSProtocolFromString(name)
    }
}

private func __getClassName(any:Any) -> String? {
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

private func __getProperties(cls:AnyClass) -> [String: SpearalIntrospectorProperty] {
    var count:CUnsignedInt = 0
    let list:UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(cls, &count)
    
    var properties = [String: SpearalIntrospectorProperty]()
    for var i:Int = 0; i < Int(count); i++ {
        let property = list[i]
        let attributes = (NSString(CString: property_getAttributes(property), encoding: NSUTF8StringEncoding) as String)
            .componentsSeparatedByString(",")
        
        if contains(attributes, "R") {
            continue
        }
        
        let name = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding) as String
        properties[name] = SpearalIntrospectorPropertyImpl(
            name: name,
            get: { (holder:AnyObject) in holder.valueForKey(name) },
            set: { (holder:AnyObject, value:AnyObject?) in holder.setValue(value, forKey: name) }
        )
    }
    return properties
}


