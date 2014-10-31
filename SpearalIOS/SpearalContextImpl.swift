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

private func bigNumberAplha() -> [UInt8] {
    var bytes = [UInt8]()
    bytes.extend("0123456789+-.E".utf8)
    return bytes
}

let BIG_NUMBER_ALPHA = bigNumberAplha()

private func bigNumberAplhaMirror() -> [UInt8] {
    var bytes = [UInt8](count: 0xff, repeatedValue: 0)
    for i in 0...(BIG_NUMBER_ALPHA.count - 1) {
        bytes[Int(BIG_NUMBER_ALPHA[i])] = UInt8(i)
    }
    return bytes
}

let BIG_NUMBER_ALPHA_MIRROR = bigNumberAplhaMirror()

class SpearalContextImpl: SpearalContext {
    
    private var introspector:SpearalIntrospector?
    private var aliasStrategy:SpearalAliasStrategy?
    
    private var coderProviders:[SpearalCoderProvider]
    private var codersCache:[String: SpearalCoder]
    
    private var converterProviders:[SpearalConverterProvider]
    private var convertersCache:[String: SpearalConverter]
    
    init() {
        self.coderProviders = [SpearalCoderProvider]()
        self.codersCache = [String: SpearalCoder]()
        
        self.converterProviders = [SpearalConverterProvider]()
        self.convertersCache = [String: SpearalConverter]()
    }
    
    func configure(introspector:SpearalIntrospector) -> SpearalContext {
        self.introspector = introspector
        return self
    }
    
    func configure(converterProvider:SpearalConverterProvider, append:Bool) -> SpearalContext {
        if append {
            converterProviders.append(converterProvider)
        }
        else {
            converterProviders.insert(converterProvider, atIndex: 0)
        }
        return self
    }
    
    func configure(aliasStrategy:SpearalAliasStrategy) -> SpearalContext {
        self.aliasStrategy = aliasStrategy
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
    
    func getIntrospector() -> SpearalIntrospector? {
        return self.introspector
    }
    
    func getAliasStrategy() -> SpearalAliasStrategy? {
        return self.aliasStrategy
    }
    
    func getCoderFor(any:Any) -> SpearalCoder? {
        if !coderProviders.isEmpty {
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
        }
        return nil
    }
    
    func getConverterFor(any:Any?) -> SpearalConverter? {
        if !converterProviders.isEmpty {
            let key:String = introspector!.classNameOfAny(any)!
            
            if let converter = convertersCache[key] {
                return converter
            }
            
            for provider in converterProviders {
                if let converter = provider.converter(any) {
                    convertersCache[key] = converter
                    return converter
                }
            }
        }
        return nil
    }
    
    func convert(any:Any?, context:SpearalConverterContext) -> Any? {
        if let converter = getConverterFor(any) {
            return converter.convert(any, context: context)
        }
        return any
    }
}