//
//  Model.swift
//  visitor
//
//  Created by Deyan Marinov on 13.07.20.
//  Copyright © 2020 accessapp. All rights reserved.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

let BASE_URL = "http://162.13.159.108:3001"

// MARK: - Welcome
struct Welcome: Codable {
    let places: [Place]
}

// MARK: - Place
struct Place: Codable {
    let id, name, type, placeDescription: String
    let www: String
    let address, location: String
    var isFavourite, approved: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, type
        case placeDescription = "description"
        case www, address, location, isFavourite, approved
    }
}

//struct DecodedArray<T: Decodable>: Decodable {
//
//    // ***
//    typealias DecodedArrayType = [T]
//
//    private var array: DecodedArrayType
//
//    // Define DynamicCodingKeys type needed for creating decoding container from JSONDecoder
//    private struct DynamicCodingKeys: CodingKey {
//
//        // Use for string-keyed dictionary
//        var stringValue: String
//        init?(stringValue: String) {
//            self.stringValue = stringValue
//        }
//
//        // Use for integer-keyed dictionary
//        var intValue: Int?
//        init?(intValue: Int) {
//            // We are not using this, thus just return nil
//            return nil
//        }
//    }
//
//    init(from decoder: Decoder) throws {
//
//        // Create decoding container using DynamicCodingKeys
//        // The container will contain all the JSON first level key
//        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
//
//        var tempArray = DecodedArrayType()
//
//        // Loop through each keys in container
//        for key in container.allKeys {
//
//            // ***
//            // Decode T using key & keep decoded T object in tempArray
//            let decodedObject = try container.decode(T.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
//            tempArray.append(decodedObject)
//        }
//
//        // Finish decoding all T objects. Thus assign tempArray to array.
//        array = tempArray
//    }
//}
//
////// Transform DecodedArray into custom collection
//extension DecodedArray: Collection {
//
//    // Required nested types, that tell Swift what our collection contains
//    typealias Index = DecodedArrayType.Index
//    typealias Element = DecodedArrayType.Element
//
//    // The upper and lower bounds of the collection, used in iterations
//    var startIndex: Index { return array.startIndex }
//    var endIndex: Index { return array.endIndex }
//
//    // Required subscript, based on a dictionary index
//    subscript(index: Index) -> Iterator.Element {
//        get { return array[index] }
//    }
//
//    // Method that returns the next index when iterating
//    func index(after i: Index) -> Index {
//        return array.index(after: i)
//    }
//}
//
//// MARK: - Slot
//struct Slot: Decodable {
//
//    let id, type, from, to: String
//    let occupiedSlots, maxSlots: Int
//    let isPlanned: Bool
//    let friends: Int
//    let date: String
//
//    enum CodingKeys: CodingKey {
//        case id, type, from, to, occupiedSlots, maxSlots, isPlanned, friends
//    }
//
//    init(from decoder: Decoder) throws {
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        // Decode name
//        id = try container.decode(String.self, forKey: CodingKeys.id)
//        type = try container.decode(String.self, forKey: CodingKeys.type)
//        from = try container.decode(String.self, forKey: CodingKeys.from)
//        to = try container.decode(String.self, forKey: CodingKeys.to)
//        occupiedSlots = try container.decode(Int.self, forKey: CodingKeys.occupiedSlots)
//        maxSlots = try container.decode(Int.self, forKey: CodingKeys.maxSlots)
//        isPlanned = try container.decode(Bool.self, forKey: CodingKeys.isPlanned)
//        friends = try container.decode(Int.self, forKey: CodingKeys.friends)
//
//        // Extract category from coding path
//        date = container.codingPath.first!.stringValue
//    }
//}

public struct Outer: Codable {
    public let slots: Slots
}

public struct Slots: Codable {
    public var innerArray: [String: [Slot]]
    
    public struct Slot: Codable {
        public let id: String
        public let type: String
        public let from: String
        public let to: String
        public let occupiedSlots: Int
        public let maxSlots: Int
        public let isPlanned: Bool
        public let friends: Int
    }
    
    private struct CustomCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        
        self.innerArray = [String: [Slot]]()
        for key in container.allKeys {
            let value = try container.decode([Slot].self, forKey: CustomCodingKeys(stringValue: key.stringValue)!)
            self.innerArray[key.stringValue] = value
        }
    }
}

public struct VisitResponse: Codable {
    public let visits: Visits
}

public struct Visits: Codable {
    public var innerArray: [String: [Visit]]
    
    public struct Visit: Codable {
        public let slotId: String
        public let placeId: String
        public let type: String
        public let name: String
        public let startTime: String
        public let endTime: String
        public let occupiedSlots: Int
        public let maxSlots: Int
        public let visitors: Int
    }
    
    private struct CustomCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        
        self.innerArray = [String: [Visit]]()
        for key in container.allKeys {
            let value = try container.decode([Visit].self, forKey: CustomCodingKeys(stringValue: key.stringValue)!)
            self.innerArray[key.stringValue] = value
        }
    }
}
