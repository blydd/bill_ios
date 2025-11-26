import SwiftUI

/// 支付方式管理视图
struct PaymentMethodListView: View {
    @StateObject private var viewModel: PaymentMethodViewModel
    @State private var showingAddCreditSheet = false
    @State private var showingAddSavingsSheet = false
    @State private var showingError = false
    
    // 信贷方式表单字段
    @State private var creditName = ""
    @State private var creditLimit = ""
    @State private var outstandingBalance = ""
    @State private var billingDate = ""
    @State private var creditTransactionType: TransactionType = .expense
    
    // 储蓄方式表单字段
    @State private var savingsName = ""
    @State private var savingsBalance = ""
    @State private var savingsTransactionType: TransactionType = .expense
    
    init(repository: DataRepository) {
        _viewModel = StateObject(wrappedValue: PaymentMethodViewModel(repository: repository))
    }
    var body: some View {
        List {
            Section("信贷方式") {
                ForEach(viewModel.creditMethods, id: \.id) { method in
                    VStack(alignment: .leading) {
                        Text(method.name)
                            .font(.headline)
                        Text("额度: \(method.creditLimit as NSDecimalNumber) | 欠费: \(method.outstandingBalance as NSDecimalNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button("添加信贷方式") {
                    showingAddCreditSheet = true
                }
            }
            
            Section("储蓄方式") {
                ForEach(viewModel.savingsMethods, id: \.id) { method in
                    VStack(alignment: .leading) {
                        Text(method.name)
                            .font(.headline)
                        Text("余额: \(method.balance as NSDecimalNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button("添加储蓄方式") {
                    showingAddSavingsSheet = true
                }
            }
        }
        .navigationTitle("支付方式")
        .sheet(isPresented: $showingAddCreditSheet) {
            addCreditMethodSheet
        }
        .sheet(isPresented: $showingAddSavingsSheet) {
            addSavingsMethodSheet
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .task {
            await viewModel.loadPaymentMethods()
        }
    }
    private var addCreditMethodSheet: some View {
        NavigationView {
            Form {
                TextField("名称", text: $creditName)
                TextField("信用额度", text: $creditLimit)
                    .keyboardType(.decimalPad)
                TextField("初始欠费", text: $outstandingBalance)
                    .keyboardType(.decimalPad)
                TextField("账单日", text: $billingDate)
                    .keyboardType(.numberPad)
                
                Picker("交易类型", selection: $creditTransactionType) {
                    Text("支出").tag(TransactionType.expense)
                    Text("收入").tag(TransactionType.income)
                    Text("不计入").tag(TransactionType.excluded)
                }
            }
            .navigationTitle("添加信贷方式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        resetCreditForm()
                        showingAddCreditSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await saveCreditMethod()
                        }
                    }
                }
            }
        }
    }
    private var addSavingsMethodSheet: some View {
        NavigationView {
            Form {
                TextField("名称", text: $savingsName)
                TextField("初始余额", text: $savingsBalance)
                    .keyboardType(.decimalPad)
                
                Picker("交易类型", selection: $savingsTransactionType) {
                    Text("支出").tag(TransactionType.expense)
                    Text("收入").tag(TransactionType.income)
                    Text("不计入").tag(TransactionType.excluded)
                }
            }
            .navigationTitle("添加储蓄方式")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        resetSavingsForm()
                        showingAddSavingsSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await saveSavingsMethod()
                        }
                    }
                }
            }
        }
    }
    
    private func saveCreditMethod() async {
        guard let limit = Decimal(string: creditLimit),
              let balance = Decimal(string: outstandingBalance),
              let date = Int(billingDate) else {
            showingError = true
            return
        }
        
        do {
            try await viewModel.createCreditMethod(
                name: creditName,
                transactionType: creditTransactionType,
                creditLimit: limit,
                outstandingBalance: balance,
                billingDate: date
            )
            resetCreditForm()
            showingAddCreditSheet = false
        } catch {
            showingError = true
        }
    }
    
    private func saveSavingsMethod() async {
        guard let balance = Decimal(string: savingsBalance) else {
            showingError = true
            return
        }
        
        do {
            try await viewModel.createSavingsMethod(
                name: savingsName,
                transactionType: savingsTransactionType,
                balance: balance
            )
            resetSavingsForm()
            showingAddSavingsSheet = false
        } catch {
            showingError = true
        }
    }
    
    private func resetCreditForm() {
        creditName = ""
        creditLimit = ""
        outstandingBalance = ""
        billingDate = ""
        creditTransactionType = .expense
    }
    
    private func resetSavingsForm() {
        savingsName = ""
        savingsBalance = ""
        savingsTransactionType = .expense
    }
}
