import XCTest
@testable import TagBasedExpenseTracker

/// 数据模型基础测试
final class ModelTests: XCTestCase {
    
    // MARK: - Bill Tests
    
    func testBillCodable() throws {
        let bill = Bill(
            amount: 100.50,
            paymentMethodId: UUID(),
            categoryIds: [UUID(), UUID()],
            ownerId: UUID(),
            note: "测试账单"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(bill)
        
        let decoder = JSONDecoder()
        let decodedBill = try decoder.decode(Bill.self, from: data)
        
        XCTAssertEqual(bill, decodedBill)
    }
    
    func testBillInitialization() {
        let paymentMethodId = UUID()
        let categoryIds = [UUID()]
        let ownerId = UUID()
        
        let bill = Bill(
            amount: 50.0,
            paymentMethodId: paymentMethodId,
            categoryIds: categoryIds,
            ownerId: ownerId
        )
        
        XCTAssertEqual(bill.amount, 50.0)
        XCTAssertEqual(bill.paymentMethodId, paymentMethodId)
        XCTAssertEqual(bill.categoryIds, categoryIds)
        XCTAssertEqual(bill.ownerId, ownerId)
        XCTAssertNil(bill.note)
    }
    
    // MARK: - BillCategory Tests
    
    func testBillCategoryCodable() throws {
        let category = BillCategory(name: "食品")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(category)
        
        let decoder = JSONDecoder()
        let decodedCategory = try decoder.decode(BillCategory.self, from: data)
        
        XCTAssertEqual(category, decodedCategory)
    }
    
    // MARK: - Owner Tests
    
    func testOwnerCodable() throws {
        let owner = Owner(name: "张三")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(owner)
        
        let decoder = JSONDecoder()
        let decodedOwner = try decoder.decode(Owner.self, from: data)
        
        XCTAssertEqual(owner, decodedOwner)
    }
    
    // MARK: - CreditMethod Tests
    
    func testCreditMethodCodable() throws {
        let creditMethod = CreditMethod(
            name: "招商银行信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 2000,
            billingDate: 15
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(creditMethod)
        
        let decoder = JSONDecoder()
        let decodedMethod = try decoder.decode(CreditMethod.self, from: data)
        
        XCTAssertEqual(creditMethod, decodedMethod)
    }
    
    func testCreditMethodAccountType() {
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 5000,
            outstandingBalance: 0,
            billingDate: 1
        )
        
        XCTAssertEqual(creditMethod.accountType, .credit)
    }
    
    // MARK: - SavingsMethod Tests
    
    func testSavingsMethodCodable() throws {
        let savingsMethod = SavingsMethod(
            name: "工商银行储蓄卡",
            transactionType: .expense,
            balance: 5000
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(savingsMethod)
        
        let decoder = JSONDecoder()
        let decodedMethod = try decoder.decode(SavingsMethod.self, from: data)
        
        XCTAssertEqual(savingsMethod, decodedMethod)
    }
    
    func testSavingsMethodAccountType() {
        let savingsMethod = SavingsMethod(
            name: "储蓄卡",
            transactionType: .expense,
            balance: 1000
        )
        
        XCTAssertEqual(savingsMethod.accountType, .savings)
    }
    
    // MARK: - PaymentMethodWrapper Tests
    
    func testPaymentMethodWrapperCreditCodable() throws {
        let creditMethod = CreditMethod(
            name: "信用卡",
            transactionType: .expense,
            creditLimit: 10000,
            outstandingBalance: 1000,
            billingDate: 5
        )
        let wrapper = PaymentMethodWrapper.credit(creditMethod)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(wrapper)
        
        let decoder = JSONDecoder()
        let decodedWrapper = try decoder.decode(PaymentMethodWrapper.self, from: data)
        
        XCTAssertEqual(wrapper, decodedWrapper)
        XCTAssertEqual(wrapper.accountType, .credit)
    }
    
    func testPaymentMethodWrapperSavingsCodable() throws {
        let savingsMethod = SavingsMethod(
            name: "储蓄卡",
            transactionType: .income,
            balance: 5000
        )
        let wrapper = PaymentMethodWrapper.savings(savingsMethod)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(wrapper)
        
        let decoder = JSONDecoder()
        let decodedWrapper = try decoder.decode(PaymentMethodWrapper.self, from: data)
        
        XCTAssertEqual(wrapper, decodedWrapper)
        XCTAssertEqual(wrapper.accountType, .savings)
    }
    
    func testPaymentMethodWrapperProperties() {
        let creditMethod = CreditMethod(
            name: "测试信用卡",
            transactionType: .expense,
            creditLimit: 5000,
            outstandingBalance: 0,
            billingDate: 10
        )
        var wrapper = PaymentMethodWrapper.credit(creditMethod)
        
        XCTAssertEqual(wrapper.name, "测试信用卡")
        XCTAssertEqual(wrapper.transactionType, .expense)
        XCTAssertEqual(wrapper.accountType, .credit)
        
        // 测试修改属性
        wrapper.name = "新名称"
        XCTAssertEqual(wrapper.name, "新名称")
        
        wrapper.transactionType = .income
        XCTAssertEqual(wrapper.transactionType, .income)
    }
    
    // MARK: - Enum Tests
    
    func testTransactionTypeCodable() throws {
        let types: [TransactionType] = [.income, .expense, .excluded]
        
        for type in types {
            let encoder = JSONEncoder()
            let data = try encoder.encode(type)
            
            let decoder = JSONDecoder()
            let decodedType = try decoder.decode(TransactionType.self, from: data)
            
            XCTAssertEqual(type, decodedType)
        }
    }
    
    func testAccountTypeCodable() throws {
        let types: [AccountType] = [.credit, .savings]
        
        for type in types {
            let encoder = JSONEncoder()
            let data = try encoder.encode(type)
            
            let decoder = JSONDecoder()
            let decodedType = try decoder.decode(AccountType.self, from: data)
            
            XCTAssertEqual(type, decodedType)
        }
    }
}
