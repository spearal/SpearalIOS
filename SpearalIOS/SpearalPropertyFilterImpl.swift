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

class SpearalPropertyFilterImpl: SpearalPropertyFilter {

    let context:SpearalContext
    private var propertiesMap:[UnsafePointer<Void>: [String]]
    
    init(_ context:SpearalContext) {
        self.context = context
        self.propertiesMap = [(UnsafePointer<Void>): [String]]()
    }
    
    func add(cls:AnyClass, propertyNames:String...) {
        let key = unsafeAddressOf(cls)
        
        let info = context.getIntrospector()!.introspect(cls)
        
        var properties = [String]()
        for property in info.properties {
            if contains(propertyNames, property) {
                properties.append(property)
            }
        }
        
        propertiesMap[key] = properties
    }
    
    func get(cls:AnyClass) -> [String] {
        let key = unsafeAddressOf(cls)
        
        if let properties = propertiesMap[key] {
            return properties
        }
        
        return context.getIntrospector()!.introspect(cls).properties
    }
}
