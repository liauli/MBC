@testable import MBC
import XCTest

final class CardSerializerTests: XCTestCase {
    private var sut: CardSerializer!

    override func setUp() {
        super.setUp()
        sut = CardSerializer()
    }

    func test_serializeDeserialize_roundtrip_idleCard() throws {
        // Given
        let expectedCard = makeIdleCard()

        // When
        let data = try sut.serialize(expectedCard)
        let result = try sut.deserialize(data)

        // Then
        XCTAssertEqual(result, expectedCard)
    }

    func test_serializeDeserialize_roundtrip_checkedInCard() throws {
        // Given
        let checkInTime = Date(timeIntervalSince1970: 1_700_000_000)
        let expectedCard = MemberCard(
            identity: MemberIdentity(
                memberID: "MBC-0001",
                name: "Ahmad Sudirman",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: 50000, lastTopUpAmount: 50000),
            visitState: .checkedIn(time: checkInTime, isSimulated: false),
            transactions: [
                Transaction(type: .topUp, amount: 50000, timestamp: Date(timeIntervalSince1970: 1_690_000_100)),
            ],
            writeCounter: 3
        )

        // When
        let data = try sut.serialize(expectedCard)
        let result = try sut.deserialize(data)

        // Then
        XCTAssertEqual(result, expectedCard)
    }

    func test_serializeDeserialize_roundtrip_simulatedCheckIn() throws {
        // Given
        let expectedCard = MemberCard(
            identity: MemberIdentity(
                memberID: "MBC-0002",
                name: "Budi",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: 10000, lastTopUpAmount: 10000),
            visitState: .checkedIn(time: Date(timeIntervalSince1970: 1_700_000_000), isSimulated: true),
            transactions: [],
            writeCounter: 1
        )

        // When
        let data = try sut.serialize(expectedCard)
        let result = try sut.deserialize(data)

        // Then
        XCTAssertEqual(result, expectedCard)
    }

    func test_serializeDeserialize_maxTransactions_keepsFIFO() throws {
        // Given
        let transactions = (0 ..< 7).map { index in
            Transaction(
                type: .topUp,
                amount: 1000 * (index + 1),
                timestamp: Date(timeIntervalSince1970: Double(1_690_000_000 + index * 100))
            )
        }
        let card = MemberCard(
            identity: MemberIdentity(
                memberID: "MBC-0003",
                name: "Citra",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: 28000, lastTopUpAmount: 7000),
            visitState: .idle,
            transactions: transactions,
            writeCounter: 7
        )

        // When
        let data = try sut.serialize(card)
        let result = try sut.deserialize(data)

        // Then
        XCTAssertEqual(result.transactions.count, 5)
        XCTAssertEqual(result.transactions.first?.amount, 3000)
        XCTAssertEqual(result.transactions.last?.amount, 7000)
    }

    func test_deserialize_invalidData_throws() {
        // Given
        let invalidData = Data([0x00, 0x01])

        // When / Then
        XCTAssertThrowsError(try sut.deserialize(invalidData)) { error in
            XCTAssertEqual(error as? MBCError, .deserializationFailed)
        }
    }

    func test_serializeDeserialize_zeroBalance() throws {
        // Given
        let expectedCard = MemberCard(
            identity: MemberIdentity(
                memberID: "MBC-0004",
                name: "Dewi",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: 0, lastTopUpAmount: 0),
            visitState: .idle,
            transactions: [],
            writeCounter: 0
        )

        // When
        let data = try sut.serialize(expectedCard)
        let result = try sut.deserialize(data)

        // Then
        XCTAssertEqual(result, expectedCard)
    }

    // MARK: - Helpers

    private func makeIdleCard() -> MemberCard {
        MemberCard(
            identity: MemberIdentity(
                memberID: "MBC-0001",
                name: "Ahmad Sudirman",
                registeredDate: Date(timeIntervalSince1970: 1_690_000_000)
            ),
            wallet: Wallet(balance: 48000, lastTopUpAmount: 50000),
            visitState: .idle,
            transactions: [
                Transaction(type: .topUp, amount: 50000, timestamp: Date(timeIntervalSince1970: 1_690_000_100)),
                Transaction(type: .checkIn, amount: 0, timestamp: Date(timeIntervalSince1970: 1_690_000_200)),
                Transaction(type: .checkOut, amount: 2000, timestamp: Date(timeIntervalSince1970: 1_690_000_300)),
            ],
            writeCounter: 5
        )
    }
}
