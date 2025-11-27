# 在 Xcode 中运行项目

## 重要说明

这是一个 Swift Package 项目，**不能直接作为 iOS App 运行**。需要创建一个独立的 Xcode iOS App 项目来使用这个 Package。

## 方法一：创建新的 iOS App 项目（推荐）

### 步骤 1：创建 iOS App 项目

1. 打开 Xcode
2. 选择 `File` -> `New` -> `Project...`
3. 选择 `iOS` -> `App`
4. 填写项目信息：
   - Product Name: `ExpenseTrackerApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Bundle Identifier: `com.expensetracker.app`
5. 选择保存位置（建议保存在当前项目的父目录）
6. 点击 `Create`

### 步骤 2：添加本地 Package 依赖

1. 在新创建的项目中，选择项目导航器中的项目文件（蓝色图标）
2. 选择 `PROJECT` 下的项目名称
3. 切换到 `Package Dependencies` 标签
4. 点击 `+` 按钮
5. 点击 `Add Local...`
6. 选择本项目的根目录（包含 `Package.swift` 的目录）
7. 点击 `Add Package`
8. 在弹出的对话框中，勾选 `TagBasedExpenseTracker`
9. 点击 `Add Package`

### 步骤 3：使用 Package 中的代码

1. 删除新项目中自动生成的 `ContentView.swift`
2. 打开 `ExpenseTrackerApp.swift`（或类似的 App 入口文件）
3. 替换为以下代码：

```swift
import SwiftUI
import TagBasedExpenseTracker

@main
struct ExpenseTrackerApp: App {
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
步骤 4：运行 App
选择 iOS 模拟器（如 iPhone 15）
点击运行按钮（⌘R）
App 应该可以正常启动了