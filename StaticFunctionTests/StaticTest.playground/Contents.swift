import UIKit
import XCTest

enum Status {
    case stale, running
}

/// Adding unit test for static functions - a possibility using some dummy code
struct StatusCheck {
    static func getStatus(completion: @escaping (Status) -> ()) {
        // Simplifying what this could be, like a static async call
        completion(.running)
    }
}

protocol StatusFetcherProtocol {
    typealias StatusFetcher = ((@escaping (Status) -> ()) -> Void)
    var statusFetcher: StatusFetcher { get set }
    init(statusFetcher: @escaping StatusFetcher)
}

class StatusManager: StatusFetcherProtocol {

    var statusFetcher: StatusFetcher
    required init(statusFetcher: @escaping StatusFetcher = StatusCheck.getStatus) {
        self.statusFetcher = statusFetcher
    }

    func getStatus(completion: @escaping (Bool) -> Void) {
        self.statusFetcher { status in
            if status == .running {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

// MARK: Mocks

struct StatusCheckMock {

    static var statusCalled = 0
    static var statusToReturn: Status = .running
    static func getStatus(completion: @escaping (Status) -> ()) {
        StatusCheckMock.statusCalled += 1
        completion(StatusCheckMock.statusToReturn)
    }
}

// MARK: Tests

class StatusCheckTest: XCTestCase {

    override func tearDown() {
        super.tearDown()
        StatusCheckMock.statusCalled = 0
    }

    func test_running() {
        let expectation = self.expectation(description: "expectation")
        let sut = StatusManager(statusFetcher: StatusCheckMock.getStatus)

        sut.getStatus(completion: { isRunning in
            XCTAssertTrue(isRunning)
            XCTAssertEqual(StatusCheckMock.statusCalled, 1)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 2, handler: nil)
    }

    func test_stale() {
        let expectation = self.expectation(description: "expectation")
        let sut = StatusManager(statusFetcher: StatusCheckMock.getStatus)
        StatusCheckMock.statusToReturn = .stale

        sut.getStatus(completion: { isRunning in
            XCTAssertFalse(isRunning)
            XCTAssertEqual(StatusCheckMock.statusCalled, 1)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 2, handler: nil)
    }
}

StatusCheckTest.defaultTestSuite.run()

class TestObserver: NSObject, XCTestObservation {
    private func testCase(_ testCase: XCTestCase,
                  didFailWithDescription description: String,
                  inFile filePath: String?,
                  atLine lineNumber: UInt) {
        assertionFailure(description, line: lineNumber)
    }
}
let testObserver = TestObserver()
XCTestObservationCenter.shared.addTestObserver(testObserver)
