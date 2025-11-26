import SwiftUI

/// 账单列表视图
struct BillListView: View {
    @StateObject private var billViewModel: BillViewModel
    @StateObject private var categoryViewModel: CategoryViewModel
    @StateObject private var ownerViewModel: OwnerViewModel
    @StateObject private var paymentViewModel: PaymentMethodViewModel
    @StateObject private var exportViewModel: ExportViewModel
    
    @State private var showingAddSheet = false
    @State private var showingError = false
    @State private var showingExportSheet = false
    @State private var exportedFileURL: URL?
    
    private let repository: DataRepository
    
    init(repository: DataRepository) {
        self.repository = repository
        _billViewModel = StateObject(wrappedValue: BillViewModel(repository: repository))
        _categoryViewModel = StateObject(wrappedValue: CategoryViewModel(repository: repository))
        _ownerViewModel = StateObject(wrappedValue: OwnerViewModel(repository: repository))
        _paymentViewModel = StateObject(wrappedValue: PaymentMethodViewModel(repository: repository))
        _exportViewModel = StateObject(wrappedValue: ExportViewModel(repository: repository))
    }
    
    var body: some View {
        Group {
            if billViewModel.bills.isEmpty {
                EmptyStateView(
                    message: "还没有账单记录",
                    systemImage: "doc.text"
                )
            } else {
                List {
                    ForEach(billViewModel.bills.sorted(by: { $0.createdAt > $1.createdAt })) { bill in
                        BillRowView(
                            bill: bill,
                            categories: categoryViewModel.categories,
                            owners: ownerViewModel.owners,
                            paymentMethods: paymentViewModel.paymentMethods
                        )
                    }
                    .onDelete(perform: deleteBills)
                }
            }
        }
        .navigationTitle("账单列表")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    exportBills()
                } label: {
                    if exportViewModel.isExporting {
                        ProgressView()
                    } else {
                        Label("导出", systemImage: "square.and.arrow.up")
                    }
                }
                .disabled(billViewModel.bills.isEmpty || exportViewModel.isExporting)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            BillFormView(
                repository: repository,
                categories: categoryViewModel.categories,
                owners: ownerViewModel.owners,
                paymentMethods: paymentViewModel.paymentMethods
            )
        }
        .sheet(isPresented: $showingExportSheet) {
            if let fileURL = exportedFileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
        } message: {
            if let error = billViewModel.errorMessage {
                Text(error)
            } else if let error = exportViewModel.errorMessage {
                Text(error)
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        await billViewModel.loadBills()
        await categoryViewModel.loadCategories()
        await ownerViewModel.loadOwners()
        await paymentViewModel.loadPaymentMethods()
    }
    
    private func exportBills() {
        Task {
            do {
                let fileURL = try await exportViewModel.exportToCSV(
                    bills: billViewModel.bills,
                    categories: categoryViewModel.categories,
                    owners: ownerViewModel.owners,
                    paymentMethods: paymentViewModel.paymentMethods
                )
                exportedFileURL = fileURL
                showingExportSheet = true
            } catch {
                showingError = true
            }
        }
    }
    
    private func deleteBills(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let bill = billViewModel.bills[index]
                do {
                    try await billViewModel.deleteBill(bill)
                } catch {
                    showingError = true
                }
            }
        }
    }
}

/// 账单行视图
struct BillRowView: View {
    let bill: Bill
    let categories: [BillCategory]
    let owners: [Owner]
    let paymentMethods: [PaymentMethodWrapper]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(bill.amount as NSDecimalNumber)")
                    .font(.headline)
                Spacer()
                Text(bill.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let owner = owners.first(where: { $0.id == bill.ownerId }) {
                Text("归属人: \(owner.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let payment = paymentMethods.first(where: { $0.id == bill.paymentMethodId }) {
                Text("支付方式: \(payment.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            let categoryNames = bill.categoryIds.compactMap { id in
                categories.first(where: { $0.id == id })?.name
            }.joined(separator: ", ")
            
            if !categoryNames.isEmpty {
                Text("类型: \(categoryNames)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let note = bill.note, !note.isEmpty {
                Text("备注: \(note)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// 分享Sheet包装器
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
