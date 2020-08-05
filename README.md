# Agora Game Engine

Agora Game Engine is a real-time communication solution for esports games. It implements audio range and 3D sound effects in your games, providing a more interactive and immersive gaming experience for players.

## Audio range

The audio range feature enables you to set the sound reach among players in a game room, determining how and when players can hear each other. This enhances the players¨ interactive experience within the game.

Whether players in a game room can hear each other is determined by the team ID, audio mode, and audio reception range settings. The rules are as follows:

- When the players are on the same team, they can hear each other, regardless of the settings of the audio mode and audio reception range.
- When the players are on different teams, they can hear each other only when they use the MODE_WORLD audio mode and are within each other's audio reception range.

## 3D sound effects

The 3D sound effects feature shapes the spatial sense of the sound and changes the sound volume as the sound source moves, providing players with enhanced audio immersion and location accuracy.

## Prerequisites

### Get App ID for Agora service

You can get App ID as follows:

- Create an account in [Agora Console](https://sso.agora.io/v2/signup).
- Log in to Agora Console and create a project. Select "App ID + App Certificate + Token" as your authentication mechanism when creating the project. Make sure that you enable the [App Certificate](https://docs.agora.io/en/Agora%20Platform/token?platform=All%20Platforms#appcertificate) of this project.
- Get the App ID and App Certificate of this project in **Project Management** page.

### Generate the token

1. If you did not enable the App Certificate, then this step is not needed, and you should then pass an empty string like "" as the token argument when you call the joinChannel or enterRoom interface.
2. If you enabled the App Certificate, then the following steps is necessary. Firstly you should clone the repository of generating token.
	```
	git clone https://github.com/AgoraIO/Tools.git
	```
3. For the usage of python token generater as an example.
	* Edit file "Tools/DynamicKey/AgoraDynamicKey/python/src/RtcTokenBuilder.py", add one statement at line 48, for the support of login RTM service as follows.
		```
		token.addPrivilege(kRtmLogin, privilegeExpiredTs)
		```
	* Edit file "Tools/DynamicKey/AgoraDynamicKey/python/sample/RtcTokenBuilderSample.py", assign variables appID、 appCertificate、 channelName、 uid with your App ID、 App certificate、 room name、 integer user ID.
	* Run python script to generate token:
		```
		cd Tools/DynamicKey/AgoraDynamicKey/python/sample/
		python RtcTokenBuilderSample.py
		```

### NOTICES

Before using spacial audio feature, you should contact our marketing manager, and tell us your App ID. Then we will setup this feature for you.

## Run the demo

### Windows

1. Open file "Windows/spatial_audio.sln" with Visual Studio 2017 or newer version.
2. Define TEST_APP_ID macro with your effective App ID in "main.cpp".
	```
	#define TEST_APP_ID "YOUR_TEST_APP_ID"
	```
3. Unzip the Windows SDK zip file, copy all files in **libs** directory to **Windows/deps** directory.
4. Compile the project in Visual Studio.
5. Run the demo in the following format:
	```
	#If you did not enable the app certificate, then the YOUR_TEST_TOKEN should be ""
	spatial_audio.exe YOUR_TEST_TOKEN TEST_ROOM_NAME TEST_USER_ID
	```

#### iOS

1. Edit file "iOS/pubGDemo/ConfigModel.swift", and search "class ConfigModel" in the file, assign the member variable **appId** and **rtcToken** of ConfigModule class with your effective App ID and token.
2. Unzip the iOS SDK zip file, and copy all files in **libs** directory of SDK to the **iOS/deps** directory of this project.
3. Open file "iOS/pubGDemo.xcodeproj" with XCode, and connect your iOS device, then compile and run it.

		Running environment:
		* XCode 11.6 +
		* iOS 11.4 +

#### Android

1. Edit file "Android/app/src/main/java/com/example/spatialaudio/MainActivity.java", assign the member variables mAppId, mToken, mChannel, mUid, mTeamID and mHearRange of MainActivity class with your effective test parameters.
2. Unzip the Android SDK zip file, then copy the ***.jar** files in **libs** directory of SDK to the **libagorartc/libs** directory of this project, and copy **arm64-v8a**/**armeabi-v7a**/**x86**/**x86_64** directories in **libs** directory to **libagorartc/native-libs** directory of this project.
3. Open the project with Android Studio, connect your Android device, compile and run it.

		Running environment:
		* Android Studio 4.0 +
		* minSdkVersion 16
		* Some feature may be missing on the simulater, so testing demo with your real device is recommended.


## Contact us

- If you found any bug of demo, submiting [issues](https://github.com/AgoraIO-Usecase/Spatial-Audio/issues) is welcomed.
- The full API document of Agora SDK is [here](https://docs.agora.io/cn/)
- You can call 400-632-6626 or join QQ group 12742516 for pre-sales support.
- You can ask for technical support by submitting tickets in [Agora Console](https://console.agora.io/)

## License

The MIT License (MIT).