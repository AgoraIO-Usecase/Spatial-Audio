# Agora游戏引擎

Agora游戏引擎是 Agora 针对电子竞技类游戏提供的实时音视频解决方案，主要用于实现范围语音和 3D 音效等功能，为玩家提供互动沉浸式的游戏体验。

## 范围语音

范围语音功能可以灵活设置同一个房间内玩家之间的声音可达性，从而增加游戏的趣味性和互动性。

通过设置小队、语音模式和语音接收范围，决定同一个房间内的玩家之间能否相互听见对方的声音，规则如下：

- 当玩家属于同一小队时，无论距离多远、采用何种语音模式，都可以听见彼此的声音。
- 当玩家属于不同小队时，只有在语音模式都设为“所有人”，且在彼此的语音接收范围内时，才能相互听见。

## 3D 音效

3D 音效能塑造声音的空间感，并随着声源位置的移动改变声音的大小，使玩家获得身临其境之感。

## 前置步骤

### 获取声网 App ID
通过以下步骤获取声网 App ID：

- 在声网控制台创建一个账号。
- 登录声网控制台，创建一个项目，鉴权方式选择 “App ID + App 证书 + Token”。注意，请确保该项目启用了 App 证书。
- 前往项目管理页面，获取该项目的 App ID。

### 生成 token

1. 如果没有启用 App 证书，则不需要生成token。在调用相关接口的时候，传入空字符串。
2. 下载token生成器的代码
```
git clone https://github.com/AgoraIO/Tools.git
```
3. 以 python token生成器的使用为例
	* 编辑 Tools/DynamicKey/AgoraDynamicKey/python/src/RtcTokenBuilder.py 文件，在48行下面加如下代码，使生成的token支持RTM登录
	```
	token.addPrivilege(kRtmLogin, privilegeExpiredTs)
	```
	* 编辑 Tools/DynamicKey/AgoraDynamicKey/python/sample/RtcTokenBuilderSample.py 文件，修改 appID, appCertificate, channelName, uid 为自己使用的 App ID, App 证书, 房间名称, 整型 user ID
	* 运行 python 脚本，生成token
	```
	cd Tools/DynamicKey/AgoraDynamicKey/python/sample/
	python RtcTokenBuilderSample.py
	```

### 注意事项
在使用空间语音前，请联系我们市场销售人员，告诉我们你将要使用的App ID，以便我们为你开启该功能

## 运行示例程序

### Windows
1. 用 Visual Studio 2017 或更新版本，打开Windows/spatial_audio.sln文件。
2. 将有效的 AppID 定义为 TEST_APP_ID 宏。
```
#define TEST_APP_ID "YOUR_TEST_APP_ID"
```
3. 解压 Windows SDK 压缩包，将其中的 **libs** 文件夹下的所有文件，复制到 **Windows/deps** 文件夹下。
4. 用 Visual Studio 编译项目。
5. 按照下面的命令格式，运行示例程序
```
#如果没有启用App证书，则YOUR_TEST_TOKEN为""
spatial_audio.exe YOUR_TEST_TOKEN TEST_ROOM_NAME TEST_USER_ID
```

#### iOS
1. 编辑 iOS/pubGDemo/ConfigModel.swift 文件，搜索 "class ConfigModel" ，把 ConfigModel 类的 appId 成员变量改为你的 App ID，rtcToken 改为你的 token。
2. 解压iOS SDK 压缩包，将其中的 libs 文件夹下的所有文件，复制到本项目的 iOS/deps/ 文件夹下。
3. 使用 XCode 打开 iOS/pubGDemo.xcodeproj，连接 iOS 测试设备，设置有效的开发者签名后即可运行。

		运行环境:
		* XCode 11.6 +
		* iOS 11.4 +

#### Android
1. 将有效的 AppID 填写进 "app/src/main/res/values/strings_config.xml"

	```
	<string name="private_app_id"><#YOUR APP ID#></string>
	```

2. 解压下载的语音通话 SDK 压缩包，将其中的 **libs** 文件夹下的 ***.jar** 复制到本项目的 **app/libs** 下，其中的 **libs** 文件夹下的 **arm64-v8a**/**x86**/**armeabi-v7a** 复制到本项目的 **app/src/main/jniLibs** 下。
3. 使用 Android Studio 打开该项目，连接 Android 测试设备，编译并运行。也可以使用 `Gradle` 直接编译运行。

		运行环境:
		* Android Studio 2.0 +
		* minSdkVersion 16
		* 部分模拟器会存在功能缺失或者性能问题，所以推荐使用真机 Android 设备


## 联系我们

- 如果发现了示例程序的 bug，欢迎提交 [issue](https://github.com/AgoraIO-Usecase/Spatial-Audio/issues)
- 声网 SDK 完整 API 文档见 [文档中心](https://docs.agora.io/cn/)
- 如果有售前咨询问题，可以拨打 400 632 6626，或加入官方Q群 12742516 提问
- 如果需要售后技术支持，你可以在 [Agora Dashboard](https://dashboard.agora.io) 提交工单

## 代码许可

The MIT License (MIT).