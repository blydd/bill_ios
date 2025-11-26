import SwiftUI

/// 账单类型管理视图
struct CategoryManagementView: View {
    @StateObject private var viewModel: CategoryViewModel
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    @State private var editingCategory: BillCategory?
    @State private var newCategoryName = ""
    @State private var showingError = false
    
    init(repository: DataRepository) {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(repository: repository))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.categories) { category in
                HStack {
                    Text(category.name)
                    Spacer()
                    Button("编辑") {
                        editingCategory = category
                        newCategoryName = category.name
                        showingEditSheet = true
                    }
                    .buttonStyle(.borderless)
                }
            }
            .onDelete(perform: deleteCategories)
        }
        .navigationTitle("账单类型")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            addCategorySheet
        }
        .sheet(isPresented: $showingEditSheet) {
            editCategorySheet
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .task {
            await viewModel.loadCategories()
        }
    }
    
    private var addCategorySheet: some View {
        NavigationView {
            Form {
                TextField("类型名称", text: $newCategoryName)
            }
            .navigationTitle("添加类型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        newCategoryName = ""
                        showingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            do {
                                try await viewModel.createCategory(name: newCategoryName)
                                newCategoryName = ""
                                showingAddSheet = false
                            } catch {
                                showingError = true
                            }
                        }
                    }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var editCategorySheet: some View {
        NavigationView {
            Form {
                TextField("类型名称", text: $newCategoryName)
            }
            .navigationTitle("编辑类型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        newCategoryName = ""
                        editingCategory = nil
                        showingEditSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            if let category = editingCategory {
                                do {
                                    try await viewModel.updateCategory(category, newName: newCategoryName)
                                    newCategoryName = ""
                                    editingCategory = nil
                                    showingEditSheet = false
                                } catch {
                                    showingError = true
                                }
                            }
                        }
                    }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let category = viewModel.categories[index]
                do {
                    try await viewModel.deleteCategory(category)
                } catch {
                    showingError = true
                }
            }
        }
    }
}
