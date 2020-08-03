# Agora��Ϸ����

Agora��Ϸ������ Agora ��Ե��Ӿ�������Ϸ�ṩ��ʵʱ����Ƶ�����������Ҫ����ʵ�ַ�Χ������ 3D ��Ч�ȹ��ܣ�Ϊ����ṩ��������ʽ����Ϸ���顣

## ��Χ����

��Χ�������ܿ����������ͬһ�����������֮��������ɴ��ԣ��Ӷ�������Ϸ��Ȥζ�Ժͻ����ԡ�

ͨ������С�ӡ�����ģʽ���������շ�Χ������ͬһ�������ڵ����֮���ܷ��໥�����Է����������������£�

- ���������ͬһС��ʱ�����۾����Զ�����ú�������ģʽ�������������˴˵�������
- ��������ڲ�ͬС��ʱ��ֻ��������ģʽ����Ϊ�������ˡ������ڱ˴˵��������շ�Χ��ʱ�������໥������

## 3D ��Ч

3D ��Ч�����������Ŀռ�У���������Դλ�õ��ƶ��ı������Ĵ�С��ʹ��һ�������侳֮�С�

## ǰ�ò���

### ��ȡ���� App ID
ͨ�����²����ȡ���� App ID��

- ����������̨����һ���˺š�
- ��¼��������̨������һ����Ŀ����Ȩ��ʽѡ�� ��App ID + App ֤�� + Token����ע�⣬��ȷ������Ŀ������ App ֤�顣
- ǰ����Ŀ����ҳ�棬��ȡ����Ŀ�� App ID��

### ���� token

1. ���û������ App ֤�飬����Ҫ����token���ڵ�����ؽӿڵ�ʱ�򣬴�����ַ�����
2. ����token�������Ĵ���
```
git clone https://github.com/AgoraIO/Tools.git
```
3. �� python token��������ʹ��Ϊ��
	* �༭ Tools/DynamicKey/AgoraDynamicKey/python/src/RtcTokenBuilder.py �ļ�����48����������´��룬ʹ���ɵ�token֧��RTM��¼
	```
	token.addPrivilege(kRtmLogin, privilegeExpiredTs)
	```
	* �༭ Tools/DynamicKey/AgoraDynamicKey/python/sample/RtcTokenBuilderSample.py �ļ����޸� appID, appCertificate, channelName, uid Ϊ�Լ�ʹ�õ� App ID, App ֤��, ��������, ���� user ID
	* ���� python �ű�������token
	```
	cd Tools/DynamicKey/AgoraDynamicKey/python/sample/
	python RtcTokenBuilderSample.py
	```

### ע������
��ʹ�ÿռ�����ǰ������ϵ�����г�������Ա�����������㽫Ҫʹ�õ�App ID���Ա�����Ϊ�㿪���ù���

## ����ʾ������

### Windows
1. �� Visual Studio 2017 ����°汾����Windows/spatial_audio.sln�ļ���
2. ����Ч�� AppID ����Ϊ TEST_APP_ID �ꡣ
```
#define TEST_APP_ID "YOUR_TEST_APP_ID"
```
3. ��ѹ Windows SDK ѹ�����������е� **libs** �ļ����µ������ļ������Ƶ� **Windows/deps** �ļ����¡�
4. �� Visual Studio ������Ŀ��
5. ��������������ʽ������ʾ������
```
#���û������App֤�飬��YOUR_TEST_TOKENΪ""
spatial_audio.exe YOUR_TEST_TOKEN TEST_ROOM_NAME TEST_USER_ID
```

#### iOS
1. �༭ iOS/pubGDemo/ConfigModel.swift �ļ������� "class ConfigModel" ���� ConfigModel ��� appId ��Ա������Ϊ��� App ID��rtcToken ��Ϊ��� token��
2. ��ѹiOS SDK ѹ�����������е� libs �ļ����µ������ļ������Ƶ�����Ŀ�� iOS/deps/ �ļ����¡�
3. ʹ�� XCode �� iOS/pubGDemo.xcodeproj������ iOS �����豸��������Ч�Ŀ�����ǩ���󼴿����С�

		���л���:
		* XCode 11.6 +
		* iOS 11.4 +

#### Android
1. ����Ч�� AppID ��д�� "app/src/main/res/values/strings_config.xml"

	```
	<string name="private_app_id"><#YOUR APP ID#></string>
	```

2. ��ѹ���ص�����ͨ�� SDK ѹ�����������е� **libs** �ļ����µ� ***.jar** ���Ƶ�����Ŀ�� **app/libs** �£����е� **libs** �ļ����µ� **arm64-v8a**/**x86**/**armeabi-v7a** ���Ƶ�����Ŀ�� **app/src/main/jniLibs** �¡�
3. ʹ�� Android Studio �򿪸���Ŀ������ Android �����豸�����벢���С�Ҳ����ʹ�� `Gradle` ֱ�ӱ������С�

		���л���:
		* Android Studio 2.0 +
		* minSdkVersion 16
		* ����ģ��������ڹ���ȱʧ�����������⣬�����Ƽ�ʹ����� Android �豸


## ��ϵ����

- ���������ʾ������� bug����ӭ�ύ [issue](https://github.com/AgoraIO-Usecase/Spatial-Audio/issues)
- ���� SDK ���� API �ĵ��� [�ĵ�����](https://docs.agora.io/cn/)
- �������ǰ��ѯ���⣬���Բ��� 400 632 6626�������ٷ�QȺ 12742516 ����
- �����Ҫ�ۺ���֧�֣�������� [Agora Dashboard](https://dashboard.agora.io) �ύ����

## �������

The MIT License (MIT).