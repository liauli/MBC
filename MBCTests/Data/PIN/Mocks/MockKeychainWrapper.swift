import Foundation
@testable import MBC

final class MockKeychainWrapper: KeychainWrapperProtocol {
    var storage: [String: Data] = [:]
    var saveCalled = false
    var readCalled = false
    var deleteCalled = false

    func save(_ data: Data, for key: String) -> Bool {
        saveCalled = true
        storage[key] = data
        return true
    }

    func read(for key: String) -> Data? {
        readCalled = true
        return storage[key]
    }

    func delete(for key: String) -> Bool {
        deleteCalled = true
        storage.removeValue(forKey: key)
        return true
    }
}
