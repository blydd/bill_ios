import SwiftUI

/// 账单表单视图
struct BillFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var billViewModel: BillViewModel
    
    let categories: [BillCategory]
    let owners: [Owner]
    let paymentMethods: [PaymentMethodWrapper]
    
    @State private var amount = ""
    @State private var selectedPaymentMethodId: UUID?
    @State private var selectedCategoryIds: Set<UUID> = []
    @State private var selectedOwnerId: UUID?
    @State private var note = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(repository: DataRepository,
         categories: [BillCategory],
         owners: [Owner],
         paymentMethods: [PaymentMethodWrapper]) {
        _billViewModel = StateObject(wrappedValue: BillViewModel(repository: repository))
        self.categories = categories
        self.owners = owners
        self.paymentMethods = paymentMethods
    }
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("金额", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("支付方式", selection: $selectedPaymentMethodId) {
                        Text("请选择").tag(nil as UUID?)
                                               ForEach(paymentMethods, id: \.id) { method in
                            Text(method.name).tag(method.id as UUID?)
                        }
                    }
                    
                    Picker("归属人", selection: $selectedOwnerId) {
                        Text("请选择").tag(nil as UUID?)
                        ForEach(owners) { owner in
                            Text(owner.name).tag(owner.id as UUID?)
                        }
                    }
                }
                
                Section("账单类型") {
                    ForEach(categories) { category in
                        Toggle(category.name, isOn: Binding(
                            get: { selectedCategoryIds.contains(category.id) },
                            set: { isOn in
                                if isOn {
                                    selectedCategoryIds.insert(category.id)
                                } else {
                                    selectedCategoryIds.remove(category.id)
                                }
                            }
                        ))
                    }
                }
                
                Section("备注") {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
            }
            .navigationTitle("添加账单")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await saveBill()
                        }
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("错误", isPresented: $showingError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    private var isFormValid: Bool {
        guard let amountValue = Decimal(string: amount), amountValue > 0 else {
            return false
        }
        guard selectedPaymentMethodId != nil else {
            return false
        }
        guard !selectedCategoryIds.isEmpty else {
            return false
        }
        guard selectedOwnerId != nil else {
            return false
        }
        return true
    }
    
    private func saveBill() async {
        guard let amountValue = Decimal(string: amount),
              let paymentMethodId = selectedPaymentMethodId,
              let ownerId = selectedOwnerId else {
            errorMessage = "请填写完整信息"
            showingError = true
            return
        }
        
        do {
            try await billViewModel.createBill(
                amount: amountValue,
                paymentMethodId: paymentMethodId,
                categoryIds: Array(selectedCategoryIds),
                ownerId: ownerId,
                note: note.isEmpty ? nil : note
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
