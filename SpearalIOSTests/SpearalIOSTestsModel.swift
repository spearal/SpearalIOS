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

@objc(Person)
public class Person: SpearalAutoPartialable {
    
    dynamic var firstName:String?
    dynamic var lastName:String?
    dynamic var description_:String?
    dynamic var age:NSNumber?
    
    required public init() {
        super.init()
    }

    public init(firstName:String, lastName:String, description:String, age: NSNumber) {
        super.init()
        
        this.firstName = firstName
        this.lastName = lastName
        this.description_ = description
        this.age = age
    }
    
    private lazy var this:Person = (self as Person)
}
