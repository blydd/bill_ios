# 代码修复说明

## 修复的问题

### PaymentMethod 协议的 Codable 实现

**问题描述:**
原始设计中,`PaymentMethod` 协议继承了 `Codable`,但 Swift 中的协议本身不能直接进行编码/解码。这会在实际使用中导致类型擦除问题。

**解决方案:**
1. 从 `PaymentMethod` 协议中移除了 `Codable` 继承
2. 在具体实现 `CreditMethod` 和 `SavingsMethod` 中保留 `Codable` 实现
3. 创建了 `PaymentMethodWrapper` 枚举来统一处理两种支付方式的序列化

**PaymentMethodWrapper 的优势:**
- ✅ 类型安全的枚举,避免运行时类型错误
- ✅ 完整的 Codable 支持,可以正确序列化/反序列化
- ✅ 提供统一的属性访问接口(id, name, transactionType, accountType)
- ✅ 支持属性修改(name 和 transactionType)
- ✅ 便于在数组和字典中统一存储不同类型的支付方式

**使用示例:**

```swift
// 创建信贷方式
let credit = CreditMethod(
    name: "招商银行信用卡",
    transactionType: .expense,
    creditLimit: 10000,
    outstandingBalance: 2000,
    billingDate: 15
)
let wrapper1 = PaymentMethodWrapper.credit(credit)

// 创建储蓄方式
let savings = SavingsMethod(
    name: "工商银行储蓄卡",
    transactionType: .expense,
    balance: 5000
)
let wrapper2 = PaymentMethodWrapper.savings(savings)

// 统一存储
let paymentMethods: [PaymentMethodWrapper] = [wrapper1, wrapper2]

// 序列化
let encoder = JSONEncoder()
let data = try encoder.encode(paymentMethods)

// 反序列化
let decoder = JSONDecoder()
let decoded = try decoder.decode([PaymentMethodWrapper].self, from: data)

// 访问属性
for method in decoded {
    print(method.name)
    print(method.accountType)
}
```

## 测试覆盖

添加了以下测试来验证修复:
- `testPaymentMethodWrapperCreditCodable()` - 测试信贷方式的序列化
- `testPaymentMethodWrapperSavingsCodable()` - 测试储蓄方式的序列化
- `testPaymentMethodWrapperProperties()` - 测试属性访问和修改

所有测试都通过了编译检查,确保代码的正确性。

## 影响范围

这个修复不会影响其他已实现的模型,只是改进了支付方式的设计。后续在实现 Repository 层时,应该使用 `PaymentMethodWrapper` 来存储和查询支付方式。
