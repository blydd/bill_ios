# Requirements Document

## Introduction

本文档定义了一个基于标签的iOS记账应用系统。该系统允许用户通过灵活的标签系统来记录和管理个人财务交易，支持多种账户类型（如信贷账户、现金账户等），并提供直观的交易分类和查询功能。

## Glossary

- **Transaction System**: 交易系统，负责记录、存储和管理所有财务交易的核心系统
- **Bill**: 账单，单次收入或支出的财务记录
- **Payment Account**: 支付账户，用于支付账单的账户，分为信贷账户和储蓄账户两大类
- **Credit Account**: 信贷账户，包括信用卡、花呗等信贷类支付方式的账户类别
- **Credit Method**: 信贷方式，信贷账户下的具体支付方式（如某银行信用卡、花呗等）
- **Savings Account**: 储蓄账户，包括储蓄卡、微信零钱等即时支付方式的账户类别
- **Savings Method**: 储蓄方式，储蓄账户下的具体支付方式（如某银行储蓄卡、微信零钱等）
- **Bill Category**: 账单类型，用于分类账单的类别（如衣、食、住、行等）
- **Owner**: 归属人，账单所属的家庭成员（如丈夫、妻子、女儿等）
- **Credit Limit**: 信用额度，信贷方式可用的最大信用金额
- **Outstanding Balance**: 欠费金额，信贷方式当前未还款的金额
- **Billing Date**: 账单日，信贷方式的账单生成日期
- **Transaction Type**: 交易类型，标记支付方式是用于收入、支出还是不计入统计

## Requirements

### Requirement 1

**User Story:** 作为用户，我想要创建新的账单记录，以便记录我的收入和支出。

#### Acceptance Criteria

1. WHEN 用户输入账单金额、选择一个支付方式、选择至少一个账单类型、选择一个归属人 THEN THE Transaction System SHALL 创建新的账单记录并保存到本地存储
2. WHEN 用户尝试创建金额为零或负数的账单 THEN THE Transaction System SHALL 拒绝该账单并提示用户输入有效金额
3. WHEN 用户创建账单时未选择支付方式 THEN THE Transaction System SHALL 阻止账单创建并提示用户选择支付方式
4. WHEN 用户创建账单时未选择账单类型 THEN THE Transaction System SHALL 阻止账单创建并提示用户选择至少一个账单类型
5. WHEN 用户创建账单时未选择归属人 THEN THE Transaction System SHALL 阻止账单创建并提示用户选择归属人
6. WHEN 账单成功创建 THEN THE Transaction System SHALL 自动记录账单创建的时间戳

### Requirement 2

**User Story:** 作为用户，我想要管理账单类型，以便对账单进行分类。

#### Acceptance Criteria

1. WHEN 用户创建新的账单类型 THEN THE Transaction System SHALL 验证类型名称唯一性并保存该类型
2. WHEN 用户输入已存在的账单类型名称 THEN THE Transaction System SHALL 拒绝创建并提示用户该类型已存在
3. WHEN 用户查看账单类型列表 THEN THE Transaction System SHALL 显示所有已创建的账单类型
4. WHEN 用户编辑账单类型名称 THEN THE Transaction System SHALL 更新该类型并同步更新所有使用该类型的账单
5. WHEN 用户删除某个账单类型 THEN THE Transaction System SHALL 从所有使用该类型的账单中移除该类型引用
6. WHEN 用户为账单选择类型 THEN THE Transaction System SHALL 允许选择一个或多个账单类型

### Requirement 3

**User Story:** 作为用户，我想要管理归属人，以便标记账单属于哪个家庭成员。

#### Acceptance Criteria

1. WHEN 用户创建新的归属人 THEN THE Transaction System SHALL 验证归属人名称唯一性并保存该归属人
2. WHEN 用户输入已存在的归属人名称 THEN THE Transaction System SHALL 拒绝创建并提示用户该归属人已存在
3. WHEN 用户查看归属人列表 THEN THE Transaction System SHALL 显示所有已创建的归属人
4. WHEN 用户编辑归属人名称 THEN THE Transaction System SHALL 更新该归属人并同步更新所有关联的账单
5. WHEN 用户删除某个归属人 THEN THE Transaction System SHALL 阻止删除并提示用户该归属人仍被账单使用
6. WHEN 用户为账单选择归属人 THEN THE Transaction System SHALL 只允许选择一个归属人

### Requirement 4

**User Story:** 作为用户，我想要管理信贷账户下的信贷方式，以便追踪各种信用卡和花呗等的使用情况。

#### Acceptance Criteria

1. WHEN 用户在信贷账户下创建新的信贷方式 THEN THE Transaction System SHALL 要求用户输入方式名称、信用额度、账单日和初始欠费金额
2. WHEN 用户创建信贷方式时输入的信用额度小于初始欠费金额 THEN THE Transaction System SHALL 拒绝创建并提示用户额度不足
3. WHEN 用户为信贷方式设置交易类型 THEN THE Transaction System SHALL 允许选择收入、支出或不计入三种类型之一
4. WHEN 用户查看信贷方式 THEN THE Transaction System SHALL 显示方式名称、当前可用额度、欠费金额、账单日和关联的账单列表
5. WHEN 用户编辑信贷方式的额度或账单日 THEN THE Transaction System SHALL 更新该信贷方式的属性
6. WHEN 用户删除某个信贷方式 THEN THE Transaction System SHALL 阻止删除并提示用户该方式仍被账单使用

### Requirement 5

**User Story:** 作为用户，我想要管理储蓄账户下的储蓄方式，以便追踪各种储蓄卡和微信零钱等的使用情况。

#### Acceptance Criteria

1. WHEN 用户在储蓄账户下创建新的储蓄方式 THEN THE Transaction System SHALL 要求用户输入方式名称和初始余额
2. WHEN 用户创建储蓄方式时输入负数余额 THEN THE Transaction System SHALL 拒绝创建并提示用户输入有效余额
3. WHEN 用户为储蓄方式设置交易类型 THEN THE Transaction System SHALL 允许选择收入、支出或不计入三种类型之一
4. WHEN 用户查看储蓄方式 THEN THE Transaction System SHALL 显示方式名称、当前余额和关联的账单列表
5. WHEN 用户编辑储蓄方式的名称 THEN THE Transaction System SHALL 更新该储蓄方式的属性
6. WHEN 用户删除某个储蓄方式 THEN THE Transaction System SHALL 阻止删除并提示用户该方式仍被账单使用

### Requirement 6

**User Story:** 作为用户，我想要账单关联支付方式时自动更新额度和余额，以便准确追踪资金状况。

#### Acceptance Criteria

1. WHEN 用户使用信贷方式创建支出账单且欠费金额增加后不超过信用额度 THEN THE Transaction System SHALL 增加该信贷方式的欠费金额并减少可用额度
2. WHEN 用户使用信贷方式创建支出账单且欠费金额增加后超过信用额度 THEN THE Transaction System SHALL 拒绝创建账单并提示用户额度不足
3. WHEN 用户使用信贷方式创建收入账单 THEN THE Transaction System SHALL 减少该信贷方式的欠费金额并增加可用额度
4. WHEN 用户使用储蓄方式创建支出账单 THEN THE Transaction System SHALL 减少该储蓄方式的余额
5. WHEN 用户使用储蓄方式创建收入账单 THEN THE Transaction System SHALL 增加该储蓄方式的余额
6. WHEN 用户使用标记为不计入的支付方式创建账单 THEN THE Transaction System SHALL 不更新该方式的额度或余额

### Requirement 7

**User Story:** 作为用户，我想要查询和筛选账单记录，以便分析我的消费模式。

#### Acceptance Criteria

1. WHEN 用户按账单类型筛选账单 THEN THE Transaction System SHALL 返回包含任一所选类型的所有账单记录
2. WHEN 用户按归属人筛选账单 THEN THE Transaction System SHALL 返回任一所选归属人的所有账单记录
3. WHEN 用户按支付方式筛选账单 THEN THE Transaction System SHALL 返回使用任一所选支付方式的所有账单记录
4. WHEN 用户按账单时间范围筛选账单 THEN THE Transaction System SHALL 返回账单时间在指定时间段内的所有账单记录
5. WHEN 用户组合多个筛选条件 THEN THE Transaction System SHALL 返回同时满足所有条件的账单记录
6. WHEN 筛选结果为空 THEN THE Transaction System SHALL 显示空状态提示而不是错误信息

### Requirement 8

**User Story:** 作为用户，我想要查看统计信息，以便了解我的财务状况。

#### Acceptance Criteria

1. WHEN 用户查看统计页面 THEN THE Transaction System SHALL 计算并显示指定时间段内的总收入和总支出
2. WHEN 用户选择按账单类型统计 THEN THE Transaction System SHALL 显示每个类型对应的账单总额
3. WHEN 用户选择按归属人统计 THEN THE Transaction System SHALL 显示每个归属人的收支情况
4. WHEN 用户选择按支付方式统计 THEN THE Transaction System SHALL 显示每个支付方式的使用情况
5. WHEN 统计计算时 THEN THE Transaction System SHALL 排除标记为不计入的支付方式的账单
6. WHEN 用户选择时间范围 THEN THE Transaction System SHALL 重新计算该时间段的统计数据


### Requirement 9

**User Story:** 作为用户，我想要编辑和删除已有的账单记录，以便纠正错误或移除无效记录。

#### Acceptance Criteria

1. WHEN 用户编辑账单金额 THEN THE Transaction System SHALL 更新账单记录并重新计算相关支付方式的额度或余额
2. WHEN 用户修改账单的支付方式 THEN THE Transaction System SHALL 恢复原支付方式的额度或余额并更新新支付方式的额度或余额
3. WHEN 用户修改账单的账单类型或归属人 THEN THE Transaction System SHALL 更新账单的关联信息
4. WHEN 用户删除账单 THEN THE Transaction System SHALL 移除账单记录并恢复相关支付方式的额度或余额
5. WHEN 账单被修改 THEN THE Transaction System SHALL 保留原始创建时间但记录最后修改时间

### Requirement 10

**User Story:** 作为用户，我想要数据能够持久化保存，以便在应用重启后仍能访问我的记录。

#### Acceptance Criteria

1. WHEN 用户创建或修改账单、支付方式、账单类型或归属人 THEN THE Transaction System SHALL 立即将数据保存到本地存储
2. WHEN 应用启动 THEN THE Transaction System SHALL 从本地存储加载所有账单、支付方式、账单类型和归属人数据
3. WHEN 数据加载失败 THEN THE Transaction System SHALL 显示错误信息并提供重试选项
4. WHEN 数据保存失败 THEN THE Transaction System SHALL 通知用户并保留数据在内存中直到成功保存
5. WHEN 数据序列化和反序列化 THEN THE Transaction System SHALL 保持数据完整性和一致性

### Requirement 11

**User Story:** 作为用户，我想要应用界面简洁直观，以便快速完成记账操作。

#### Acceptance Criteria

1. WHEN 用户打开应用 THEN THE Transaction System SHALL 在1秒内显示主界面
2. WHEN 用户点击添加账单按钮 THEN THE Transaction System SHALL 显示账单创建表单
3. WHEN 用户在表单中输入数据 THEN THE Transaction System SHALL 提供实时输入验证反馈
4. WHEN 用户完成账单创建 THEN THE Transaction System SHALL 关闭表单并返回账单列表
5. WHEN 账单列表更新 THEN THE Transaction System SHALL 平滑地显示新账单而不出现闪烁


### Requirement 12

**User Story:** 作为用户，我想要将筛选后的账单数据导出为Excel文件，以便进行进一步的分析和备份。

#### Acceptance Criteria

1. WHEN 用户在账单列表页面点击导出按钮 THEN THE Transaction System SHALL 将当前筛选条件下的所有账单导出为Excel文件
2. WHEN 导出Excel文件 THEN THE Transaction System SHALL 包含账单时间、金额、账单类型、归属人、支付方式和备注等所有字段
3. WHEN 导出操作开始 THEN THE Transaction System SHALL 显示导出进度指示器
4. WHEN 导出成功完成 THEN THE Transaction System SHALL 提示用户保存文件位置并允许用户选择保存路径
5. WHEN 导出失败 THEN THE Transaction System SHALL 显示错误信息并允许用户重试
6. WHEN 导出的账单数据为空 THEN THE Transaction System SHALL 提示用户当前没有可导出的数据
