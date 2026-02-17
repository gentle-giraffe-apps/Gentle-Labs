// ─────────────────────────────────────────────────────────────
// Testing pattern: Synchronous multi-input validation
// ─────────────────────────────────────────────────────────────
// combineLatest pipelines with no scheduler fire synchronously.
// Set each input, then assert the combined output.
// ─────────────────────────────────────────────────────────────

@testable import CombineRecipes
import XCTest

final class Recipe04_CombineLatestTests: XCTestCase {

    func testBothEmptyIsInvalid() {
        let vm = FormViewModel()
        XCTAssertFalse(vm.isValid)
        XCTAssertEqual(vm.message, "Enter your credentials")
    }

    func testInvalidEmailShowsEmailError() {
        let vm = FormViewModel()
        vm.email = "notanemail"
        vm.password = "123456"
        XCTAssertFalse(vm.isValid)
        XCTAssertEqual(vm.message, "Enter a valid email")
    }

    func testShortPasswordShowsPasswordError() {
        let vm = FormViewModel()
        vm.email = "test@test.com"
        vm.password = "123"
        XCTAssertFalse(vm.isValid)
        XCTAssertEqual(vm.message, "Password must be 6+ characters")
    }

    func testValidCredentialsEnableSubmit() {
        let vm = FormViewModel()
        vm.email = "test@test.com"
        vm.password = "123456"
        XCTAssertTrue(vm.isValid)
        XCTAssertEqual(vm.message, "Ready to submit")
    }
}
