import XCTest
@testable import TagBasedExpenseTracker

/// BillViewModel单元测试
/// 测试账单管理和筛选功能
final class BillViewModelTests: XCTestCase {
    
    var repository: UserDefaultsRepository!
    var viewModel: BillViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        let testDefaults = UserDefaults(suiteName: "com.expensetracker.billvm.\(UUID().uuidString)")!
        repository = UserDefaultsRepository(userDefaults: testDefaults)
        viewModel = await BillViewModel(repository: repository)
    }
    
    override func tearDown() async throws {
        if let suiteName = repository.userDefaults.dictionaryRepresentation().keys.first {
            repository.userDefaults.removePersistentDomain(forName: suiteName)
        }
        repository = nil
        viewModel = nil
        try await super.tearDown()
    }
    
    // MARK: - Filter Tests
    // Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6
    
    /// 测试按账单类型筛选
    /// Requirement 7.1: 按账单类型筛选账单，返回包含任一所选类型的所有账单记录
    @MainActor
    func testFilterBillsByCategory() async throws {
        // Given
        let category1 = UUID()
        let category2 = UUID()
        let category3 = UUID()
        
        let bill1 = Bill(amount: 100, paymentMethodId: UUID(), categoryIds: [category1], ownerId: UUID())
        let bill2 = Bill(amount: 200, paymentMethodId: UUID(), categoryIds: [category2], ownerId: UUID())
        let bill3 = Bill(amount: 300, paymentMethodId: UUID(), categoryIds: [category1, category2], ownerId: UUID())
        let bill4 = Bill(amount: 400, paymentMethodId: UUID(), categoryIds: [category3], ownerId: UUID())
        
        try await repository.saveBill(bill1)
        try await repository.saveBill(bill2)
        try await repository.saveBill(bill3)
        try await repository.saveBill(bill4)
        
        await viewModel.loadBills()
        
        // When - 筛选包含category1的账单
        let filtered = viewModel.filterBills(categoryIds: [category1])
        
        // Then - 应该返回bill1和bill3
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains { $0.id == bill1.id })
        XCTAssertTrue(filtered.contains { $0.id == bill3.id })
    }
