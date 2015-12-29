//SwiftAddressBook - A strong-typed Swift Wrapper for ABAddressBook
//Copyright (C) 2014  Socialbit GmbH
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

import UIKit
import AddressBook

//MARK: global address book variable

public let swiftAddressBook : SwiftAddressBook? = SwiftAddressBook(0)

//MARK: Address Book

public class SwiftAddressBook {
    
    public var internalAddressBook : ABAddressBook!
    
	/**
	PRECAUTION: do not use this function unless you are aware why it exists,
	and what you have to take care about using multiple instances.
	Creating multiple AddressBooks is required for using ABAddressBook multi-
	threaded. Though, it leads to several issues:
	You must reset the address book instances individually in order to keep
	them synchronized. Contacts saved to one AddressBook are not visible in
	another until revert() was called.
	Additionally, it is not entirely clear what happens when simultaneously
	saving two AddressBook instances using save(). To prevent errors, keep
	the calls to save() sequential. It is not clear whether changes are
	overridden by another save() call, to be sure what it does try out first.
	*/
	public class func createAddressBookForAdditionalThread() -> SwiftAddressBook? {
		return SwiftAddressBook(0)
	}

    private init?(_ dummy : Int) {
        var err : Unmanaged<CFError>? = nil
        let ab = ABAddressBookCreateWithOptions(nil, &err)
        if err == nil {
            internalAddressBook = ab.takeRetainedValue()
        }
        else {
            return nil
        }
    }
    
    public class func authorizationStatus() -> ABAuthorizationStatus {
        return ABAddressBookGetAuthorizationStatus()
    }
    
    public func requestAccessWithCompletion( completion : (Bool, CFError?) -> Void ) {
        ABAddressBookRequestAccessWithCompletion(internalAddressBook) {(let b : Bool, c : CFError!) -> Void in completion(b,c)}
    }
    
    public func hasUnsavedChanges() -> Bool {
        return ABAddressBookHasUnsavedChanges(internalAddressBook)
    }
    
    public func save() -> CFError? {
        return errorIfNoSuccess { ABAddressBookSave(self.internalAddressBook, $0)}
    }
    
    public func revert() {
        ABAddressBookRevert(internalAddressBook)
    }
    
    public func addRecord(record : SwiftAddressBookRecord) -> CFError? {
        return errorIfNoSuccess { ABAddressBookAddRecord(self.internalAddressBook, record.internalRecord, $0) }
    }
    
    public func removeRecord(record : SwiftAddressBookRecord) -> CFError? {
        return errorIfNoSuccess { ABAddressBookRemoveRecord(self.internalAddressBook, record.internalRecord, $0) }
    }
    
//    //This function does not yet work
//    public func registerExternalChangeCallback(callback: (AnyObject) -> Void) {
//        //call some objective C function (c function pointer does not work in swift)
//    }
//
//    //This function does not yet work
//    public func unregisterExternalChangeCallback(callback: (AnyObject) -> Void) {
//        //call some objective C function (c function pointer does not work in swift)
//    }
    
    
    //MARK: person records
    
    public var personCount : Int {
        get {
            return ABAddressBookGetPersonCount(internalAddressBook)
        }
    }
    
    public func personWithRecordId(recordId : Int32) -> SwiftAddressBookPerson? {
        return SwiftAddressBookRecord.from(ABAddressBookGetPersonWithRecordID(internalAddressBook, recordId)?.takeUnretainedValue()) as? SwiftAddressBookPerson
    }
    
    public var allPeople : [SwiftAddressBookPerson]? {
        get {
            return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeople(internalAddressBook).takeRetainedValue())
        }
    }
    
	public var allPeopleExcludingLinkedContacts : [SwiftAddressBookPerson]? {
		if let all = allPeople {
			let filtered : NSMutableArray = NSMutableArray(array: all)
			for person in all {
				if !(NSArray(array: filtered) as! [SwiftAddressBookPerson]).contains({
					(SwiftAddressBookPerson p) -> Bool in
					return p.recordID == person.recordID
				}) {
					//already filtered out this contact
					continue
				}

				//throw out duplicates
				let allFiltered : [SwiftAddressBookPerson] = NSArray(array: filtered) as! [SwiftAddressBookPerson]
				for possibleDuplicate in allFiltered {
					if let linked = person.allLinkedPeople {
						if possibleDuplicate.recordID != person.recordID
							&& linked.contains({
								(SwiftAddressBookPerson p) -> Bool in
								return p.recordID == possibleDuplicate.recordID
							}) {
								(filtered as NSMutableArray).removeObject(possibleDuplicate)
						}
					}
				}
			}
			return NSArray(array: filtered) as? [SwiftAddressBookPerson]
		}
		return nil
	}

    public func allPeopleInSource(source : SwiftAddressBookSource) -> [SwiftAddressBookPerson]? {
        return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeopleInSource(internalAddressBook, source.internalRecord).takeRetainedValue())
    }
    
    public func allPeopleInSourceWithSortOrdering(source : SwiftAddressBookSource, ordering : SwiftAddressBookOrdering) -> [SwiftAddressBookPerson]? {
        return convertRecordsToPersons(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(internalAddressBook, source.internalRecord, ordering.abPersonSortOrderingValue).takeRetainedValue())
    }
	
	public func peopleWithName(name : String) -> [SwiftAddressBookPerson]? {
		return convertRecordsToPersons(ABAddressBookCopyPeopleWithName(internalAddressBook, name).takeRetainedValue())
	}


    //MARK: group records
    
    public func groupWithRecordId(recordId : Int32) -> SwiftAddressBookGroup? {
        return SwiftAddressBookRecord.from(ABAddressBookGetGroupWithRecordID(internalAddressBook, recordId)?.takeUnretainedValue()) as? SwiftAddressBookGroup
    }
    
    public var groupCount : Int {
        get {
            return ABAddressBookGetGroupCount(internalAddressBook)
        }
    }
    
    public var arrayOfAllGroups : [SwiftAddressBookGroup]? {
        get {
            return convertRecordsToGroups(ABAddressBookCopyArrayOfAllGroups(internalAddressBook).takeRetainedValue())
        }
    }
    
    public func allGroupsInSource(source : SwiftAddressBookSource) -> [SwiftAddressBookGroup]? {
        return convertRecordsToGroups(ABAddressBookCopyArrayOfAllGroupsInSource(internalAddressBook, source.internalRecord).takeRetainedValue())
    }
    
    
    //MARK: sources
    
    public var defaultSource : SwiftAddressBookSource? {
        get {
            return SwiftAddressBookRecord.from(ABAddressBookCopyDefaultSource(internalAddressBook)?.takeRetainedValue()) as? SwiftAddressBookSource
        }
    }
    
    public func sourceWithRecordId(sourceId : Int32) -> SwiftAddressBookSource? {
        return SwiftAddressBookRecord.from(ABAddressBookGetSourceWithRecordID(internalAddressBook, sourceId)?.takeUnretainedValue()) as? SwiftAddressBookSource
    }
    
    public var allSources : [SwiftAddressBookSource]? {
        get {
            return convertRecordsToSources(ABAddressBookCopyArrayOfAllSources(internalAddressBook).takeRetainedValue())
        }
    }    
}
