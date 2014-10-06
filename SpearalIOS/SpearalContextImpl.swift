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
    
    private var _introspector:SpearalIntrospector?
    
    private var coderProviders:[SpearalCoderProvider]
    private var coderProvidersCache:[String: SpearalCoder]
    
    init() {
        self.coderProviders = [SpearalCoderProvider]()
        self.coderProvidersCache = [String: SpearalCoder]()
    }
    
    var introspector:SpearalIntrospector {
        return _introspector!
    }
    
    func configure(coderProvider:SpearalCoderProvider, append:Bool) {
        if append {
            coderProviders.append(coderProvider)
        }
        else {
            coderProviders.insert(coderProvider, atIndex: 0)
        }
    }
    
    func configure(introspector:SpearalIntrospector) {
        self._introspector = introspector
    }
    
    func coderFor(any:Any) -> SpearalCoder? {
        let key:String = _introspector!.classNameOf(any)!
        
        if let coder = coderProvidersCache[key] {
            return coder
        }
        
        for provider in coderProviders {
            if let coder = provider.coder(any) {
                coderProvidersCache[key] = coder
                return coder
            }
        }
        
        return nil
    }
}