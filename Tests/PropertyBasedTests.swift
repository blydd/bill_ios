import XCTest
import SwiftCheck
@testable import TagBasedExpenseTracker

/// 基于属性的测试
/// 使用SwiftCheck进行属性测试，验证系统的通用正确性属性
final class PropertyBasedTests: XCTestCase {
    
    // MARK: - Test Helpers
    
    /// 创建测试用的Repository
    private func createTestRepository() -> UserDefaultsRepository {
        let testDefaults = UserDefaults(suiteName: "com.expensetracker.pbt.\(UUID().uuidString)")!
        return UserDefaultsRepository(userDefaults: testDefaults)
    }
    
    /// 清理测试Repository
    private func cleanupTestRepository(_ repository: UserDefaultsRepository) {
        if let suiteName = repository.userDefaults.dictionaryRepresentation().keys.first {
            repository.userDefaults.removePersistentDomain(forName: suiteName)
        }
    }
    
    // MARK: - Property 3: 名称唯一性约束
    // Feature: tag-based-expense-tracker, Property 3: 名称唯一性约束
    // Validates: Requirements 2.2
    
    /// 测试账单类型名称唯一性约束
    /// 对于任何实体类型(账单类型),尝试创建具有已存在名称的新实体应该失败
    @MainActor
    func testCategoryNameUniquenessConstraint() {
        property("尝试创建具有已存在名称的账单类型应该失败") <- forAll { (name: String) in
            // 过滤掉空字符串和纯空白字符串
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else {
                return Discard()
            }
            
            let repository = self.createTestRepository()
            let viewModel = CategoryViewModel(repository: repository)
            
            var result = true
            let expectation = XCTestExpectation(description: "Category creation test")
            
            Task { @MainActor in
                do {
                    // 首先创建一个账单类型
                    try await viewModel.createCategory(name: trimmedName)
                    
                    // 尝试创建同名的账单类型，应该失败
                    do {
                        try await viewModel.createCategory(name: trimmedName)
                        // 如果没有抛出错误，测试失败
                        result = false
                    } catch AppError.duplicateName {
                        // 预期的错误，测试通过
                        result = true
                    } catch {
                        // 其他错误，测试失败
                        result = false
                    }
                } catch {
                    // 第一次创建失败，测试失败
                    result = false
                }
                
                self.cleanupTestRepository(repository)
                expectation.fulfill()
            }
            
            self.wait(for: [expectation], timeout: 5.0)
            return result
        }.verbose.maxSize(100)
    }
    
    /// 测试账单类型名称唯一性约束 - 不同名称应该成功
    /// 对于任何两个不同的名称，创建两个账单类型应该成功
    @MainActor
    func testCategoryDifferentNamesAllowed() {
        property("创建具有不同名称的账单类型应该成功") <- forAll { (name1: String, name2: String) in
            let trimmedName1 = name1.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedName2 = name2.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 过滤掉空字符串和相同名称
            guard !trimmedName1.isEmpty && !trimmedName2.isEmpty && trimmedName1 != trimmedName2 else {
                return Discard()
            }
            
            let repository = self.createTestRepository()
            let viewModel = CategoryViewModel(repository: repository)
            
            var result = true
            let expectation = XCTestExpectation(description: "Different category names test")
            
            Task { @MainActor in
                do {
                    // 创建第一个账单类型
                    try await viewModel.createCategory(name: trimmedName1)
                    
                    // 创建第二个不同名称的账单类型，应该成功
                    try await viewModel.createCategory(name: trimmedName2)
                    
                    // 验证两个类型都存在
                    result = viewModel.categories.count == 2
                } catch {
                    // 任何错误都表示测试失败
                    result = false
                }
                
                self.cleanupTestRepository(repository)
                expectation.fulfill()
            }
            
            self.wait(for: [expectation], timeout: 5.0)
            return result
        }.verbose.maxSize(100)
    }
    
    /// 测试账单类型名称唯一性约束 - 大小写敏感
    /// 验证名称比较是否区分大小写
    @MainActor
    func testCategoryNameCaseSensitivity() {
        property("名称比较应该区分大小写") <- forAll { (baseName: String) in
            let trimmedName = baseName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 过滤掉空字符串和没有字母的字符串
            guard !trimmedName.isEmpty && trimmedName.rangeOfCharacter(from: .letters) != nil else {
                return Discard()
            }
            
            let lowerName = trimmedName.lowercased()
            let upperName = trimmedName.uppercased()
            
            // 如果大小写转换后相同，跳过
            guard lowerName != upperName else {
                return Discard()
            }
            
            let repository = self.createTestRepository()
            let viewModel = CategoryViewModel(repository: repository)
            
            var result = true
            let expectation = XCTestExpectation(description: "Case sensitivity test")
            
            Task { @MainActor in
                do {
                    // 创建小写版本
                    try await viewModel.createCategory(name: lowerName)
                    
                    // 创建大写版本，应该成功（因为区分大小写）
                    try await viewModel.createCategory(name: upperName)
                    
                    // 验证两个类型都存在
                    result = viewModel.categories.count == 2
                } catch {
                    // 任何错误都表示测试失败
                    result = false
                }
                
                self.cleanupTestRepository(repository)
                expectation.fulfill()
            }
            
            self.wait(for: [expectation], timeout: 5.0)
            return result
        }.verbose.maxSize(100)
    }
}
