@testable import MBC
import XCTest

final class RegisterMemberUseCaseTests: XCTestCase {
    private var sut: RegisterMemberUseCase!
    private var mockRepository: MockCardRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardRepository()
        sut = RegisterMemberUseCase(repository: mockRepository)
    }

    func test_execute_validName_writesCardAndReturns() {
        // Given
        mockRepository.writeCardResult = .success(())

        // When
        var result: Result<MemberCard, MBCError>?
        sut.execute(name: "Ahmad") { result = $0 }

        // Then
        switch result {
        case let .success(card):
            XCTAssertEqual(card.identity.name, "Ahmad")
            XCTAssertEqual(card.wallet.balance, 0)
            XCTAssertEqual(card.visitState, .idle)
            XCTAssertFalse(card.identity.memberID.isEmpty)
        default:
            XCTFail("Expected success")
        }
        XCTAssertNotNil(mockRepository.writtenCard)
    }

    func test_execute_trimsWhitespace() {
        // Given
        mockRepository.writeCardResult = .success(())

        // When
        var result: Result<MemberCard, MBCError>?
        sut.execute(name: "  Budi  ") { result = $0 }

        // Then
        if case let .success(card) = result {
            XCTAssertEqual(card.identity.name, "Budi")
        } else {
            XCTFail("Expected success")
        }
    }

    func test_execute_emptyName_fails() {
        // When
        var error: MBCError?
        sut.execute(name: "   ") { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidName)
        XCTAssertNil(mockRepository.writtenCard)
    }

    func test_execute_nameTooLong_fails() {
        // Given
        let longName = String(repeating: "A", count: 33)

        // When
        var error: MBCError?
        sut.execute(name: longName) { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .invalidName)
    }

    func test_execute_nfcWriteFails_returnsError() {
        // Given
        mockRepository.writeCardResult = .failure(.nfcWriteFailed)

        // When
        var error: MBCError?
        sut.execute(name: "Citra") { if case let .failure(e) = $0 { error = e } }

        // Then
        XCTAssertEqual(error, .nfcWriteFailed)
    }
}
