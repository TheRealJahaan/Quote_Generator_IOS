import Foundation
import SwiftData


@Model
//Because this class is marked with |@Model|, SwiftData will automatically manage it as a database model. You don't have to write SQL, create tables manually, or map columns yourself. Under the hood, SwiftData handles persistence, which is one of those rare moments where software actually saves you work instead of inventing new ways to configure it.
class User {

    var fullName: String
    var email: String
    var password: String

    init(
        fullName: String,
        email: String,
        password: String
    ) {
        self.fullName = fullName
        self.email = email
        self.password = password
    }
}
