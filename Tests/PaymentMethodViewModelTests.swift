import XCTest
@testable import TagBasedExpenseTracker

/// 支付方式ViewModel测试
/// 测试信贷方式和储蓄方式的创建、编辑、删除和验证功能
@MainActor
final class PaymentMethodViewModelTests: XCTestCase {
    var viewModel: PaymentMethodViewModel!
    var repository: UserDefaultsRepository!
    var testDefaults: UserDefaults!
    
    override func setUp() async throws {
        // Use a separate UserDefaults suite for testing
        testDefaults = UserDefaults(suiteName: "com.expensetracker.paymentmethodtests")!
        testDefaults.removePersistentDomain(forName: "com.expensetracker.paymentmethodtests")
        repository = UserDefaultsRepository(userDefaults: testDefaults)
        viewModel = PaymentMethodViewModel(repository: repository)
    }
    
    override func tearDown() async throws {
        testDefaults.removePersistentDomain(forName: "com.expensetracker.paymentmethodtests")
        viewModel = nil
        repository = nil
        testDefaults = nil
    }
    
    // MARK: - Load Payment Methods Tests
    
    func testLoadPaymentMethodsWhenEmpty() async {
        // When
        await viewModel.loadPaymentMethods()
        
        // Then
        XCTAssertEqual(viewModel.paymentMethods.count, 0)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadPaymentMethodsWithExistingData() async throws {
        // Given
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 5
        )
        let savingsMethod = SavingsMethod(
            name: "储蓄卡",
            transactionType: .expense,
            balance: 5000
        )
        try await repository.savePaymentMethod(.credit(creditMethod))
        try await repository.savePaymentMethod(.savings(savingsMethod))
        
        // When
        await viewModel.loadPaymentMethods()
        
        // Then
        XCTAssertEqual(viewModel.paymentMethods.count, 2)
        XCTAssertNil(viewModel.errorMessage)
    }
}

    // MARK: - Create Credit Method Tests (Requirements 4.1, 4.2)
    
    func testCreateCreditMethodWithValidData() async throws {
        // Given
        let name = "招商银行信用卡"
        let creditLimit: Decimal = 20000
        let outstandingBalance: Decimal = 5000
        let billingDate = 10
        
        // When
        try await viewModel.createCreditMethod(
            name: name,
            transactionType: .expense,
            creditLimit: creditLimit,
            outstandingBalance: outstandingBalance,
            billingDate: billingDate
        )
        
        // Then
        XCTAssertEqual(viewModel.paymentMethods.count, 1)
        
        guard case .credit(let method) = viewModel.paymentMethods.first else {
            XCTFail("Expected credit method")
            return
        }
        
        XCTAssertEqual(method.name, "招商银行信用卡")
        XCTAssertEqual(method.creditLimit, 20000)
        XCTAssertEqual(method.outstandingBalance, 5000)
        XCTAssertEqual(method.billingDate, 10)
        XCTAssertEqual(method.transactionType, .expense)
        
        // Verify persistence
        let fetchedMethods = try await repository.fetchPaymentMethods()
        XCTAssertEqual(fetchedMethods.count, 1)
    }
    
    func testCreateCreditMethodWithInvalidCreditLimitThrowsError() async {
        // Given - credit limit less than outstanding balance
        let creditLimit: Decimal = 5000
        let outstandingBalance: Decimal = 10000
        
        // When/Then
        do {
            try await viewModel.createCreditMethod(
                name: "信用卡",
                transactionType: .expense,
                creditLimit: creditLimit,
                outstandingBalance: outstandingBalance,
                billingDate: 1
            )
            XCTFail("Expected error to be thrown")
        } catch AppError.invalidCreditLimit {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertEqual(viewModel.paymentMethods.count, 0)
    }
    
    // MARK: - Create Savings Method Tests (Requirements 5.1, 5.2)
    
    func testCreateSavingsMethodWithValidData() async throws {
        // Given
        let name = "工商银行储蓄卡"
        let balance: Decimal = 15000
        
        // When
        try await viewModel.createSavingsMethod(
            name: name,
            transactionType: .expense,
            balance: balance
        )
        
        // Then
        XCTAssertEqual(viewModel.paymentMethods.count, 1)
        
        guard case .savings(let method) = viewModel.paymentMethods.first else {
            XCTFail("Expected savings method")
            return
        }
        
        XCTAssertEqual(method.name, "工商银行储蓄卡")
        XCTAssertEqual(method.balance, 15000)
        XCTAssertEqual(method.transactionType, .expense)
        
        // Verify persistence
        let fetchedMethods = try await repository.fetchPaymentMethods()
        XCTAssertEqual(fetchedMethods.count, 1)
    }
    
    func testCreateSavingsMethodWithNegativeBalanceThrowsError() async {
        // Given
        let negativeBalance: Decimal = -1000
        
        // When/Then
        do {
            try await viewModel.createSavingsMethod(
                name: "储蓄卡",
                transactionType: .expense,
                balance: negativeBalance
            )
            XCTFail("Expected error to be thrown")
        } catch AppError.insufficientBalance {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        XCTAssertEqual(viewModel.paymentMethods.count, 0)
    }
    
    // MARK: - Update Credit Method Tests (Requirements 4.3, 4.5)
    
    func testUpdateCreditMethodCreditLimit() async throws {
        // Given
        try await viewModel.createCreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 5
        )
        let methodId = viewModel.paymentMethods.first!.id
        
        // When
        try await viewModel.updateCreditMethod(id: methodId, creditLimit: 20000)
        
        // Then
        guard case .credit(let method) = viewModel.paymentMethods.first else {
            XCTFail("Expected credit method")
            return
        }
        XCTAssertEqual(method.creditLimit, 20000)
        XCTAssertEqual(method.outstandingBalance, 2000)
    }
    
    func testUpdateCreditMethodWithInvalidCreditLimitThrowsError() async throws {
        // Given
        try await viewModel.createCreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 5000,
            billingDate: 5
        )
        let methodId = viewModel.paymentMethods.first!.id
        
        // When/Then - try to set credit limit below outstanding balance
        do {
            try await viewModel.updateCreditMethod(id: methodId, creditLimit: 3000)
            XCTFail("Expected error to be thrown")
        } catch AppError.invalidCreditLimit {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Credit limit should remain unchanged
        guard case .credit(let method) = viewModel.paymentMethods.first else {
            XCTFail("Expected credit method")
            return
        }
        XCTAssertEqual(method.creditLimit, 10000)
    }
    
    // MARK: - Delete Payment Method Tests (Requirements 4.6, 5.6)
    
    func testDeletePaymentMethodNotUsedByBills() async throws {
        // Given
        try await viewModel.createCreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 0,
            billingDate: 5
        )
        let methodId = viewModel.paymentMethods.first!.id
        
        // When
        try await viewModel.deletePaymentMethod(id: methodId)
        
        // Then
        XCTAssertEqual(viewModel.paymentMethods.count, 0)
        
        // Verify persistence
        let fetchedMethods = try await repository.fetchPaymentMethods()
        XCTAssertEqual(fetchedMethods.count, 0)
    }
    
    func testDeletePaymentMethodUsedByBillsThrowsError() async throws {
        // Given
        try await viewModel.createCreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 0,
            billingDate: 5
        )
        let methodId = viewModel.paymentMethods.first!.id
        
        // Create a bill that uses this payment method
        let bill = Bill(
            amount: 100,
            paymentMethodId: methodId,
            categoryIds: [UUID()],
            ownerId: UUID()
        )
        try await repository.saveBill(bill)
        
        // When/Then
        do {
            try await viewModel.deletePaymentMethod(id: methodId)
            XCTFail("Expected error to be thrown")
        } catch AppError.dataNotFound {
            // Success - payment method is still in use
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        // Payment method should still exist
        XCTAssertEqual(viewModel.paymentMethods.count, 1)
    }
    
    // MARK: - Helper Methods Tests
    
    func testAvailableCreditCalculation() async throws {
        // Given
        try await viewModel.createCreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 3000,
            billingDate: 5
        )
        
        guard case .credit(let creditMethod) = viewModel.paymentMethods.first else {
            XCTFail("Expected credit method")
            return
        }
        
        // When
        let availableCredit = viewModel.availableCredit(for: creditMethod)
        
        // Then
        XCTAssertEqual(availableCredit, 7000)
    }
}
