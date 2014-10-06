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

protocol SpearalConfigurable {
}

protocol SpearalRepeatable: SpearalConfigurable {
}

typealias SpearalCoder = (encoder:SpearalExtendedEncoder, value:Any) -> Void

protocol SpearalCoderProvider: SpearalRepeatable {
    
    func coder(any:Any) -> SpearalCoder?
}

typealias SpearalIntrospectorGetter = (AnyObject) -> AnyObject?
typealias SpearalIntrospectorSetter = (AnyObject, AnyObject?) -> Void

protocol SpearalIntrospectorProperty {
    
    var name:String { get }
    var get:SpearalIntrospectorGetter { get }
    var set:SpearalIntrospectorSetter { get }
}

protocol SpearalIntrospectorClass {
    
    var cls:AnyClass { get }
    var name:String { get }
    var properties:[String: SpearalIntrospectorProperty] { get }
}

protocol SpearalIntrospector: SpearalConfigurable {
    
    func introspect(cls:AnyClass) -> SpearalIntrospectorClass
    func classNameOf(any:Any) -> String?
    func classNameOf(cls:AnyClass) -> String
    func classForName(name:String) -> AnyClass?
    func protocolForName(name:String) -> Protocol?
}

protocol SpearalContext {

    func configure(coderProvider:SpearalCoderProvider, append:Bool)
    func configure(introspector:SpearalIntrospector)

    var introspector:SpearalIntrospector { get }
    
    func coderFor(any:Any) -> SpearalCoder?
}
