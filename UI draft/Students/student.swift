import Foundation

struct Student: Identifiable {
    let id: String
    let name: String
    let studentClass: String

    var dateOfBirth: String?
    var gender: String?
    var height: String?
    var weight: String?
    var qrCodeString: String?

    var sitUps: String?
    var pushUps: String?
    var pullUps: String?
    var shuttleRun: String?
    var standingBroadJump: String?
    var sitAndReach: String?
    var run24km: String?
}
