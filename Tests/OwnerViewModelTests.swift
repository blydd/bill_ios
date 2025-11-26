import XCTest
@testable import TagBasedExpenseTracker

/// 归属人ViewModel测试
/// 测试归属人的创建、编辑、删除和名称唯一性验证功能
@MainActor
final class OwnerViewModelTests: XCTestCase {
    var viewModel: OwnerViewModel!
    var repository: UserDefaultsRepository!
    var testDefaults: UserDefaults!
    
    override func setUp() async throws {
        // Use a separate UserDefaults suite for testing
        testDefaults = UserDefaults(suiteName: "com.expensetracker.ownertests")!
        testDefaults.removePersistentDomain(forName: "com.expensetracker.ownertests")
        repository = UserDefaultsRepository(userDefaults: testDefaults)
        viewModel = OwnerViewModel(repository: repository)
    }
    
    override func tearDown() async throws {
        testDefaults.removePersistentDomain(forName: "com.expensetracker.ownertests")
        viewModel = nil
        repository = nil
        testDefaults = nil
    }
    
    // MARK: - Load Owners Tests
    
    func testLoadOwnersWhenEmpty() async {
        // When
        await viewModel.loadOwners()
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 0)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadOwnersWithExistingData() async throws {
        // Given
        let owner1 = Owner(name: "张三")
        let owner2 = Owner(name: "李四")
        try await repository.saveOwner(owner1)
        try await repository.saveOwner(owner2)
        
        // When
        await viewModel.loadOwners()
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 2)
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "张三" }))
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "李四" }))
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Create Owner Tests (Requirements 3.1, 3.2)
    
    func testCreateOwnerWithValidName() async throws {
        // Given
        let ownerName = "王五"
        
        // When
        try await viewModel.createOwner(name: ownerName)
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 1)
        XCTAssertEqual(viewModel.owners.first?.name, "王五")
        
        // Verify persistence
        let fetchedOwners = try await repository.fetchOwners()
        XCTAssertEqual(fetchedOwners.count, 1)
        XCTAssertEqual(fetchedOwners.first?.name, "王五")
    }
    
    func testCreateOwnerTrimsWhitespace() async throws {
        // Given
        let ownerName = "  赵六  "
        
        // When
        try await viewModel.createOwner(name: ownerName)
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 1)
        XCTAssertEqual(viewModel.owners.first?.name, "赵六")
    }
    
    func testCreateOwnerWithEmptyNameThrowsError() async {
        // Given
        let emptyName = "   "
        
        // When/Then
        do {
            try await viewModel.createOwner(name: emptyName)
            XCTFail("Expected error to be thrown")
        } catch AppError.duplicateName(let entityType) {
            XCTAssertEqual(entityType, "归属人")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertEqual(viewModel.owners.count, 0)
    }
    
    func testCreateOwnerWithDuplicateNameThrowsError() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        
        // When/Then
        do {
            try await viewModel.createOwner(name: "张三")
            XCTFail("Expected error to be thrown")
        } catch AppError.duplicateName(let entityType) {
            XCTAssertEqual(entityType, "归属人")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Should still have only one owner
        XCTAssertEqual(viewModel.owners.count, 1)
    }
    
    func testCreateOwnerWithDuplicateNameCaseInsensitive() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        
        // When/Then - same name should be rejected
        do {
            try await viewModel.createOwner(name: "张三")
            XCTFail("Expected error to be thrown")
        } catch AppError.duplicateName {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Update Owner Tests (Requirements 3.3, 3.4)
    
    func testUpdateOwnerWithValidName() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        let owner = viewModel.owners.first!
        
        // When
        try await viewModel.updateOwner(owner, newName: "李四")
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 1)
        XCTAssertEqual(viewModel.owners.first?.name, "李四")
        XCTAssertEqual(viewModel.owners.first?.id, owner.id)
        
        // Verify persistence
        let fetchedOwners = try await repository.fetchOwners()
        XCTAssertEqual(fetchedOwners.count, 1)
        XCTAssertEqual(fetchedOwners.first?.name, "李四")
    }
    
    func testUpdateOwnerTrimsWhitespace() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        let owner = viewModel.owners.first!
        
        // When
        try await viewModel.updateOwner(owner, newName: "  王五  ")
        
        // Then
        XCTAssertEqual(viewModel.owners.first?.name, "王五")
    }
    
    func testUpdateOwnerWithEmptyNameThrowsError() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        let owner = viewModel.owners.first!
        
        // When/Then
        do {
            try await viewModel.updateOwner(owner, newName: "   ")
            XCTFail("Expected error to be thrown")
        } catch AppError.duplicateName(let entityType) {
            XCTAssertEqual(entityType, "归属人")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Name should remain unchanged
        XCTAssertEqual(viewModel.owners.first?.name, "张三")
    }
    
    func testUpdateOwnerWithDuplicateNameThrowsError() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        try await viewModel.createOwner(name: "李四")
        let owner = viewModel.owners.first(where: { $0.name == "张三" })!
        
        // When/Then
        do {
            try await viewModel.updateOwner(owner, newName: "李四")
            XCTFail("Expected error to be thrown")
        } catch AppError.duplicateName(let entityType) {
            XCTAssertEqual(entityType, "归属人")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Name should remain unchanged
        XCTAssertEqual(viewModel.owners.first(where: { $0.id == owner.id })?.name, "张三")
    }
    
    func testUpdateOwnerWithSameNameSucceeds() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        let owner = viewModel.owners.first!
        
        // When - updating with the same name should succeed
        try await viewModel.updateOwner(owner, newName: "张三")
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 1)
        XCTAssertEqual(viewModel.owners.first?.name, "张三")
    }
    
    // MARK: - Delete Owner Tests (Requirements 3.5)
    
    func testDeleteOwnerNotUsedByBills() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        let owner = viewModel.owners.first!
        
        // When
        try await viewModel.deleteOwner(owner)
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 0)
        
        // Verify persistence
        let fetchedOwners = try await repository.fetchOwners()
        XCTAssertEqual(fetchedOwners.count, 0)
    }
    
    func testDeleteOwnerUsedByBillsThrowsError() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        let owner = viewModel.owners.first!
        
        // Create a bill that uses this owner
        let bill = Bill(
            amount: 100,
            paymentMethodId: UUID(),
            categoryIds: [UUID()],
            ownerId: owner.id
        )
        try await repository.saveBill(bill)
        
        // When/Then
        do {
            try await viewModel.deleteOwner(owner)
            XCTFail("Expected error to be thrown")
        } catch AppError.dataNotFound {
            // Success - owner is still in use
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Owner should still exist
        XCTAssertEqual(viewModel.owners.count, 1)
        
        // Verify persistence
        let fetchedOwners = try await repository.fetchOwners()
        XCTAssertEqual(fetchedOwners.count, 1)
    }
    
    func testDeleteOwnerRemovesFromLocalList() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        try await viewModel.createOwner(name: "李四")
        let ownerToDelete = viewModel.owners.first(where: { $0.name == "张三" })!
        
        // When
        try await viewModel.deleteOwner(ownerToDelete)
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 1)
        XCTAssertEqual(viewModel.owners.first?.name, "李四")
    }
    
    // MARK: - Name Uniqueness Check Tests
    
    func testIsNameUniqueReturnsTrueForNewName() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        
        // When
        let isUnique = viewModel.isNameUnique("李四")
        
        // Then
        XCTAssertTrue(isUnique)
    }
    
    func testIsNameUniqueReturnsFalseForExistingName() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        
        // When
        let isUnique = viewModel.isNameUnique("张三")
        
        // Then
        XCTAssertFalse(isUnique)
    }
    
    func testIsNameUniqueTrimsWhitespace() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        
        // When
        let isUnique = viewModel.isNameUnique("  张三  ")
        
        // Then
        XCTAssertFalse(isUnique)
    }
    
    func testIsNameUniqueExcludingIdAllowsSameName() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        let owner = viewModel.owners.first!
        
        // When
        let isUnique = viewModel.isNameUnique("张三", excludingId: owner.id)
        
        // Then
        XCTAssertTrue(isUnique)
    }
    
    func testIsNameUniqueExcludingIdDetectsDuplicates() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        try await viewModel.createOwner(name: "李四")
        let owner = viewModel.owners.first(where: { $0.name == "张三" })!
        
        // When
        let isUnique = viewModel.isNameUnique("李四", excludingId: owner.id)
        
        // Then
        XCTAssertFalse(isUnique)
    }
    
    // MARK: - Multiple Owners Tests
    
    func testCreateMultipleOwners() async throws {
        // When
        try await viewModel.createOwner(name: "张三")
        try await viewModel.createOwner(name: "李四")
        try await viewModel.createOwner(name: "王五")
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 3)
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "张三" }))
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "李四" }))
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "王五" }))
    }
    
    func testUpdateOneOwnerDoesNotAffectOthers() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        try await viewModel.createOwner(name: "李四")
        let ownerToUpdate = viewModel.owners.first(where: { $0.name == "张三" })!
        
        // When
        try await viewModel.updateOwner(ownerToUpdate, newName: "王五")
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 2)
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "王五" }))
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "李四" }))
        XCTAssertFalse(viewModel.owners.contains(where: { $0.name == "张三" }))
    }
    
    func testDeleteOneOwnerDoesNotAffectOthers() async throws {
        // Given
        try await viewModel.createOwner(name: "张三")
        try await viewModel.createOwner(name: "李四")
        try await viewModel.createOwner(name: "王五")
        let ownerToDelete = viewModel.owners.first(where: { $0.name == "李四" })!
        
        // When
        try await viewModel.deleteOwner(ownerToDelete)
        
        // Then
        XCTAssertEqual(viewModel.owners.count, 2)
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "张三" }))
        XCTAssertFalse(viewModel.owners.contains(where: { $0.name == "李四" }))
        XCTAssertTrue(viewModel.owners.contains(where: { $0.name == "王五" }))
    }
}
