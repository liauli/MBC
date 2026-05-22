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

    func test_execute_validName_writesCardAndReturns() async throws {
        // Given
        mockRepository.writeCardResult = .success(())

        // When
        let card = try await sut.execute(name: "Ahmad")

        // Then
        XCTAssertEqual(card.identity.name, "Ahmad")
        XCTAssertEqual(card.wallet.balance, 0)
        XCTAssertEqual(card.visitState, .idle)
        XCTAssertFalse(card.identity.memberID.isEmpty)
        XCTAssertNotNil(mockRepository.writtenCard)
    }

    func test_execute_emptyName_throws() async {
        do {
            _ = try await sut.execute(name: "   ")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .invalidName)
        }
    }

    func test_execute_nameTooLong_throws() async {
        do {
            _ = try await sut.execute(name: String(repeating: "A", count: 33))
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .invalidName)
        }
    }

    func test_execute_nfcWriteFails_throws() async {
        // Given
        mockRepository.writeCardResult = .failure(.nfcWriteFailed)

        // When / Then
        do {
            _ = try await sut.execute(name: "Citra")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(error as? MBCError, .nfcWriteFailed)
        }
    }
}
