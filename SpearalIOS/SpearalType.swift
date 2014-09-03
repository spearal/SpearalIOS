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

enum SpearalType: UInt8 {
    
    // No parameters (0x00...0x0f).
    
    case NULL = 0x00
    
    case TRUE = 0x01
    case FALSE = 0x02
    
    // 4 bits of parameters (0x10...0xf0).
    
    case INTEGRAL = 0x10
    case BIG_INTEGRAL = 0x20
    
    case FLOATING = 0x30
    case BIG_FLOATING = 0x40
    
    case STRING = 0x50
    
    case BYTE_ARRAY = 0x60
    
    case DATE_TIME = 0x70
    
    case COLLECTION = 0x80
    case MAP = 0x90
    
    case ENUM = 0xa0
    case CLASS = 0xb0
    case BEAN = 0xc0
    
    static func valueOf(parameterizedType:UInt8) -> SpearalType? {
        return SpearalType.fromRaw(parameterizedType < 0x10 ? parameterizedType : parameterizedType & UInt8(0xf0))
    }
}