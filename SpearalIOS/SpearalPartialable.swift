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

@objc(SpearalPartialable)
public protocol SpearalPartialable {
    
    func _$isDefined(name:String) -> Bool
    func _$undefine(name:String)
    
    var  _$definedPropertyNames:[String] { get }
}

private var propertyNamesCache = Dictionary<UnsafePointer<Void>, [String]>()
private func getPropertyNames(anyClass:AnyClass, stopClass:AnyClass = NSObject.self) -> [String] {
    let key = unsafeAddressOf(anyClass)
    
    if let propertyNames = propertyNamesCache[key] {
        return propertyNames
    }
    
    let stopClassAddress = unsafeAddressOf(stopClass)
    
    var propertyNames = [String]()
    
    for var cls:AnyClass? = anyClass;
        cls != nil && unsafeAddressOf(cls!) != stopClassAddress;
        cls = class_getSuperclass(cls) {
            
            var count:CUnsignedInt = 0
            let list:UnsafeMutablePointer<objc_property_t> = class_copyPropertyList(cls, &count)
            
            for var i:Int = 0; i < Int(count); i++ {
                let property = list[i]
                if property_copyAttributeValue(property, "R") == nil {
                    propertyNames.append(String.fromCString(property_getName(property))!)
                }
            }
    }
    
    propertyNamesCache[key] = propertyNames
    
    return propertyNames
}

@objc(SpearalAutoPartialable)
public class SpearalAutoPartialable: NSObject, SpearalPartialable {
    
    private var observerContext = 0
    private var properties:[String: Bool]
    
    required override public init() {
        self.properties = [String: Bool]()
        
        super.init()
        
        let propertyNames = getPropertyNames(self.dynamicType, stopClass: SpearalAutoPartialable.self)
        for propertyName in propertyNames {
            if propertyName.isEmpty || properties[propertyName] != nil {
                continue
            }
            properties[propertyName] = false
            
            self.addObserver(self, forKeyPath: propertyName, options: .New, context: &observerContext)
        }
    }
    
    public override var description:String {
        var className = NSStringFromClass(self.dynamicType)
        if className.hasPrefix("NSKVONotifying_") {
            className = NSStringFromClass(class_getSuperclass(self.dynamicType))
        }
        
        var s = className + " {"
        for (propertyName, defined) in properties {
            s += "\n    " + propertyName + ": "
            if defined {
                var value:AnyObject? = valueForKey(propertyName)
                if value != nil {
                    s += "\(value!)"
                }
                else {
                    s += "nil"
                }
            }
            else {
                s += "(undefined)"
            }
        }
        s += "\n}"
        return s
    }
    
    public func _$isDefined(name:String) -> Bool {
        return properties[name] ?? false
    }
    
    public func _$undefine(name:String) {
        if _$isDefined(name) {
            setValue(nil, forKey: name)
            properties[name] = false
        }
    }
    
    public var _$definedPropertyNames:[String] {
        get {
            return properties.keys.filter({(name:String) in return self.properties[name]!}).array
        }
    }
    
    override public func observeValueForKeyPath(
        keyPath: String,
        ofObject: AnyObject,
        change: [NSObject: AnyObject],
        context: UnsafeMutablePointer<Void>) {

        if context == &observerContext {
            properties[keyPath] = true
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: ofObject, change: change, context: context)
        }
    }
    
    deinit {
        for propertyName in properties.keys {
            self.removeObserver(self, forKeyPath: propertyName, context: &observerContext)
        }
    }
}
