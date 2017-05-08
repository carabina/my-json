//
//  JSONDeserialization.swift
//  MYUtils
//
//  Created by Optimus Prime on 04.05.17.
//  Copyright © 2017 Trenlab. All rights reserved.
//

import Foundation

// MARK: - MYJSONDeserizlizable

public protocol MYJSONDeserizlizable {
    init(json: MYJSON)
}

// MARK: - Operators

infix operator <-

// MARK: - Assignment

public func <- <T>(lft: inout T?, rgt: Any?) {
    lft = Transform(model: lft, data: rgt)
}

public func <- <T>(lft: inout  T, rgt: Any?) {
    if let deser = Transform(model: lft, data: rgt) {
        lft = deser
    }
}

// MARK: - Deserizlizable

public func <- <T: MYJSONDeserizlizable>(lhs: T.Type, rhs: Any?) -> T {
    let model = lhs.init(json: MYJSON())
    
    guard let right = rhs else {
        return model
    }
    
    switch right {
    case is MYJSON:
        return lhs.init(json: right as! MYJSON)
    case is T:
        return right as! T
    default:
        return model
    }
}

public func <- <T: MYJSONDeserizlizable>(lhs: T.Type, rhs: Any?) -> [T] {
    var models: [T] = []
    
    guard let right = rhs else {
        return []
    }

    switch right {
    case is MYJSON:
        let json  = right as! MYJSON
        let model = lhs.init(json: json)
        models.append(model)
    case is [MYJSON]:
        let jsonArray = right as! [MYJSON]
        
        models = jsonArray.map({ (json: MYJSON) -> T in
            return lhs.init(json: json)
        })
    case is T:
        models.append(right as! T)
    case is [T]:
        models.append(contentsOf: (right as! [T]))
    default: break
    }
    
    return models
}

public func <- <T: MYJSONDeserizlizable>(lhs: T.Type, rhs: MYJSON) -> T {
    return lhs.init(json: rhs)
}

public func <- <T: MYJSONDeserizlizable>(lhs: T.Type, rhs: MYJSONArrayType) -> [T] {
    var array: [T] = []
    
    for json in rhs {
        let model: T = lhs <- json
        array.append(model)
    }
    
    return array
}

public func <- <T: MYJSONDeserizlizable>(lhs: T.Type, rhs: MYJSONType) -> T {
    return T(json: MYJSON(value: rhs))
}

// MARK: - Enum

public func <- <T: RawRepresentable>(lft: inout T, rgt: Any?) {
    guard let right = rgt else {
        return
    }
    guard right is T.RawValue else {
        return
    }
    
    if let deser = Transform(model: lft, data: T(rawValue: right as! T.RawValue)) {
        lft = deser
    }
}

public func <- <T: RawRepresentable>(lft: inout T?, rgt: Any?) {
    guard let right = rgt else {
        return
    }
    guard right is T.RawValue else {
        return
    }
    
    lft = Transform(model: lft, data: T(rawValue: right as! T.RawValue))
}

// MARK: - Transform

public func Transform<T>(model: T?, data: Any?) -> T? {
    guard let _ = data else {
        return nil
    }
    guard data! is T else {
        return nil
    }
    
    return data as! T?
}