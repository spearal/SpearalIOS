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

class SpearalContextImpl: SpearalContext {
    
    private var introspector:SpearalIntrospector?
    private var aliasStrategy:SpearalAliasStrategy?
    
    private var coderProviders:[SpearalCoderProvider]
    private var codersCache:[String: SpearalCoder]
    
    init() {
        self.coderProviders = [SpearalCoderProvider]()
        self.codersCache = [String: SpearalCoder]()
    }
    
    func configure(introspector:SpearalIntrospector) -> SpearalContext {
        self.introspector = introspector
        return self
    }
    
    func configure(coderProvider:SpearalCoderProvider, append:Bool) -> SpearalContext {
        if append {
            coderProviders.append(coderProvider)
        }
        else {
            coderProviders.insert(coderProvider, atIndex: 0)
        }
        return self
    }
    
    func configure(aliasStrategy:SpearalAliasStrategy) -> SpearalContext {
        self.aliasStrategy = aliasStrategy
        return self
    }
    
    func getIntrospector() -> SpearalIntrospector? {
        return self.introspector
    }
    
    func getAliasStrategy() -> SpearalAliasStrategy? {
        return self.aliasStrategy
    }
    
    func getCoderFor(any:Any) -> SpearalCoder? {
        let key:String = introspector!.classNameOfAny(any)!
        
        if let coder = codersCache[key] {
            return coder
        }
        
        for provider in coderProviders {
            if let coder = provider.coder(any) {
                codersCache[key] = coder
                return coder
            }
        }
        
        return nil
    }
}