//
//  SwiftAddressBookRecord.swift
//  Pods
//
//  Created by Socialbit - Tassilo Karge on 09.03.15.
//
//

import Foundation
import AddressBook

//MARK: Wrapper for ABAddressBookRecord

public class SwiftAddressBookRecord {

	public var internalRecord : ABRecord!

	init(record : ABRecord) {
		internalRecord = record
	}

	init?(record : ABRecord!) {
		internalRecord = record
		if record == nil {
			return nil
		}
	}

	public var recordID: Int {
		get {
			return Int(ABRecordGetRecordID(self.internalRecord))
		}
    }
    
    public var recordType: SwiftAddressBookRecordType {
        get {
            return SwiftAddressBookRecordType(abRecordType: ABRecordGetRecordType(self.internalRecord))
        }
    }

	public func convertToSource() -> SwiftAddressBookSource? {
        return self as? SwiftAddressBookSource
	}

	public func convertToGroup() -> SwiftAddressBookGroup? {
		return self as? SwiftAddressBookGroup
	}

    public func convertToPerson() -> SwiftAddressBookPerson? {
        return self as? SwiftAddressBookPerson
    }
    
    public static func from(record: ABRecord?) -> SwiftAddressBookRecord? {
        let type = ABRecordGetRecordType(record)
        if type == UInt32(kABSourceType) {
            return SwiftAddressBookSource(record: record)
            
        } else if type == UInt32(kABGroupType) {
            return SwiftAddressBookGroup(record: record)
            
        } else if type == UInt32(kABPersonType) {
            return SwiftAddressBookPerson(record: record)
            
        } else {
            return nil
        }
    }

}

extension SwiftAddressBookRecord: Hashable {

	public var hashValue: Int {
		return recordID.hashValue
	}

}

public func == (lhs: SwiftAddressBookRecord, rhs: SwiftAddressBookRecord) -> Bool {
	return lhs.recordID == rhs.recordID
}
