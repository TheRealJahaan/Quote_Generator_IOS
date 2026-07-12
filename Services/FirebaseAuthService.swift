import Foundation
import FirebaseAuth

final class FirebaseAuthService {

    static let shared = FirebaseAuthService()

    private init() { }

    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    ) {

        Auth.auth().createUser(
            withEmail: email,
            password: password
        ) { result, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user else {
                return
            }

            completion(.success(user))
        }
    }
}
