//
//  Persister.swift
//  mirror-challenge
//
//  Created by Ali Ersöz on 2/25/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import RealmSwift

protocol Persistable {
    var id: Int {get set}
}

protocol PersisterProtocol {
	func get<T: Persistable & Object>(id: Int) -> T?
    func first<T: Persistable & Object>(isIncluded: (T) -> (Bool)) -> T?
    func all<T: Persistable & Object>(isIncluded: (T) -> (Bool)) -> [T]
    func save<T: Persistable & Object>(object: T)
    func delete<T: Persistable & Object>(object: T)
}

final class RealmPersister: PersisterProtocol {
    init() {
        configure()
    }
    
    private func configure() {
        func setDefaultRealmForUser(username: String) {
            var config = Realm.Configuration(schemaVersion: 2,
                                             migrationBlock: { migration, oldSchemaVersion in
                                                if (oldSchemaVersion < 2) {
                                                    // ...
                                                }
            })
            
            let dbname = "db-2"
            config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(dbname).realm")
            Realm.Configuration.defaultConfiguration = config
        }
    }
    
    func get<T: Persistable & Object>(id: Int) -> T? {
        let realm = try! Realm()
        return realm.objects(T.self).filter {$0.id == id}.first
    }
    
    func first<T: Persistable & Object>(isIncluded: (T) -> (Bool)) -> T? {
        let realm = try! Realm()
        return realm.objects(T.self).filter(isIncluded).first
    }
    
    func all<T: Persistable & Object>(isIncluded: (T) -> (Bool)) -> [T] {
        let realm = try! Realm()
        return realm.objects(T.self).filter(isIncluded)
    }
    
    func save<T: Persistable & Object>(object: T) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(object, update: true)
        }
    }
    
    func delete<T: Persistable & Object>(object: T) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(object)
        }
    }
}
