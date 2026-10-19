import XCTest
@testable import QuoteKit

@MainActor
final class QuoteFeedModelTests: XCTestCase {
    func testStartsOnTheDailyQuote() {
        let daily = makeQuote("daily")
        let model = QuoteFeedModel(repository: QuoteRepository(primary: FailingProvider(), fallback: FailingProvider()), dailyQuote: daily)
        XCTAssertEqual(model.current, daily)
        XCTAssertTrue(model.isShowingDailyQuote)
        XCTAssertFalse(model.canGoBack)
    }

    func testLoadNextThenGoBack() async {
        let repository = QuoteRepository(primary: SequenceProvider([makeQuote("a"), makeQuote("b")]), fallback: FailingProvider())
        let model = QuoteFeedModel(repository: repository, dailyQuote: makeQuote("daily"))

        await model.loadNext()
        XCTAssertEqual(model.current.id, "a")
        XCTAssertEqual(model.source, .remote)
        await model.loadNext()
        XCTAssertEqual(model.current.id, "b")
        XCTAssertFalse(model.isLoading)

        model.goBack()
        XCTAssertEqual(model.current.id, "a")
        model.goBack()
        XCTAssertTrue(model.isShowingDailyQuote)
        XCTAssertFalse(model.canGoBack)
    }

    func testHistoryIsCapped() async {
        let quotes = (0..<10).map { makeQuote("q\($0)") }
        let repository = QuoteRepository(primary: SequenceProvider(quotes), fallback: FailingProvider())
        let model = QuoteFeedModel(repository: repository, dailyQuote: makeQuote("daily"), historyLimit: 3)
        for _ in 0..<6 { await model.loadNext() }
        XCTAssertEqual(model.history.count, 3)
    }
}

@MainActor
final class SessionModelTests: XCTestCase {
    private func makeModel(guest: Bool = false) -> (SessionModel, InMemoryAuthService) {
        let auth = InMemoryAuthService()
        auth.register(email: "ana@example.com", password: "abc12345", displayName: "Ana")
        return (SessionModel(auth: auth, guestStore: InMemoryGuestModeStore(isGuest: guest)), auth)
    }

    func testValidationErrorsSkipTheBackend() async {
        let (model, auth) = makeModel()
        await model.signIn(email: "not-an-email", password: "abc12345")
        XCTAssertEqual(model.errorMessage, ValidationError.invalidEmail.message)
        XCTAssertNil(auth.currentUser)
    }

    func testSignInSucceedsWithNormalizedEmail() async {
        let (model, _) = makeModel()
        await model.signIn(email: "  Ana@Example.com ", password: "abc12345")
        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.currentUser?.displayName, "Ana")
    }

    func testWrongPasswordShowsFriendlyMessage() async {
        let (model, _) = makeModel()
        await model.signIn(email: "ana@example.com", password: "wrong999")
        XCTAssertEqual(model.errorMessage, AuthFailure.wrongCredentials.message)
        XCTAssertNil(model.currentUser)
    }

    func testSignUpThenDuplicateIsRejected() async {
        let (model, _) = makeModel()
        await model.signUp(name: "Ben", email: "ben@example.com", password: "pass1234", confirmation: "pass1234")
        XCTAssertEqual(model.currentUser?.firstName, "Ben")

        model.signOut()
        XCTAssertEqual(model.state, .signedOut)
        await model.signUp(name: "Ben", email: "ben@example.com", password: "pass1234", confirmation: "pass1234")
        XCTAssertEqual(model.errorMessage, AuthFailure.emailAlreadyInUse.message)
    }

    func testGuestModeAndLeavingIt() {
        let (model, _) = makeModel()
        model.continueAsGuest()
        XCTAssertEqual(model.currentUser, .guest)
        model.signOut()
        XCTAssertEqual(model.state, .signedOut)
    }

    func testPasswordResetSetsInfoMessage() async {
        let (model, auth) = makeModel()
        let sent = await model.sendPasswordReset(email: "Ana@example.com")
        XCTAssertTrue(sent)
        XCTAssertEqual(auth.passwordResetRequests, ["ana@example.com"])
        XCTAssertNotNil(model.infoMessage)
    }

    func testDeleteAccountSignsOut() async {
        let (model, _) = makeModel()
        await model.signIn(email: "ana@example.com", password: "abc12345")
        let deleted = await model.deleteAccount()
        XCTAssertTrue(deleted)
        XCTAssertEqual(model.state, .signedOut)

        await model.signIn(email: "ana@example.com", password: "abc12345")
        XCTAssertEqual(model.errorMessage, AuthFailure.wrongCredentials.message)
    }

    func testObservingRestoresGuestSession() async {
        let (model, _) = makeModel(guest: true)
        let task = Task { await model.observeAuthState() }
        for _ in 0..<50 where model.state == .loading {
            await Task.yield()
        }
        task.cancel()
        XCTAssertEqual(model.state, .signedIn(.guest))
    }
}
