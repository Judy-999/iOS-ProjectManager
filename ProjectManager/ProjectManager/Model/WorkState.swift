//
//  WorkState.swift
//  ProjectManager
//
//  Created by Judy on 2022/09/15.
//

enum WorkState: String, CaseIterable {
    case todo = "TODO"
    case doing = "DOING"
    case done = "DONE"
    var title: String {
        switch self {
        case .todo:
            return "TODO"
        case .doing:
            return "DOING"
        case .done:
            return "DONE"
        }
    }
}
