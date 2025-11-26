# Design Document

## Overview

本设计文档描述了一个基于SwiftUI的iOS记账应用的技术架构和实现方案。该应用采用MVVM架构模式，使用Swift语言开发，支持iOS 15.0及以上版本。应用的核心功能包括账单管理、多维度标签分类、支付方式管理（信贷和储蓄）、数据筛选统计以及Excel导出。

## Architecture

### 架构模式

采用MVVM (Model-View-ViewModel) 架构模式：

- **Model层**: 定义数据模型和业务逻辑
- **View层**: SwiftUI视图组件，负责UI展示
- **ViewModel层**: 连接Model和View，处理业务逻辑和状态管理
- **Repository层**: 数据持久化和访问抽象层

### 技术栈

- **UI框架**: SwiftUI
- **数据持久化**: Core Data / UserDefaults (根据数据复杂度选择)
- **状态管理**: Combine框架 + @Published属性
- **Excel导出**: 使用第三方库如 `xlsxwriter` 或自定义CSV导出
- **日期处理**: Foundation的Date和Calendar
- **并发处理**: Swift Concurrency (async/await)

## Components and Interfaces

### 核心组件

#### 1. Data Models (模型层)

**Bill (账单)**
```swift
struct Bill: Identifiable, Codable {
    let id: UUID
    var amount: Decimal
    var paymentMethodId: UUID
    var categoryIds: [UUID]
    var ownerId: UUID
    var note: String?
    var createdAt: Date
    var updatedAt: Date
}
```

**PaymentMethod (支付方式基类)**
```swift
protocol PaymentMethod: Identifiable, Codable {
    var id: UUID { get }
    var name: String { get set }
    var transactionType: TransactionType { get set }
    var accountType: AccountType { get }
}

enum TransactionType: String, Codable {
    case income
    case expense
    case excluded
}

enum AccountType: String, Codable {
    case credit
    case savings
}
```

**CreditMethod (信贷方式)**
```swift
struct CreditMethod: PaymentMethod {
    let id: UUID
    var name: String
    var transactionType: TransactionType
    let accountType: AccountType = .credit
    var creditLimit: Decimal
    var outstandingBalance: Decimal
    var billingDate: Int
}
```

**SavingsMethod (储蓄方式)**
```swift
struct SavingsMethod: PaymentMethod {
    let id: UUID
    var name: String
    var transactionType: TransactionType
    let accountType: AccountType = .savings
    var balance: Decimal
}
```

**BillCategory (账单类型)**
```swift
struct BillCategory: Identifiable, Codable {
    let id: UUID
    var name: String
}
```

**Owner (归属人)**
```swift
struct Owner: Identifiable, Codable {
    let id: UUID
    var name: String
}
```

#### 2. ViewModels (视图模型层)

**BillViewModel**
- 管理账单的创建、编辑、删除
- 处理账单筛选和排序
- 协调支付方式余额/额度更新

**PaymentMethodViewModel**
- 管理信贷方式和储蓄方式的CRUD操作
- 计算可用额度和余额
- 验证额度限制

**CategoryViewModel**
- 管理账单类型的CRUD操作
- 验证名称唯一性

**OwnerViewModel**
- 管理归属人的CRUD操作
- 验证名称唯一性

**StatisticsViewModel**
- 计算收支统计
- 按不同维度聚合数据
- 生成图表数据

**ExportViewModel**
- 处理Excel/CSV导出逻辑
- 格式化导出数据

#### 3. Repository (数据访问层)

**DataRepository**
```swift
protocol DataRepository {
    func saveBill(_ bill: Bill) async throws
    func fetchBills() async throws -> [Bill]
    func updateBill(_ bill: Bill) async throws
    func deleteBill(_ bill: Bill) async throws
    
    func savePaymentMethod(_ method: any PaymentMethod) async throws
    func fetchPaymentMethods() async throws -> [any PaymentMethod]
    
    func saveCategory(_ category: BillCategory) async throws
    func fetchCategories() async throws -> [BillCategory]
    
    func saveOwner(_ owner: Owner) async throws
    func fetchOwners() async throws -> [Owner]
}
```

**CoreDataRepository** (实现类)
- 使用Core Data进行本地持久化
- 实现DataRepository协议

#### 4. Views (视图层)

**主要视图**
- `BillListView`: 账单列表和筛选界面
- `BillFormView`: 账单创建/编辑表单
- `PaymentMethodListView`: 支付方式管理界面
- `CategoryManagementView`: 账单类型管理界面
- `OwnerManagementView`: 归属人管理界面
- `StatisticsView`: 统计分析界面
- `SettingsView`: 设置界面

## Data Models

### 数据关系图

```
Bill (账单)
├── paymentMethodId → PaymentMethod (1:1)
├── categoryIds → [BillCategory] (1:N)
└── ownerId → Owner (1:1)

PaymentMethod (支付方式)
├── CreditMethod (信贷方式)
└── SavingsMethod (储蓄方式)
```

### 数据验证规则

1. **账单创建验证**
   - 金额必须大于0
   - 必须选择一个支付方式
   - 必须选择至少一个账单类型
   - 必须选择一个归属人

2. **信贷方式验证**
   - 信用额度必须大于等于初始欠费金额
   - 创建支出账单时，新的欠费金额不能超过信用额度

3. **储蓄方式验证**
   - 初始余额不能为负数

4. **名称唯一性验证**
   - 账单类型名称必须唯一
   - 归属人名称必须唯一

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Acceptence Criteria Testing Prework:

1.1 WHEN 用户输入账单金额、选择一个支付方式、选择至少一个账单类型、选择一个归属人 THEN THE Transaction System SHALL 创建新的账单记录并保存到本地存储
Thoughts: 这是测试账单创建的核心功能。我们可以生成随机的账单数据(金额、支付方式、类型、归属人),创建账单,然后验证账单被正确保存。这是一个属性测试。
Testable: yes - property

1.2 WHEN 用户尝试创建金额为零或负数的账单 THEN THE Transaction System SHALL 拒绝该账单并提示用户输入有效金额
Thoughts: 这是测试输入验证。我们可以生成零和负数金额,尝试创建账单,验证系统拒绝。这是边界情况测试。
Testable: edge-case

1.3-1.5 必填字段验证
Thoughts: 这些都是测试必填字段验证的规则。可以作为边界情况处理。
Testable: edge-case

1.6 WHEN 账单成功创建 THEN THE Transaction System SHALL 自动记录账单创建的时间戳
Thoughts: 这是测试时间戳自动生成。对于任何账单,创建后应该有时间戳。这是一个属性。
Testable: yes - property

2.1 WHEN 用户创建新的账单类型 THEN THE Transaction System SHALL 验证类型名称唯一性并保存该类型
Thoughts: 这是测试名称唯一性约束。对于任何新类型名称,如果不存在则应该成功保存。这是一个属性。
Testable: yes - property

2.2 WHEN 用户输入已存在的账单类型名称 THEN THE Transaction System SHALL 拒绝创建并提示用户该类型已存在
Thoughts: 这是测试重复名称拒绝。对于任何已存在的名称,系统应该拒绝。这是一个属性。
Testable: yes - property

2.4 WHEN 用户编辑账单类型名称 THEN THE Transaction System SHALL 更新该类型并同步更新所有使用该类型的账单
Thoughts: 这是测试级联更新。对于任何类型的重命名,所有引用该类型的账单都应该反映新名称。这是一个属性。
Testable: yes - property

3.1-3.6 归属人管理
Thoughts: 与账单类型管理类似,都是CRUD操作和唯一性验证。
Testable: yes - property (类似2.1-2.4)

4.1 WHEN 用户在信贷账户下创建新的信贷方式 THEN THE Transaction System SHALL 要求用户输入方式名称、信用额度、账单日和初始欠费金额
Thoughts: 这是测试信贷方式创建。对于任何有效的信贷方式数据,系统应该成功创建。这是一个属性。
Testable: yes - property

4.2 WHEN 用户创建信贷方式时输入的信用额度小于初始欠费金额 THEN THE Transaction System SHALL 拒绝创建并提示用户额度不足
Thoughts: 这是测试额度验证。对于任何额度小于欠费的情况,系统应该拒绝。这是一个属性。
Testable: yes - property

5.1-5.6 储蓄方式管理
Thoughts: 与信贷方式类似,测试储蓄方式的CRUD操作。
Testable: yes - property

6.1 WHEN 用户使用信贷方式创建支出账单且欠费金额增加后不超过信用额度 THEN THE Transaction System SHALL 增加该信贷方式的欠费金额并减少可用额度
Thoughts: 这是测试信贷方式余额更新逻辑。对于任何有效的支出账单,欠费应该增加,可用额度应该减少。这是一个属性。
Testable: yes - property

6.2 WHEN 用户使用信贷方式创建支出账单且欠费金额增加后超过信用额度 THEN THE Transaction System SHALL 拒绝创建账单并提示用户额度不足
Thoughts: 这是测试额度限制。对于任何会导致超额的账单,系统应该拒绝。这是一个属性。
Testable: yes - property

6.3-6.6 余额更新规则
Thoughts: 测试不同场景下的余额/额度更新逻辑。
Testable: yes - property

7.1-7.6 筛选功能
Thoughts: 测试筛选逻辑的正确性。对于任何筛选条件,返回的结果应该满足条件。这是一个属性。
Testable: yes - property

8.1-8.6 统计功能
Thoughts: 测试统计计算的正确性。对于任何账单集合,统计结果应该准确。这是一个属性。
Testable: yes - property

9.1 WHEN 用户编辑账单金额 THEN THE Transaction System SHALL 更新账单记录并重新计算相关支付方式的额度或余额
Thoughts: 这是测试编辑后的余额重算。对于任何账单金额的修改,相关余额应该正确更新。这是一个属性。
Testable: yes - property

9.2 WHEN 用户修改账单的支付方式 THEN THE Transaction System SHALL 恢复原支付方式的额度或余额并更新新支付方式的额度或余额
Thoughts: 这是测试支付方式切换的余额调整。对于任何支付方式的切换,两个方式的余额都应该正确调整。这是一个属性。
Testable: yes - property

9.4 WHEN 用户删除账单 THEN THE Transaction System SHALL 移除账单记录并恢复相关支付方式的额度或余额
Thoughts: 这是测试删除的余额恢复。对于任何账单的删除,相关余额应该恢复。这是一个属性。
Testable: yes - property

10.5 WHEN 数据序列化和反序列化 THEN THE Transaction System SHALL 保持数据完整性和一致性
Thoughts: 这是测试数据持久化的往返一致性。对于任何数据,序列化后反序列化应该得到相同的数据。这是一个往返属性。
Testable: yes - property

11.1-11.5 UI相关
Thoughts: 这些是UI交互和性能要求,不适合单元测试。
Testable: no

12.2 WHEN 导出Excel文件 THEN THE Transaction System SHALL 包含账单时间、金额、账单类型、归属人、支付方式和备注等所有字段
Thoughts: 这是测试导出数据的完整性。对于任何账单,导出的数据应该包含所有必需字段。这是一个属性。
Testable: yes - property


### Property Reflection

经过分析,我识别出以下可以合并或优化的属性:

1. **名称唯一性验证** - 账单类型和归属人的唯一性验证逻辑相同,可以合并为一个通用属性
2. **余额更新逻辑** - 信贷和储蓄方式的余额更新可以统一为一个属性,根据交易类型和账户类型计算
3. **筛选功能** - 多个筛选条件可以合并为一个综合筛选属性
4. **边界情况** - 零/负数金额、必填字段等验证可以作为生成器的约束,不需要单独的属性

### Correctness Properties

Property 1: 账单创建保存一致性
*For any* 有效的账单数据(正数金额、有效的支付方式ID、至少一个类型ID、有效的归属人ID),创建账单后从存储中查询应该能找到该账单且所有字段匹配
**Validates: Requirements 1.1**

Property 2: 时间戳自动生成
*For any* 新创建的账单,其createdAt字段应该被自动设置且不为空
**Validates: Requirements 1.6**

Property 3: 名称唯一性约束
*For any* 实体类型(账单类型或归属人),尝试创建具有已存在名称的新实体应该失败
**Validates: Requirements 2.2, 3.2**

Property 4: 级联更新一致性
*For any* 账单类型或归属人的名称更新,所有引用该实体的账单都应该反映新的名称
**Validates: Requirements 2.4, 3.4**

Property 5: 信贷额度验证
*For any* 信贷方式,其信用额度必须大于等于初始欠费金额,否则创建应该失败
**Validates: Requirements 4.2**

Property 6: 信贷支出余额更新
*For any* 使用信贷方式的支出账单,如果创建后欠费不超过额度,则欠费金额应该增加账单金额,可用额度应该减少账单金额
**Validates: Requirements 6.1**

Property 7: 信贷额度限制
*For any* 使用信贷方式的支出账单,如果创建后欠费会超过额度,则账单创建应该失败
**Validates: Requirements 6.2**

Property 8: 信贷收入余额更新
*For any* 使用信贷方式的收入账单,欠费金额应该减少账单金额,可用额度应该增加账单金额
**Validates: Requirements 6.3**

Property 9: 储蓄支出余额更新
*For any* 使用储蓄方式的支出账单,储蓄方式的余额应该减少账单金额
**Validates: Requirements 6.4**

Property 10: 储蓄收入余额更新
*For any* 使用储蓄方式的收入账单,储蓄方式的余额应该增加账单金额
**Validates: Requirements 6.5**

Property 11: 不计入类型不更新余额
*For any* 使用标记为"不计入"的支付方式创建的账单,该支付方式的余额或额度应该保持不变
**Validates: Requirements 6.6**

Property 12: 筛选结果正确性
*For any* 筛选条件组合(类型、归属人、支付方式、时间范围),返回的所有账单都应该满足所有指定的筛选条件
**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

Property 13: 统计计算准确性
*For any* 账单集合和时间范围,计算的总收入应该等于所有收入账单(排除"不计入"类型)的金额之和,总支出应该等于所有支出账单的金额之和
**Validates: Requirements 8.1, 8.5**

Property 14: 账单编辑余额重算
*For any* 账单金额的修改,相关支付方式的余额或额度应该根据金额差值进行调整
**Validates: Requirements 9.1**

Property 15: 支付方式切换余额调整
*For any* 账单的支付方式切换,原支付方式的余额应该恢复,新支付方式的余额应该相应扣除
**Validates: Requirements 9.2**

Property 16: 账单删除余额恢复
*For any* 账单的删除,相关支付方式的余额或额度应该恢复到删除前的状态
**Validates: Requirements 9.4**

Property 17: 数据持久化往返一致性
*For any* 数据对象(账单、支付方式、类型、归属人),序列化后反序列化应该得到等价的对象
**Validates: Requirements 10.5**

Property 18: 导出数据完整性
*For any* 导出的账单,导出文件中应该包含该账单的所有必需字段(时间、金额、类型、归属人、支付方式)
**Validates: Requirements 12.2**


## Error Handling

### 错误类型定义

`swift
enum AppError: Error, LocalizedError {
    case invalidAmount
    case missingPaymentMethod
    case missingCategory
    case missingOwner
    case duplicateName(entityType: String)
    case creditLimitExceeded
    case insufficientBalance
    case invalidCreditLimit
    case dataNotFound
    case persistenceError(underlying: Error)
    case exportError(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "账单金额必须大于0"
        case .missingPaymentMethod:
            return "请选择支付方式"
        case .missingCategory:
            return "请选择至少一个账单类型"
        case .missingOwner:
            return "请选择归属人"
        case .duplicateName(let entityType):
            return "\(entityType)名称已存在"
        case .creditLimitExceeded:
            return "信用额度不足"
        case .insufficientBalance:
            return "余额不足"
        case .invalidCreditLimit:
            return "信用额度必须大于等于初始欠费金额"
        case .dataNotFound:
            return "数据不存在"
        case .persistenceError(let error):
            return "数据保存失败: \(error.localizedDescription)"
        case .exportError(let error):
            return "导出失败: \(error.localizedDescription)"
        }
    }
}
`

### 错误处理策略

1. **输入验证错误**: 在ViewModel层进行验证,立即向用户显示错误提示
2. **业务逻辑错误**: 在Service层抛出,由ViewModel捕获并转换为用户友好的消息
3. **持久化错误**: 在Repository层抛出,提供重试机制
4. **导出错误**: 提供详细的错误信息和重试选项

## Testing Strategy

### 测试框架

- **单元测试**: XCTest框架
- **属性测试**: 使用SwiftCheck库进行基于属性的测试
- **UI测试**: XCTest UI Testing (可选)

### 属性测试配置

每个属性测试应该:
- 运行至少100次迭代
- 使用SwiftCheck的property函数定义
- 明确标注对应的设计文档属性编号

### 测试标注格式

`swift
// Feature: tag-based-expense-tracker, Property 1: 账单创建保存一致性
func testBillCreationPersistenceConsistency() {
    property("创建的账单应该能从存储中查询到") <- forAll { (bill: Bill) in
        // 测试逻辑
    }
}
`

### 单元测试覆盖范围

1. **Model层测试**
   - 数据模型的编码/解码
   - 业务逻辑方法

2. **ViewModel层测试**
   - 输入验证逻辑
   - 状态管理
   - 业务流程

3. **Repository层测试**
   - CRUD操作
   - 数据查询和筛选

4. **Service层测试**
   - 余额计算逻辑
   - 统计计算逻辑
   - 导出功能

### 测试数据生成器

为属性测试创建自定义生成器:

`swift
extension Bill: Arbitrary {
    public static var arbitrary: Gen<Bill> {
        return Gen<Bill>.compose { c in
            return Bill(
                id: UUID(),
                amount: c.generate(using: Gen.choose((1, 10000))),
                paymentMethodId: UUID(),
                categoryIds: c.generate(),
                ownerId: UUID(),
                note: c.generate(),
                createdAt: Date(),
                updatedAt: Date()
            )
        }
    }
}
`

### 测试执行顺序

1. 首先实现核心数据模型和Repository
2. 为核心功能编写属性测试
3. 实现ViewModel和业务逻辑
4. 编写单元测试验证具体场景
5. 实现UI层
6. 运行所有测试确保通过

## Implementation Notes

### 数据持久化方案

推荐使用Core Data:
- 支持复杂的数据关系
- 提供高效的查询和筛选
- 内置数据迁移支持

### 性能优化考虑

1. **列表分页**: 账单列表使用分页加载,避免一次性加载大量数据
2. **索引优化**: 为常用查询字段(如日期、支付方式ID)创建索引
3. **缓存策略**: ViewModel层缓存常用数据(类型、归属人列表)
4. **异步操作**: 所有数据库操作使用async/await,避免阻塞主线程

### UI/UX设计原则

1. **即时反馈**: 输入验证提供实时反馈
2. **加载状态**: 异步操作显示加载指示器
3. **错误提示**: 使用Alert或Toast显示错误信息
4. **确认对话框**: 删除操作需要用户确认
5. **空状态**: 列表为空时显示友好的空状态提示

### 扩展性考虑

1. **多币种支持**: 预留货币类型字段
2. **预算功能**: 数据模型支持未来添加预算管理
3. **云同步**: Repository接口设计支持未来添加云同步
4. **数据导入**: 预留数据导入接口

