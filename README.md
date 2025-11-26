# Tag-Based Expense Tracker

基于标签的iOS记账应用

## 项目结构

```
TagBasedExpenseTracker/
├── Package.swift                 # Swift Package Manager配置
├── Sources/
│   └── Models/                   # 核心数据模型
│       ├── AccountType.swift     # 账户类型枚举
│       ├── TransactionType.swift # 交易类型枚举
│       ├── Bill.swift            # 账单模型
│       ├── BillCategory.swift    # 账单类型模型
│       ├── Owner.swift           # 归属人模型
│       └── PaymentMethod.swift   # 支付方式协议和实现
└── Tests/                        # 测试文件
```

## 技术栈

- **语言**: Swift 5.9+
- **平台**: iOS 15.0+, macOS 12.0+
- **UI框架**: SwiftUI
- **数据持久化**: Core Data
- **测试框架**: XCTest + SwiftCheck (属性测试)

## 核心数据模型

### Bill (账单)
记录单次收入或支出的财务记录，包含金额、支付方式、账单类型、归属人等信息。

### PaymentMethod (支付方式)
支付方式协议，有两种实现：
- **CreditMethod**: 信贷方式（信用卡、花呗等）
- **SavingsMethod**: 储蓄方式（储蓄卡、微信零钱等）

### BillCategory (账单类型)
用于分类账单的类别（如衣、食、住、行等）。

### Owner (归属人)
账单所属的家庭成员（如丈夫、妻子、女儿等）。

## 构建项目

```bash
swift build
```

## 运行测试

```bash
swift test
```

## 开发说明

本项目遵循MVVM架构模式，使用属性测试(Property-Based Testing)确保代码正确性。所有核心数据模型都实现了`Codable`协议以支持序列化。
