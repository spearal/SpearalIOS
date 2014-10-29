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

public protocol SpearalFactory {
    
    var context:SpearalContext { get }
    
    func newEncoder(output:SpearalOutput) -> SpearalEncoder
    // func newEncoder(output:SpearalOutput, filter:SpearalPropertyFilter) -> SpearalEncoder
    
    func newDecoder(input:SpearalInput) -> SpearalDecoder
}

public class DefaultSpearalFactory: SpearalFactory {
    
    public let context:SpearalContext
    
    public init() {
        self.context = SpearalContextImpl()
        
        context
            .configure(SpearalIntrospectorImpl())
            .configure(SpearalStandardCoderProvider(), append: false)
    }
    
    public func newEncoder(output:SpearalOutput) -> SpearalEncoder {
        return SpearalEncoderImpl(context: context, output: output)
    }

    // func newEncoder(output:SpearalOutput, filter:SpearalPropertyFilter) -> SpearalEncoder
    
    public func newDecoder(input:SpearalInput) -> SpearalDecoder {
        return SpearalDecoderImpl(context: context, input: input)
    }
}

public class BasicSpearalAliasStrategy: SpearalAliasStrategy {
    
    private var localToRemoteClassNames:[String: String]
    private var remoteToLocalClassNames:[String: String]
    
    private let localToRemoteAliaser:SpearalClassNameAliaser
    private let remoteToLocalAliaser:SpearalClassNameAliaser
    
    private var localToRemoteProperties:[String: [String: String]]
    private var remoteToLocalProperties:[String: [String: String]]
    
    public convenience required init(localToRemoteClassNames:[String: String]) {
        self.init(
            localToRemoteClassNames,
            { (localClassName:String) -> String in return localClassName },
            { (remoteClassName:String) -> String in return remoteClassName }
        )
    }
    
    public convenience required init(
        localToRemoteAliaser:SpearalClassNameAliaser,
        remoteToLocalAliaser:SpearalClassNameAliaser) {

        self.init([String: String](), localToRemoteAliaser, remoteToLocalAliaser)
    }
    
    private init(
        _ localToRemoteClassNames:[String: String],
        localToRemoteAliaser:SpearalClassNameAliaser,
        remoteToLocalAliaser:SpearalClassNameAliaser) {
        
        self.localToRemoteClassNames = localToRemoteClassNames
        self.remoteToLocalClassNames = BasicSpearalAliasStrategy.reverseMap(localToRemoteClassNames)
        
        self.localToRemoteAliaser = localToRemoteAliaser
        self.remoteToLocalAliaser = remoteToLocalAliaser
        
        self.localToRemoteProperties = [String: [String: String]]()
        self.remoteToLocalProperties = [String: [String: String]]()
    }
    
    public func setPropertiesAlias(localClassName:String, localToRemoteProperties:[String: String]) {
        self.localToRemoteProperties[localClassName] = localToRemoteProperties
        self.remoteToLocalProperties[localClassName] = BasicSpearalAliasStrategy.reverseMap(localToRemoteProperties)
    }
    
    public func localToRemoteClassName(localClassName:String) -> String {
        if let remoteClassName = localToRemoteClassNames[localClassName] {
            return remoteClassName
        }
        let remoteClassName = localToRemoteAliaser(localClassName)
        localToRemoteClassNames[localClassName] = remoteClassName
        return remoteClassName
    }
    
    public func remoteToLocalClassName(remoteClassName:String) -> String {
        if let localClassName = remoteToLocalClassNames[remoteClassName] {
            return localClassName
        }
        let localClassName = localToRemoteAliaser(remoteClassName)
        remoteToLocalClassNames[remoteClassName] = localClassName
        return localClassName
    }
    
    public func localToRemoteProperties(localClassName:String) -> [String: String] {
        if let properties = localToRemoteProperties[localClassName] {
            return properties
        }
        if let properties = localToRemoteProperties["*"] {
            return properties
        }
        return [String: String]()
    }
    
    public func remoteToLocalProperties(localClassName:String) -> [String: String] {
        if let properties = remoteToLocalProperties[localClassName] {
            return properties
        }
        if let properties = remoteToLocalProperties["*"] {
            return properties
        }
        return [String: String]()
    }
    
    private class func reverseMap(map:[String: String]) -> [String: String] {
        var reversed = [String: String]()
        for (key, value) in map {
            reversed[value] = key
        }
        return reversed
    }
}
