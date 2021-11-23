//
//  ToDoTask.swift
//  RealmDemoApp
//
//  Created by Martin Urciuoli on 22/11/2021.
//

import Foundation
import RealmSwift

class ToDoTask: Object {
    @objc dynamic var tasknote: String?
    @objc dynamic var taskid: String?
}
