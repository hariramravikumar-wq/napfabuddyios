//
//  student.swift
//  UI draft
//
//  Created by Hariram Ravikumar on 23/6/26.
//

import Foundation

struct Student: Identifiable {
    let id: String
    let name: String
    let studentClass: String
    
    var sitUps: String?
    var pushUps: String?
    var pullUps: String?
    var shuttleRun: String?
    var standingBroadJump: String?
    var run24km: String?
}
