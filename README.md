# MeshTalk

MeshTalk 是一个以 [bitchat](https://github.com/permissionlesstech/bitchat) iOS 与
[bitchat-android](https://github.com/permissionlesstech/bitchat-android) 为上游的独立分支。

- 应用名称：**MeshTalk**
- 仓库：<https://github.com/e2168708352-web/MeshTalk>
- 官网：<https://e2168708352-web.github.io/MeshTalk/>（源码见 `docs/`）
- Android `applicationId` / iOS Bundle ID：`com.meshtalk.app`
- 版本：`1.0.0`（versionCode `1`）
- Android 最低版本：API 26；目标版本：API 37
- iOS 最低版本：iOS 16.0
- 上游协议实现、加密算法和包格式保持不变；品牌、图标、配色已独立，**网络命名空间与官方一致**，两端可与官方 bitchat 互通。

> 当前状态：两端安装包均由 GitHub Actions 云构建产出，并已完成 Android ↔ iOS、
> Android ↔ Android、iOS ↔ iOS 三种组合的真实设备通信验证。Android 单元测试 631 项
> 全部通过；iOS 产出无签名 IPA，需自行重签后安装。

## 项目由来

官方 bitchat 应用在中国区 App Store 无法获取，部分用户没有合法渠道安装。本项目从
官方开源仓库拉取源码自行构建，提供可直接安装的包。

- **非商业**。不收费、无广告、无内购，不收集任何用户数据，不做用户画像。
  构建与分发由个人维护，没有商业主体参与。
- **源码来源可核验**。代码取自 [`permissionlesstech/bitchat`](https://github.com/permissionlesstech/bitchat)
  与 [`bitchat-android`](https://github.com/permissionlesstech/bitchat-android)，
  基线提交日期 2026-10-23，未引入任何第三方代码。任何人都可以按 `NOTICE.md`
  记录的上游地址逐文件比对。
- **协议与加密实现未改动**。BLE 包格式、Noise 握手与端到端加密逻辑与上游一致；
  改动的只是品牌资产、Bundle ID、以及用于网络发现与寻址的命名空间常量。
- **与官方互通**。本分支的 BLE 服务 UUID、Nostr 事件类型、私信前缀、Wi-Fi
  Direct/Aware 标识符均已统一为上游值，因此官方 bitchat 客户端可以与 MeshTalk
  用户互相发现并通信。详见下方「与官方 bitchat 互通」一节。
- **与官方的具体差异**：品牌名称与图标、配色、Bundle ID `com.meshtalk.app`、
  URL scheme `meshtalk://`，以及两个消息归属判定的缺陷修复。网络层与上游完全一致。
- **跟进上游**。截至 2026-10-24，本分支**已与上游 `main` 完全对齐**：iOS 侧补齐了
  geochat 性能优化、消息归属判定修复与加密依赖升级；Android 侧导入时即与
  `bitchat-android` 同步，无需移植。后续会持续跟进官方的安全修复与协议变更。
- **与官方的关系**：本分支与 bitchat 项目及其维护者无隶属、背书或赞助关系。
  官方不会为本分支的任何问题提供支持。

## 目录

```
MeshTalk/
├─ android/                 Android 应用（Gradle）
├─ ios/                     iOS / macOS 应用（Xcode + SwiftPM）
├─ .github/workflows/       Android APK 与 iOS unsigned IPA 云构建
├─ NOTICE.md                上游归属、许可证与合规说明
└─ LICENSE                  GPLv3 文本（Android 衍生部分；iOS 部分另见 ios/LICENSE）
```

## 与官方 bitchat 互通

MeshTalk 使用与官方完全相同的网络命名空间，因此官方 bitchat 用户与 MeshTalk
用户可以在同一个 BLE mesh 或 Nostr relay 上互相发现、互相通信。底层包格式、
Noise 握手与端到端加密本来就与上游一致，此处只是把发现与寻址用的标识符也
统一回上游值。

| 项目 | 值 |
| --- | --- |
| BLE 主服务 UUID | `F47B5E2D-4A9E-4C5A-9B3F-8E1D2C3A4B5C`（mainnet） |
| BLE 主服务 UUID（DEBUG） | `F47B5E2D-4A9E-4C5A-9B3F-8E1D2C3A4B5A`（testnet） |
| BLE 特征 UUID | `A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D` |
| Nostr kinds | `1` / `1059` / `20000` / `20001` / `1401` |
| Nostr 私信前缀 | `bitchat1:` |
| Wi‑Fi Direct SSID 前缀 | `DIRECT-BC-` |
| Wi‑Fi Aware 服务名 | `bitchat` |

本分支独有的部分：应用名称、图标、Bundle ID `com.meshtalk.app`、
URL Scheme `meshtalk://`，以及上面提到的两个缺陷修复。

已完成的真机通信验证覆盖三种设备组合：**Android ↔ iOS 跨平台**、
**Android ↔ Android**、**iOS ↔ iOS**，双向收发正常。

> 需要说明的是，官方 bitchat 客户端不会把 MeshTalk 显示为「MeshTalk」——
> 它们按昵称与公钥识别节点，与识别任何其他 bitchat 节点一致。这不影响通信，
> 但意味着双方看到的对端名称由各自的昵称设置决定。

应用运行时不再从上游仓库下载 relay 列表或 APK 更新元数据：

- iOS 的 `GeoRelayDirectory` 只使用内置 `ios/relays/online_relays_gps.csv`。
- Android 的 `RelayDirectory` 只使用内置 `android/app/src/main/assets/nostr_relays.csv`。
- Android 已删除远程 APK 更新/下载入口，仅保留本机 APK 分享。
- 协议域分隔符（如 `bitchat-board-v1`）刻意保持不变，以避免破坏包兼容性；
  它们不参与网络发现，也不构成与官方客户端的互通通道。

公共 Nostr relay 本身是共享基础设施。MeshTalk 使用独立的 event kind 和私信前缀，
所以即使连接同一个 relay，官方客户端也不会解析 MeshTalk 的消息。

## Android 构建

要求：JDK 21、Android SDK Platform 37、Build Tools 37.0.0。

```powershell
cd android
.\gradlew.bat :app:assembleDebug --console=plain --no-daemon
```

产物：

```
android/app/build/outputs/apk/debug/app-universal-debug.apk
```

安装：

```powershell
adb install -r android/app/build/outputs/apk/debug/app-universal-debug.apk
```

也可以把 APK 传到手机后手动安装，需要在系统中允许“安装未知应用”。

当前 APK 使用 Android **debug 签名**，只适合测试和侧载。正式分发前请创建自己的
release keystore，并在 `android/app/build.gradle.kts` 中配置 `signingConfigs`；
不要复用 debug 密钥。

构建会自动生成按 ABI 拆分的 APK 以及一个通用 APK。通用包较大，但兼容性最好。

## iOS 构建

iOS 需要 macOS + Xcode 26 或更新版本。品牌与 Bundle ID 已经配置好：

- 工程：`ios/MeshTalk.xcodeproj`
- Scheme：`MeshTalk (iOS)`
- 显示名称：`MeshTalk`
- Bundle ID：`com.meshtalk.app`
- App Group：`group.com.meshtalk.app`
- 分享扩展 Bundle ID：`com.meshtalk.app.ShareExtension`

### 使用 GitHub Actions 生成无签名 IPA

工作流 `.github/workflows/ios-unsigned.yml` 已在仓库中配置并验证通过
（runner `macos-26`）：

- 推送到 `main` 且改动落在 `ios/**` 时自动触发；
- 也可在 **Actions → iOS unsigned IPA → Run workflow** 手动触发；
- 构建完成后下载 artifact `MeshTalk-unsigned-ipa`，内含
  `MeshTalk-unsigned.ipa` 与其 SHA-256 校验文件。

构建采用 `CODE_SIGNING_ALLOWED=NO`，因此产物没有签名，不能直接安装到非越狱设备。
需要用你自己的 Apple Developer 证书重签（或使用 Sideloadly 之类工具以 Apple ID
本地重签），也可以在 Xcode 中选择你的 Team 后直接运行到真机。

### 本机签名构建

```bash
cd ios
cp Configs/Local.xcconfig.example Configs/Local.xcconfig
# 编辑 Configs/Local.xcconfig，填入 DEVELOPMENT_TEAM
open MeshTalk.xcodeproj
```

在 Xcode 中选择 `MeshTalk (iOS)` scheme 和你的开发团队，然后运行到真机。
首次使用需要在 Apple Developer 后台注册 App Group
`group.com.meshtalk.app`，并让主应用与分享扩展都使用该 App Group。

`Configs/Local.xcconfig` 已被 `.gitignore` 忽略，不要把 Team ID、证书或描述文件提交到仓库。

## 许可证与合规

- iOS 上游为 **Unlicense**（公共领域），见 `ios/LICENSE`。
- Android 上游为 **GNU GPLv3**，见 `android/LICENSE.md`。
- MeshTalk 对 Android 部分的修改同样按 GPLv3 提供；分发 APK 时必须同时提供对应源码。
- 上游版权与项目归属见 `NOTICE.md`。MeshTalk 与上游项目没有官方关联。

发布前请自行评估：

1. **App Store 审核指南 4.3（Spam）**：与现有应用高度相似的分支可能被拒。
2. **Google Play 政策**：自行分发 APK 不受 Play 审核约束，但上架 Play 需要满足
   开发者账号、签名、数据安全表单与目标 API 等要求。
3. **加密出口合规**：应用包含加密功能，向某些国家/地区分发前请确认当地法律。
4. **商标与图标**：不要使用 bitchat 名称、图标或官方商店素材；MeshTalk 已使用独立品牌。
5. **蓝牙与定位权限**：上架说明必须与实际用途一致。

## 已知限制

- **真机验证已完成。** 已完成 **Android ↔ iOS 跨平台**、**Android ↔ Android**、
  **iOS ↔ iOS** 三种组合的真实设备通信验证，双向收发正常。验证范围是基础通信链路；
  分享扩展、后台唤醒、大文件传输等边界场景尚未逐项覆盖。
- iOS 蓝牙权限：`.unauthorized` 有三种成因，应用已按成因区分提示文案——用户拒绝、设备
  策略限制（屏幕使用时间 / MDM）、以及系统已授权但进程仍被拒。第三种在重签或覆盖安装后
  常见：`CBCentralManager` 会缓存创建时的授权状态，应用已在前台恢复时用
  `CBManager.authorization` 比对并重建管理器。但实测最有效的处置是**重启设备**，清掉
  `bluetoothd` 的残留状态；重启后仍不恢复，再删除应用重新安装。
- Android CI 依赖 runner 预装的 SDK，不要在 `ubuntu-latest` 上使用
  `android-actions/setup-android`：该动作内部执行 `sdkmanager tools`，而 `tools`
  包已被上游移除，会直接失败。同时 `sdkmanager` 不在 PATH 上，需从
  `$ANDROID_HOME/cmdline-tools/*/bin` 解析；平台包名是 `platforms;android-37.0`
  （API 37.0 / Android 17），不是 `platforms;android-37`。
- 在 Windows 上运行 Android 单元测试时，Robolectric 的临时目录可能因路径过长
  触发 `SQLITE_CANTOPEN`。把临时目录指到短路径即可：

  ```powershell
  $env:JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=D:\t"
  .\gradlew.bat :app:testDebugUnitTest --console=plain --no-daemon
  ```

  本机已用该方式跑通全部 631 个单元测试。
- 分享文案中的 App Store 链接是占位地址；正式发布前请替换为真实商店页面。
