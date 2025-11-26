import XCTest
@testable import TagBasedExpenseTracker

final class RepositoryTests: XCTestCase {
    var repository: UserDefaultsRepository!
    var testDefaults: UserDefaults!
    
    override func setUp() async throws {
        // Use a separate UserDefaults suite for testing
        testDefaults = UserDefaults(suiteName: "com.expensetracker.tests")!
        testDefaults.removePersistentDomain(forName: "com.expensetracker.tests")
        repository = UserDefaultsRepository(userDefaults: testDefaults)
    }
    
    override func tearDown() async throws {
        testDefaults.removePersistentDomain(forName: "com.expensetracker.tests")
        repository = nil
        testDefaults = nil
    }
    
    // MARK: - Bill Tests
    
    func testSaveAndFetchBill() async throws {
        // Given
        let bill = Bill(
            amount: 100.50,
            paymentMethodId: UUID(),
            categoryIds: [UUID()],
            ownerId: UUID()
        )
        
        // When
        try await repository.saveBill(bill)
        let fetchedBills = try await repository.fetchBills()
        
        // Then
        XCTAssertEqual(fetchedBills.count, 1)
        XCTAssertEqual(fetchedBills.first?.id, bill.id)
        XCTAssertEqual(fetchedBills.first?.amount, bill.amount)
    }
    
    func testUpdateBill() async throws {
        // Given
        var bill = Bill(
            amount: 100.50,
            paymentMethodId: UUID(),
            categoryIds: [UUID()],
            ownerId: UUID()
        )
        try await repository.saveBill(bill)
        
        // When
        bill.amount = 200.75
        try await repository.updateBill(bill)
        let fetchedBills = try await repository.fetchBills()
        
        // Then
        XCTAssertEqual(fetchedBills.count, 1)
        XCTAssertEqual(fetchedBills.first?.amount, 200.75)
    }
    
    func testDeleteBill() async throws {
        // Given
        let bill = Bill(
            amount: 100.50,
            paymentMethodId: UUID(),
            categoryIds: [UUID()],
            ownerId: UUID()
        )
        try await repository.saveBill(bill)
        
        // When
        try await repository.deleteBill(bill)
        let fetchedBills = try await repository.fetchBills()
        
        // Then
        XCTAssertEqual(fetchedBills.count, 0)
    }
    
    func testFetchBillById() async throws {
        // Given
        let bill = Bill(
            amount: 100.50,
            paymentMethodId: UUID(),
            categoryIds: [UUID()],
            ownerId: UUID()
        )
        try await repository.saveBill(bill)
        
        // When
        let fetchedBill = try await repository.fetchBill(by: bill.id)
        
        // Then
        XCTAssertNotNil(fetchedBill)
        XCTAssertEqual(fetchedBill?.id, bill.id)
    }
    
    func testUpdateNonExistentBillThrowsError() async throws {
        // Given
        let bill = Bill(
            amount: 100.50,
            paymentMethodId: UUID(),
            categoryIds: [UUID()],
            ownerId: UUID()
        )
        
        // When/Then
        do {
            try await repository.updateBill(bill)
            XCTFail("Expected error to be thrown")
        } catch RepositoryError.notFound {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - PaymentMethod Tests
    
    func testSaveAndFetchCreditMethod() async throws {
        // Given
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 15
        )
        let wrapper = PaymentMethodWrapper.credit(creditMethod)
        
        // When
        try await repository.savePaymentMethod(wrapper)
        let fetchedMethods = try await repository.fetchPaymentMethods()
        
        // Then
        XCTAssertEqual(fetchedMethods.count, 1)
        XCTAssertEqual(fetchedMethods.first?.id, creditMethod.id)
        XCTAssertEqual(fetchedMethods.first?.name, "信用卡")
    }
    
    func testSaveAndFetchSavingsMethod() async throws {
        // Given
        let savingsMethod = SavingsMethod(
            name: "储蓄卡",
            transactionType: .expense,
            balance: 5000
        )
        let wrapper = PaymentMethodWrapper.savings(savingsMethod)
        
        // When
        try await repository.savePaymentMethod(wrapper)
        let fetchedMethods = try await repository.fetchPaymentMethods()
        
        // Then
        XCTAssertEqual(fetchedMethods.count, 1)
        XCTAssertEqual(fetchedMethods.first?.id, savingsMethod.id)
        XCTAssertEqual(fetchedMethods.first?.name, "储蓄卡")
    }
    
    func testUpdatePaymentMethod() async throws {
        // Given
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 15
        )
        var wrapper = PaymentMethodWrapper.credit(creditMethod)
        try await repository.savePaymentMethod(wrapper)
        
        // When
        wrapper.name = "新信用卡"
        try await repository.updatePaymentMethod(wrapper)
        let fetchedMethods = try await repository.fetchPaymentMethods()
        
        // Then
        XCTAssertEqual(fetchedMethods.count, 1)
        XCTAssertEqual(fetchedMethods.first?.name, "新信用卡")
    }
    
    func testDeletePaymentMethod() async throws {
        // Given
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 15
        )
        let wrapper = PaymentMethodWrapper.credit(creditMethod)
        try await repository.savePaymentMethod(wrapper)
        
        // When
        try await repository.deletePaymentMethod(wrapper)
        let fetchedMethods = try await repository.fetchPaymentMethods()
        
        // Then
        XCTAssertEqual(fetchedMethods.count, 0)
    }
    
    // MARK: - BillCategory Tests
    
    func testSaveAndFetchCategory() async throws {
        // Given
        let category = BillCategory(name: "餐饮")
        
        // When
        try await repository.saveCategory(category)
        let fetchedCategories = try await repository.fetchCategories()
        
        // Then
        XCTAssertEqual(fetchedCategories.count, 1)
        XCTAssertEqual(fetchedCategories.first?.id, category.id)
        XCTAssertEqual(fetchedCategories.first?.name, "餐饮")
    }
    
    func testUpdateCategory() async throws {
        // Given
        var category = BillCategory(name: "餐饮")
        try await repository.saveCategory(category)
        
        // When
        category.name = "食品"
        try await repository.updateCategory(category)
        let fetchedCategories = try await repository.fetchCategories()
        
        // Then
        XCTAssertEqual(fetchedCategories.count, 1)
        XCTAssertEqual(fetchedCategories.first?.name, "食品")
    }
    
    func testDeleteCategory() async throws {
        // Given
        let category = BillCategory(name: "餐饮")
        try await repository.saveCategory(category)
        
        // When
        try await repository.deleteCategory(category)
        let fetchedCategories = try await repository.fetchCategories()
        
        // Then
        XCTAssertEqual(fetchedCategories.count, 0)
    }
    
    // MARK: - Owner Tests
    
    func testSaveAndFetchOwner() async throws {
        // Given
        let owner = Owner(name: "张三")
        
        // When
        try await repository.saveOwner(owner)
        let fetchedOwners = try await repository.fetchOwners()
        
        // Then
        XCTAssertEqual(fetchedOwners.count, 1)
        XCTAssertEqual(fetchedOwners.first?.id, owner.id)
        XCTAssertEqual(fetchedOwners.first?.name, "张三")
    }
    
    func testUpdateOwner() async throws {
        // Given
        var owner = Owner(name: "张三")
        try await repository.saveOwner(owner)
        
        // When
        owner.name = "李四"
        try await repository.updateOwner(owner)
        let fetchedOwners = try await repository.fetchOwners()
        
        // Then
        XCTAssertEqual(fetchedOwners.count, 1)
        XCTAssertEqual(fetchedOwners.first?.name, "李四")
    }
    
    func testDeleteOwner() async throws {
        // Given
        let owner = Owner(name: "张三")
        try await repository.saveOwner(owner)
        
        // When
        try await repository.deleteOwner(owner)
        let fetchedOwners = try await repository.fetchOwners()
        
        // Then
        XCTAssertEqual(fetchedOwners.count, 0)
    }
    
    // MARK: - Multiple Items Tests
    
    func testSaveMultipleBills() async throws {
        // Given
        let bill1 = Bill(amount: 100, paymentMethodId: UUID(), categoryIds: [UUID()], ownerId: UUID())
        let bill2 = Bill(amount: 200, paymentMethodId: UUID(), categoryIds: [UUID()], ownerId: UUID())
        let bill3 = Bill(amount: 300, paymentMethodId: UUID(), categoryIds: [UUID()], ownerId: UUID())
        
        // When
        try await repository.saveBill(bill1)
        try await repository.saveBill(bill2)
        try await repository.saveBill(bill3)
        let fetchedBills = try await repository.fetchBills()
        
        // Then
        XCTAssertEqual(fetchedBills.count, 3)
    }
    
    func testFetchEmptyBills() async throws {
        // When
        let fetchedBills = try await repository.fetchBills()
        
        // Then
        XCTAssertEqual(fetchedBills.count, 0)
    }
    
    // MARK: - Query and Filtering Tests
    
    func testFetchBillByIdReturnsNilForNonExistent() async throws {
        // Given
        let nonExistentId = UUID()
        
        // When
        let fetchedBill = try await repository.fetchBill(by: nonExistentId)
        
        // Then
        XCTAssertNil(fetchedBill)
    }
    
    func testFetchPaymentMethodById() async throws {
        // Given
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 15
        )
        let wrapper = PaymentMethodWrapper.credit(creditMethod)
        try await repository.savePaymentMethod(wrapper)
        
        // When
        let fetchedMethod = try await repository.fetchPaymentMethod(by: creditMethod.id)
        
        // Then
        XCTAssertNotNil(fetchedMethod)
        XCTAssertEqual(fetchedMethod?.id, creditMethod.id)
        XCTAssertEqual(fetchedMethod?.name, "信用卡")
    }
    
    func testFetchCategoryById() async throws {
        // Given
        let category = BillCategory(name: "餐饮")
        try await repository.saveCategory(category)
        
        // When
        let fetchedCategory = try await repository.fetchCategory(by: category.id)
        
        // Then
        XCTAssertNotNil(fetchedCategory)
        XCTAssertEqual(fetchedCategory?.id, category.id)
        XCTAssertEqual(fetchedCategory?.name, "餐饮")
    }
    
    func testFetchOwnerById() async throws {
        // Given
        let owner = Owner(name: "张三")
        try await repository.saveOwner(owner)
        
        // When
        let fetchedOwner = try await repository.fetchOwner(by: owner.id)
        
        // Then
        XCTAssertNotNil(fetchedOwner)
        XCTAssertEqual(fetchedOwner?.id, owner.id)
        XCTAssertEqual(fetchedOwner?.name, "张三")
    }
    
    func testFetchMultipleCategories() async throws {
        // Given
        let category1 = BillCategory(name: "餐饮")
        let category2 = BillCategory(name: "交通")
        let category3 = BillCategory(name: "娱乐")
        
        // When
        try await repository.saveCategory(category1)
        try await repository.saveCategory(category2)
        try await repository.saveCategory(category3)
        let fetchedCategories = try await repository.fetchCategories()
        
        // Then
        XCTAssertEqual(fetchedCategories.count, 3)
        XCTAssertTrue(fetchedCategories.contains(where: { $0.name == "餐饮" }))
        XCTAssertTrue(fetchedCategories.contains(where: { $0.name == "交通" }))
        XCTAssertTrue(fetchedCategories.contains(where: { $0.name == "娱乐" }))
    }
    
    func testFetchMultipleOwners() async throws {
        // Given
        let owner1 = Owner(name: "张三")
        let owner2 = Owner(name: "李四")
        let owner3 = Owner(name: "王五")
        
        // When
        try await repository.saveOwner(owner1)
        try await repository.saveOwner(owner2)
        try await repository.saveOwner(owner3)
        let fetchedOwners = try await repository.fetchOwners()
        
        // Then
        XCTAssertEqual(fetchedOwners.count, 3)
        XCTAssertTrue(fetchedOwners.contains(where: { $0.name == "张三" }))
        XCTAssertTrue(fetchedOwners.contains(where: { $0.name == "李四" }))
        XCTAssertTrue(fetchedOwners.contains(where: { $0.name == "王五" }))
    }
    
    func testFetchMultiplePaymentMethods() async throws {
        // Given
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 15
        )
        let savingsMethod = SavingsMethod(
            name: "储蓄卡",
            transactionType: .expense,
            balance: 5000
        )
        
        // When
        try await repository.savePaymentMethod(.credit(creditMethod))
        try await repository.savePaymentMethod(.savings(savingsMethod))
        let fetchedMethods = try await repository.fetchPaymentMethods()
        
        // Then
        XCTAssertEqual(fetchedMethods.count, 2)
        XCTAssertTrue(fetchedMethods.contains(where: { $0.name == "信用卡" }))
        XCTAssertTrue(fetchedMethods.contains(where: { $0.name == "储蓄卡" }))
    }
    
    // MARK: - Data Integrity Tests
    
    func testBillDataIntegrityAfterSaveAndFetch() async throws {
        // Given
        let categoryId = UUID()
        let ownerId = UUID()
        let paymentMethodId = UUID()
        let note = "测试备注"
        let amount = Decimal(string: "123.45")!
        let createdAt = Date()
        
        let bill = Bill(
            amount: amount,
            paymentMethodId: paymentMethodId,
            categoryIds: [categoryId],
            ownerId: ownerId,
            note: note,
            createdAt: createdAt,
            updatedAt: createdAt
        )
        
        // When
        try await repository.saveBill(bill)
        let fetchedBill = try await repository.fetchBill(by: bill.id)
        
        // Then
        XCTAssertNotNil(fetchedBill)
        XCTAssertEqual(fetchedBill?.id, bill.id)
        XCTAssertEqual(fetchedBill?.amount, amount)
        XCTAssertEqual(fetchedBill?.paymentMethodId, paymentMethodId)
        XCTAssertEqual(fetchedBill?.categoryIds, [categoryId])
        XCTAssertEqual(fetchedBill?.ownerId, ownerId)
        XCTAssertEqual(fetchedBill?.note, note)
    }
    
    func testCreditMethodDataIntegrityAfterSaveAndFetch() async throws {
        // Given
        let creditMethod = CreditMethod(
            name: "招商银行信用卡",
            transactionType: .expense,
            creditLimit: 50000,
            outstandingBalance: 12345.67,
            billingDate: 25
        )
        let wrapper = PaymentMethodWrapper.credit(creditMethod)
        
        // When
        try await repository.savePaymentMethod(wrapper)
        let fetchedMethod = try await repository.fetchPaymentMethod(by: creditMethod.id)
        
        // Then
        XCTAssertNotNil(fetchedMethod)
        guard case .credit(let fetchedCredit) = fetchedMethod else {
            XCTFail("Expected credit method")
            return
        }
        XCTAssertEqual(fetchedCredit.id, creditMethod.id)
        XCTAssertEqual(fetchedCredit.name, "招商银行信用卡")
        XCTAssertEqual(fetchedCredit.transactionType, .expense)
        XCTAssertEqual(fetchedCredit.creditLimit, 50000)
        XCTAssertEqual(fetchedCredit.outstandingBalance, 12345.67)
        XCTAssertEqual(fetchedCredit.billingDate, 25)
    }
    
    func testSavingsMethodDataIntegrityAfterSaveAndFetch() async throws {
        // Given
        let savingsMethod = SavingsMethod(
            name: "工商银行储蓄卡",
            transactionType: .income,
            balance: 98765.43
        )
        let wrapper = PaymentMethodWrapper.savings(savingsMethod)
        
        // When
        try await repository.savePaymentMethod(wrapper)
        let fetchedMethod = try await repository.fetchPaymentMethod(by: savingsMethod.id)
        
        // Then
        XCTAssertNotNil(fetchedMethod)
        guard case .savings(let fetchedSavings) = fetchedMethod else {
            XCTFail("Expected savings method")
            return
        }
        XCTAssertEqual(fetchedSavings.id, savingsMethod.id)
        XCTAssertEqual(fetchedSavings.name, "工商银行储蓄卡")
        XCTAssertEqual(fetchedSavings.transactionType, .income)
        XCTAssertEqual(fetchedSavings.balance, 98765.43)
    }
    
    func testDeleteBillDoesNotAffectOtherBills() async throws {
        // Given
        let bill1 = Bill(amount: 100, paymentMethodId: UUID(), categoryIds: [UUID()], ownerId: UUID())
        let bill2 = Bill(amount: 200, paymentMethodId: UUID(), categoryIds: [UUID()], ownerId: UUID())
        let bill3 = Bill(amount: 300, paymentMethodId: UUID(), categoryIds: [UUID()], ownerId: UUID())
        
        try await repository.saveBill(bill1)
        try await repository.saveBill(bill2)
        try await repository.saveBill(bill3)
        
        // When
        try await repository.deleteBill(bill2)
        let fetchedBills = try await repository.fetchBills()
        
        // Then
        XCTAssertEqual(fetchedBills.count, 2)
        XCTAssertTrue(fetchedBills.contains(where: { $0.id == bill1.id }))
        XCTAssertFalse(fetchedBills.contains(where: { $0.id == bill2.id }))
        XCTAssertTrue(fetchedBills.contains(where: { $0.id == bill3.id }))
    }
    
    func testUpdateCategoryDoesNotAffectOtherCategories() async throws {
        // Given
        var category1 = BillCategory(name: "餐饮")
        let category2 = BillCategory(name: "交通")
        
        try await repository.saveCategory(category1)
        try await repository.saveCategory(category2)
        
        // When
        category1.name = "食品"
        try await repository.updateCategory(category1)
        let fetchedCategories = try await repository.fetchCategories()
        
        // Then
        XCTAssertEqual(fetchedCategories.count, 2)
        XCTAssertTrue(fetchedCategories.contains(where: { $0.name == "食品" }))
        XCTAssertTrue(fetchedCategories.contains(where: { $0.name == "交通" }))
        XCTAssertFalse(fetchedCategories.contains(where: { $0.name == "餐饮" }))
    }
    
    // MARK: - Edge Cases
    
    func testSaveBillWithMultipleCategories() async throws {
        // Given
        let categoryIds = [UUID(), UUID(), UUID()]
        let bill = Bill(
            amount: 100,
            paymentMethodId: UUID(),
            categoryIds: categoryIds,
            ownerId: UUID()
        )
        
        // When
        try await repository.saveBill(bill)
        let fetchedBill = try await repository.fetchBill(by: bill.id)
        
        // Then
        XCTAssertNotNil(fetchedBill)
        XCTAssertEqual(fetchedBill?.categoryIds.count, 3)
        XCTAssertEqual(fetchedBill?.categoryIds, categoryIds)
    }
    
    func testSaveBillWithEmptyNote() async throws {
        // Given
        let bill = Bill(
            amount: 100,
            paymentMethodId: UUID(),
            categoryIds: [UUID()],
            ownerId: UUID(),
            note: nil
        )
        
        // When
        try await repository.saveBill(bill)
        let fetchedBill = try await repository.fetchBill(by: bill.id)
        
        // Then
        XCTAssertNotNil(fetchedBill)
        XCTAssertNil(fetchedBill?.note)
    }
    
    func testSaveBillWithLargeAmount() async throws {
        // Given
        let largeAmount = Decimal(string: "999999999.99")!
        let bill = Bill(
            amount: largeAmount,
            paymentMethodId: UUID(),
            categoryIds: [UUID()],
            ownerId: UUID()
        )
        
        // When
        try await repository.saveBill(bill)
        let fetchedBill = try await repository.fetchBill(by: bill.id)
        
        // Then
        XCTAssertNotNil(fetchedBill)
        XCTAssertEqual(fetchedBill?.amount, largeAmount)
    }
    
    func testUpdatePaymentMethodPreservesId() async throws {
        // Given
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 15
        )
        var wrapper = PaymentMethodWrapper.credit(creditMethod)
        try await repository.savePaymentMethod(wrapper)
        let originalId = wrapper.id
        
        // When
        wrapper.name = "新名称"
        try await repository.updatePaymentMethod(wrapper)
        let fetchedMethod = try await repository.fetchPaymentMethod(by: originalId)
        
        // Then
        XCTAssertNotNil(fetchedMethod)
        XCTAssertEqual(fetchedMethod?.id, originalId)
        XCTAssertEqual(fetchedMethod?.name, "新名称")
    }
    
    func testFetchEmptyCategories() async throws {
        // When
        let fetchedCategories = try await repository.fetchCategories()
        
        // Then
        XCTAssertEqual(fetchedCategories.count, 0)
    }
    
    func testFetchEmptyOwners() async throws {
        // When
        let fetchedOwners = try await repository.fetchOwners()
        
        // Then
        XCTAssertEqual(fetchedOwners.count, 0)
    }
    
    func testFetchEmptyPaymentMethods() async throws {
        // When
        let fetchedMethods = try await repository.fetchPaymentMethods()
        
        // Then
        XCTAssertEqual(fetchedMethods.count, 0)
    }
}
