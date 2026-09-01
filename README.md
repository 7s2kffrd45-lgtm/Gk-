# 🗓️ GK课表

一款基于 **HarmonyOS（鸿蒙）** 开发的课程表应用，个人独立开发项目（完善中）。

登录后自动拉取整学期课程数据，以"周"为单位进行**网格化课表展示**，支持课程详情查看、本地数据持久化（杀后台/重启不丢数据），界面适配**沉浸式光感材质**与深浅色模式。

> 正在学习鸿蒙开发的小伙伴欢迎 star ⭐ / fork，有任何问题可以直接提 Issue。

---

## ✨ 功能特性

- 🔐 **学号密码登录认证**：对接后端登录接口，支持验证码流程
- 📅 **整学期课表拉取**：登录后自动获取整学期课程数据，按教学周过滤展示
- 🗂️ **网格化课表渲染**：周一至周日 7 列 × 12 节次自适应排版，**多门课程重叠时自动堆叠显示**
- 🔢 **动态计算当前教学周**：自动根据学期起始日期计算当前周数
- 📖 **课程详情页**：查看课程名称、教师、教室、节次、考核方式等信息
- 💾 **本地持久化**：基于 Preferences 缓存登录状态与课表数据，杀后台/重启应用后无需重新登录
- ✨ **沉浸式光感材质**：自动检测设备是否支持 UIMaterial，支持设备开启沉浸光感，并适配安全区显示
- 🧭 **自定义底部导航**：首页 / 课程 / 我的 多页面导航（Navigation + NavPathStack）

## 🛠️ 技术栈

| 分类 | 技术 |
| --- | --- |
| 开发语言 | ArkTS |
| UI 框架 | ArkUI 声明式开发（`@ComponentV2` / `@Local` / `@Provider` / `@Consumer` / `AppStorageV2`） |
| 页面导航 | Navigation + NavPathStack |
| 网络请求 | rcp（Remote Communication Kit） |
| 本地存储 | `@ohos.data.preferences` |
| 开发工具 | DevEco Studio（API 12+） |

## 📁 项目结构

```
KBL/
├── AppScope/                     # 应用全局配置
├── entry/
│   ├── src/main/
│   │   ├── module.json5          # 模块配置（权限、Ability 等）
│   │   └── ets/
│   │       ├── entryability/     # EntryAbility 应用入口
│   │       ├── pages/            # 页面：登录页 / 首页 / 课表页 / 详情页
│   │       ├── views/            # 自定义组件：课表网格、节次栏、底部导航等
│   │       ├── models/           # 数据模型与工具（安全区、材质检测等）
│   │       ├── preferenceUtil/   # Preferences 本地持久化封装
│   │       └── rcpModles/        # 网络请求与课表数据处理算法
│   ├── src/mock/                 # Mock 数据配置
│   └── src/test/                 # 单元测试
├── build-profile.json5           # 工程构建配置
└── oh-package.json5              # 依赖配置
```

## 🚀 运行方法

### 环境要求

- DevEco Studio 5.x（支持 ArkTS / API 12+）
- HarmonyOS 模拟器或真机（仅支持 phone 设备类型）

### 步骤

1. **克隆仓库**

   ```bash
   git clone https://github.com/7s2kffrd45-lgtm/Gk-.git
   ```

2. **启动后端服务**

   应用需要后端提供登录与课表接口（见下方接口约定），默认请求地址为 `http://10.0.2.2:3000`。

3. **用 DevEco Studio 打开项目**

   配置好签名后，运行到模拟器或真机：
   - 模拟器访问电脑本机服务使用 `10.0.2.2`
   - 真机请将 `entry/src/main/ets/rcpModles/rcpUtil.ets` 中的 `baseUrl` 改为电脑局域网 IP

## 🔌 后端接口约定

| 接口 | 方法 | 说明 |
| --- | --- | --- |
| `/api/login` | POST | 学号密码登录，返回 `token` 与用户名 |
| `/api/schedule` | GET | 携带 `token` 与 `termStart` 获取整学期课程数据 |

课表数据结构（`courses[]`）：

```
courseName 课程名称 | weeks 上课周次 | teacher 教师 | periods 节次
classroom 教室 | examMethod 考核方式 | dayOfWeek 星期 | dayName 星期名称 | dates 具体日期
```

## 🗺️ 开发计划

- [ ] 课表图片识别导入（详情页已预留入口）
- [ ] 考试倒计时与课程提醒
- [ ] 课表导出 / 分享
- [ ] 深浅色模式手动切换

## 📄 License

本项目仅供学习交流使用。
