# Implementation Plan

- [x] 1. 设置项目结构和核心数据模型
  - 创建Xcode项目,配置SwiftUI和Core Data
  - 定义核心数据模型结构(Bill, PaymentMethod, BillCategory, Owner)
  - 实现Codable协议支持序列化
  - _Requirements: 10.5_

- [x] 1.1 编写数据模型属性测试
  - **Property 17: 数据持久化往返一致性**
  - **Validates: Requirements 10.5**

- [x] 2. 实现Repository层数据访问
  - 创建DataRepository协议定义
  - 实现CoreDataRepository类
  - 实现基本的CRUD操作(保存、查询、更新、删除)
  - _Requirements: 10.1, 10.2_

- [x] 2.1 编写Repository层单元测试
  - 测试CRUD操作的正确性
  - 测试数据查询和筛选
  - _Requirements: 10.1, 10.2_

- [x] 3. 实现账单类型管理功能
  - 创建CategoryViewModel
  - 实现账单类型的创建、编辑、删除功能
  - 实现名称唯一性验证
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ] 3.1 编写账单类型属性测试
  - **Property 3: 名称唯一性约束**
  - **Validates: Requirements 2.2**

- [ ]* 3.2 编写账单类型级联更新属性测试
  - **Property 4: 级联更新一致性**
  - **Validates: Requirements 2.4**

- [x] 4. 实现归属人管理功能
  - 创建OwnerViewModel
  - 实现归属人的创建、编辑、删除功能
  - 实现名称唯一性验证
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 4.1 编写归属人属性测试
  - **Property 3: 名称唯一性约束**
  - **Validates: Requirements 3.2**

- [ ]* 4.2 编写归属人级联更新属性测试
  - **Property 4: 级联更新一致性**
  - **Validates: Requirements 3.4**

- [x] 5. 实现支付方式管理功能
  - 创建PaymentMethodViewModel
  - 实现信贷方式的创建、编辑、删除功能
  - 实现储蓄方式的创建、编辑、删除功能
  - 实现信用额度验证逻辑
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ]* 5.1 编写信贷额度验证属性测试
  - **Property 5: 信贷额度验证**
  - **Validates: Requirements 4.2**

- [x] 6. 实现账单创建和余额更新逻辑
  - 创建BillViewModel
  - 实现账单创建功能
  - 实现输入验证(金额、必填字段)
  - 实现信贷方式余额自动更新逻辑
  - 实现储蓄方式余额自动更新逻辑
  - 实现信用额度限制检查
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_

- [ ]* 6.1 编写账单创建属性测试
  - **Property 1: 账单创建保存一致性**
  - **Validates: Requirements 1.1**

- [ ]* 6.2 编写时间戳自动生成属性测试
  - **Property 2: 时间戳自动生成**
  - **Validates: Requirements 1.6**

- [ ]* 6.3 编写信贷支出余额更新属性测试
  - **Property 6: 信贷支出余额更新**
  - **Validates: Requirements 6.1**

- [ ]* 6.4 编写信贷额度限制属性测试
  - **Property 7: 信贷额度限制**
  - **Validates: Requirements 6.2**

- [ ]* 6.5 编写信贷收入余额更新属性测试
  - **Property 8: 信贷收入余额更新**
  - **Validates: Requirements 6.3**

- [ ]* 6.6 编写储蓄支出余额更新属性测试
  - **Property 9: 储蓄支出余额更新**
  - **Validates: Requirements 6.4**

- [ ]* 6.7 编写储蓄收入余额更新属性测试
  - **Property 10: 储蓄收入余额更新**
  - **Validates: Requirements 6.5**

- [ ]* 6.8 编写不计入类型余额不变属性测试
  - **Property 11: 不计入类型不更新余额**
  - **Validates: Requirements 6.6**

- [x] 7. 实现账单编辑和删除功能
  - 实现账单金额编辑和余额重算
  - 实现账单支付方式切换和余额调整
  - 实现账单类型和归属人修改
  - 实现账单删除和余额恢复
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ]* 7.1 编写账单编辑余额重算属性测试
  - **Property 14: 账单编辑余额重算**
  - **Validates: Requirements 9.1**

- [ ]* 7.2 编写支付方式切换余额调整属性测试
  - **Property 15: 支付方式切换余额调整**
  - **Validates: Requirements 9.2**

- [ ]* 7.3 编写账单删除余额恢复属性测试
  - **Property 16: 账单删除余额恢复**
  - **Validates: Requirements 9.4**

- [x] 8. 实现账单筛选功能
  - 实现按账单类型筛选
  - 实现按归属人筛选
  - 实现按支付方式筛选
  - 实现按时间范围筛选
  - 实现多条件组合筛选
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [x] 8.1 编写筛选结果正确性属性测试
  - **Property 12: 筛选结果正确性**
  - **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

- [x] 9. 实现统计分析功能
  - 创建StatisticsViewModel
  - 实现总收入和总支出计算
  - 实现按账单类型统计
  - 实现按归属人统计
  - 实现按支付方式统计
  - 实现时间范围筛选
  - 排除"不计入"类型的账单
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

- [x] 9.1 编写统计计算准确性属性测试
  - **Property 13: 统计计算准确性**
  - **Validates: Requirements 8.1, 8.5**

- [x] 10. 实现Excel导出功能
  - 创建ExportViewModel
  - 实现CSV/Excel文件生成
  - 实现导出数据格式化
  - 实现文件保存和分享
  - 实现导出进度显示
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

- [x] 10.1 编写导出数据完整性属性测试
  - **Property 18: 导出数据完整性**
  - **Validates: Requirements 12.2**

- [x] 11. 实现UI视图层
  - 创建BillListView(账单列表)
  - 创建BillFormView(账单表单)
  - 创建PaymentMethodListView(支付方式管理)
  - 创建CategoryManagementView(账单类型管理)
  - 创建OwnerManagementView(归属人管理)
  - 创建StatisticsView(统计分析)
  - 实现表单输入验证和实时反馈
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [x] 12. 实现错误处理和用户反馈
  - 定义AppError错误类型
  - 实现错误提示UI(Alert/Toast)
  - 实现加载状态指示器
  - 实现空状态提示
  - 实现删除确认对话框
  - _Requirements: 10.3, 10.4_

- [x] 13. 最终检查点 - 确保所有测试通过
  - 确保所有测试通过,如有问题请询问用户

