# 📱 TagBasedExpenseTracker - Xcode 项目设置指南

## 🎯 项目概述

这是一个基于SwiftUI的iOS记账应用，采用MVVM架构，支持多维度账单管理、统计分析和数据导出功能。

---

## 🚀 快速开始

### 方法一：直接在Xcode中打开Package（推荐）

#### 1. 打开项目

```bash
# 在项目根目录执行
open Package.swift
```

或者在Xcode中：
- File → Open
- 选择 `Package.swift` 文件

#### 2. 选择运行目标

- 在Xcode顶部工具栏选择 `ExpenseTrackerApp` scheme
- 选择iOS模拟器（iPhone 14 Pro或更新版本）

#### 3. 运行项目

- 点击运行按钮 (▶️) 或按 `Cmd + R`
- 应用将在模拟器中启动

#### 4. 运行测试

```bash
# 命令行运行
swift test

# 或在Xcode中
# Product → Test 或按 Cmd + U
```

---

### 方法二：创建独立的iOS App项目
如果方法一不工作，可以创建一个新的iOS App项目：

#### 步骤1：创建新项目

1. 打开Xcode
2. File → New → Project
3. 选择 **iOS** → **App**
4. 填写项目信息：
   - Product Name: `ExpenseTrackerApp`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - 取消勾选 Core Data 和 Tests

#### 步骤2：添加Package依赖

1. 在项目导航器中选择项目文件
2. 选择 **Package Dependencies** 标签
3. 点击 **+** 按钮
4. 选择 **Add Local...**
5. 浏览并选择当前项目的根目录
6. 添加 `TagBasedExpenseTracker` 库

#### 步骤3：配置App入口

1. 删除Xcode自动生成的 `ContentView.swift`
2. 打开 `ExpenseTrackerAppApp.swift`（或类似名称的App文件）
3. 替换为以下内容：

```swift
import SwiftUI
import TagBasedExpenseTracker

@main
struct ExpenseTrackerAppApp: App {
    private let repository = UserDefaultsRepository()
    
    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository)
        }
    }
}

struct ContentView: View {
    let repository: DataRepository
    
    var body: some View {
        TabView {
            NavigationView {
                BillListView(repository: repository)
            }
            .tabItem {
                Label("账单", systemImage: "doc.text")
            }
            
            NavigationView {
                StatisticsView(repository: repository)
            }
            .tabItem {
                Label("统计", systemImage: "chart.bar")
            }
            
            NavigationView {
                SettingsView(repository: repository)
            }
            .tabItem {
                Label("设置", systemImage: "gearshape")
            }
        }
    }
}

struct SettingsView: View {
    let repository: DataRepository
    
    var body: some View {
        List {
            NavigationLink("账单类型管理") {
                CategoryManagementView(repository: repository)
            }
            
            NavigationLink("归属人管理") {
                OwnerManagementView(repository: repository)
            }
            
            NavigationLink("支付方式管理") {
                PaymentMethodListView(repository: repository)
            }
        }
        .navigationTitle("设置")
    }
}
```

#### 步骤4：运行项目

- 选择iOS模拟器
- 点击运行按钮 (▶️) 或按 `Cmd + R`

---

## 📋 系统要求

- **Xcode**: 14.0 或更高版本
- **iOS**: 15.0 或更高版本
- **macOS**: 12.0 或更高版本（用于开发）
- **Swift**: 5.9 或更高版本

---
## 🏗️ 项目结构

```
TagBasedExpenseTracker/
├── Package.swift                 # Swift Package配置
├── Sources/
│   ├── App.swift                # 应用入口
│   ├── Models/                  # 数据模型
│   │   ├── Bill.swift
│   │   ├── BillCategory.swift
│   │   ├── Owner.swift
│   │   ├── PaymentMethod.swift
│   │   ├── AccountType.swift
│   │   ├── TransactionType.swift
│   │   └── AppError.swift
│   ├── Repository/              # 数据访问层
│   │   ├── DataRepository.swift
│   │   └── UserDefaultsRepository.swift
│   ├── ViewModels/              # 业务逻辑层
│   │   ├── BillViewModel.swift
│   │   ├── CategoryViewModel.swift
│   │   ├── OwnerViewModel.swift
│   │   ├── PaymentMethodViewModel.swift
│   │   ├── StatisticsViewModel.swift
│   │   └── ExportViewModel.swift
│   └── Views/                   # UI层
│       ├── BillListView.swift
│       ├── BillFormView.swift
│       ├── CategoryManagementView.swift
│       ├── OwnerManagementView.swift
│       ├── PaymentMethodListView.swift
│       ├── StatisticsView.swift
│       └── ... (辅助视图)
└── Tests/                       # 测试
    ├── ModelTests.swift
    ├── RepositoryTests.swift
    ├── PropertyBasedTests.swift
    └── ... (其他测试)
```

---

## ✨ 核心功能

### 1. 账单管理
- ✅ 创建账单（金额、支付方式、类型、归属人）
- ✅ 删除账单
- ✅ 筛选账单（按类型、归属人、支付方式、时间）
- ✅ 自动更新支付方式余额

### 2. 支付方式管理
- ✅ 信贷方式（信用卡、花呗等）
  - 信用额度管理
  - 欠费金额跟踪
  - 账单日设置
- ✅ 储蓄方式（储蓄卡、现金等）
  - 余额管理

### 3. 分类管理
- ✅ 账单类型管理（衣、食、住、行等）
- ✅ 归属人管理（家庭成员）
- ✅ 名称唯一性验证

### 4. 统计分析
- ✅ 总收入/总支出统计
- ✅ 按账单类型统计
- ✅ 按归属人统计
- ✅ 按支付方式统计
- ✅ 时间范围筛选

### 5. 数据导出
- ✅ CSV格式导出
- ✅ 包含所有账单字段
- ✅ 系统分享功能

---
## 🧪 运行测试

### 命令行运行

```bash
# 运行所有测试
swift test

# 运行特定测试
swift test --filter ModelTests
swift test --filter PropertyBasedTests
```

### Xcode中运行

1. 打开 Test Navigator (`⌘ + 6`)
2. 点击测试旁边的运行按钮
3. 或使用 Product → Test (`⌘ + U`)

---

## 🐛 常见问题

### 问题1：无法找到模块

**错误**: `No such module 'TagBasedExpenseTracker'`

**解决方案**:
1. 确保已添加Package依赖
2. Clean Build Folder (`⌘ + Shift + K`)
3. 重新构建项目 (`⌘ + B`)

### 问题2：模拟器无法启动

**解决方案**:
1. 重启Xcode
2. 在Xcode中：Window → Devices and Simulators
3. 删除并重新创建模拟器

### 问题3：SwiftCheck依赖下载失败

**解决方案**:
1. 检查网络连接
2. File → Packages → Reset Package Caches
3. File → Packages → Update to Latest Package Versions

### 问题4：编译错误

**解决方案**:
1. 确保Xcode版本 ≥ 14.0
2. 确保iOS Deployment Target ≥ 15.0
3. Clean Build Folder (`⌘ + Shift + K`)

---
## 📱 使用指南

### 主要界面

1. **账单列表** - 显示所有账单，支持筛选和导出
2. **统计分析** - 多维度统计图表
3. **设置** - 管理类型、归属人和支付方式

### 操作流程

1. **首次使用**：先在"设置"中添加账单类型、归属人和支付方式
2. **创建账单**：在"账单"页面点击"+"添加新账单
3. **查看统计**：在"统计"页面查看收支分析
4. **导出数据**：在"账单"页面点击"导出"按钮

---

## 🔧 开发说明

### 架构模式

- **MVVM** (Model-View-ViewModel)
- **Repository Pattern** (数据访问抽象)
- **Dependency Injection** (依赖注入)

### 技术栈

- **UI**: SwiftUI
- **数据持久化**: UserDefaults
- **状态管理**: Combine + @Published
- **并发**: Swift Concurrency (async/await)
- **测试**: XCTest + SwiftCheck (属性测试)

### 代码规范

- 所有ViewModel使用 `@MainActor`
- 所有异步操作使用 `async/await`
- 错误处理使用自定义 `AppError`
- 遵循Swift API设计指南

---

## 📚 相关文档

- [需求文档](.kiro/specs/tag-based-expense-tracker/requirements.md)
- [设计文档](.kiro/specs/tag-based-expense-tracker/design.md)
- [任务列表](.kiro/specs/tag-based-expense-tracker/tasks.md)
- [实现笔记](IMPLEMENTATION_NOTES.md)

---

## 🤝 贡献指南

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

---

## 📄 许可证

本项目仅供学习和参考使用。

---

## 💡 技术支持

如有问题，请查看：

1. 本文档的"常见问题"部分
2. 项目的Issues页面
3. Swift官方文档：https://swift.org/documentation/

---

## 🎉 开始使用

现在你可以：

1. 打开 `Package.swift` 在Xcode中
2. 选择 `ExpenseTrackerApp` scheme
3. 点击运行按钮
4. 开始使用你的记账应用！

**祝你使用愉快！** 🚀