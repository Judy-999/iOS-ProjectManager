//
//  Work.swift
//  ProjectManager
//
//  Created by Judy on 2022/09/07.
//

import Foundation

struct Work {
    let id: UUID
    let title: String
    let content: String
    let deadline: Date
    let state: WorkState
}
