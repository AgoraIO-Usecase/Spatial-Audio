#include "IAgoraGMEngine.h"
#include <iostream>
#include <sstream>
#include <signal.h>
#include <stdlib.h>

using namespace agora::rtc;

#define TEST_APP_ID "01234567890123456789012345678901"

bool bStop = false;

void SigInt_Handler(int n_signal)
{
    std::cout << "interruptedn" << std::endl;
    bStop = true;
}
void SigBreak_Handler(int n_signal)
{
    std::cout << "closedn" << std::endl;
    bStop = true;
}

class RtcEngineEH : public agora::rtc::IRtcEngineEventHandler{
};

class GmeEvtHdl : public agora::rtc::IGMEngineEventHandler
{
public:
    GmeEvtHdl(IGameMediaEngine* gme) : m_gme(gme) {}
    virtual ~GmeEvtHdl() {}

    // this callback will be called, when the old token expires
    virtual void onRequestToken() {
        std::string newToken = "";
        // request new token from token generate server, here
        // ......
        m_gme->renewToken(newToken.c_str());
    }
    // this callback is triggered, when the connection
    // state changes from GME_CONNECTION_STATE_CONNECTING to 
    // GME_CONNECTION_STATE_CONNECTED
    virtual void onEnterRoomSuccess() {
        std::cout << "enter room success" << std::endl;
    }
    // this callback is triggered, when the connection
    // state changes from GME_CONNECTION_STATE_CONNECTING to 
    // GME_CONNECTION_STATE_DISCONNECTED
    virtual void onEnterRoomFail() {
        std::cout << "enter room fail" << std::endl;
    }
    // this callback is triggered everytime when the connection state changes
    virtual void onConnectionStateChange(agora::rtc::GME_CONNECTION_STATE_TYPE state, agora::rtc::GME_CONNECTION_CHANGED_REASON_TYPE reason) {
        std::cout << "connection state change " << state << ", code " << reason << std::endl;
    }
    // this callback is triggered when long time (4 seconds) no data received from server
    // param: lostSyncTimeMs is the interval in milliseconds from last receiving data from server
    virtual void onLostSync(int64_t lostSyncTimeMs) {
        std::cout << "lost sync with server, no data time " << lostSyncTimeMs << std::endl;
    }
    // this callback is triggered when the SDK received data from server after long time no data coming
    virtual void onGetSync(int64_t lostSyncTimeMs) {
        std::cout << "get sync with server, offline time " << lostSyncTimeMs << std::endl;
    }
    // this callback is triggered when the teammates change
    // param:
    //      uids is the array of user ID currently
    //      userCount is the length of array
    virtual void onTeamMatesChange(const unsigned int *uids, int userCount) {
        std::cout << "team mates change, count " << userCount << std::endl;
        std::stringstream ss;
        ss << '[';
        for (int i = 0; i < userCount; ++i) {
            ss << uids[i] << ", ";
        }
        ss << ']';
        std::cout << ss.str() << std::endl;
    }

    IGameMediaEngine *m_gme;
};

int main(int argc, const char **argv)
{
    if (argc < 4) {
        std::cout << "usage: spatial_audio.exe token room uid" << std::endl;
        return 0;
    }
    signal(SIGINT, &SigInt_Handler);
    signal(SIGBREAK, &SigBreak_Handler);

    // define RTC engine event handler
    RtcEngineEH rtcEH;
    // define initializing parameters for RTC engine
    agora::rtc::RtcEngineContext rtcCtx;
    rtcCtx.eventHandler = &rtcEH;
    // this APP ID is the one in your agora service control pannel
    rtcCtx.appId = TEST_APP_ID;
    rtcCtx.context = NULL;

    // create and inilialize the RTC engine
    agora::rtc::IRtcEngine *rtcEngine = createAgoraRtcEngine();
    rtcEngine->initialize(rtcCtx);
    // these operations bellow are optional
    // you can do some settings in your case
    rtcEngine->disableVideo();
    rtcEngine->enableAudio();
    // set the channel profile to game profile
    rtcEngine->setChannelProfile(agora::rtc::CHANNEL_PROFILE_GAME);
    // rtcEngine->setLogFilter(agora::LOG_FILTER_TYPE::LOG_FILTER_DEBUG);

    // create Game Media Engine, GME in short
    IGameMediaEngine* gme = createAgoraGameMediaEngine();
    // define your event handler for the GME
    GmeEvtHdl hdl(gme);
    // define initializing parameters for the GME
    agora::rtc::GMEngineContext ctx;
    // the APP ID should be the same with the RTC engine
    ctx.appId = TEST_APP_ID;
    ctx.eventHandler = &hdl;
    // do initializing with the RTC engine and parameters above
    gme->initialize(rtcEngine, ctx);

    // do some settings about range audio and 3D audio
    // set the teamID
    gme->setRangeAudioTeamID(123);
    // turn on the global and team audio 3D feature
    gme->enableSpatializer(true, true);
    // set the audio mode to only hearing voice from teamates
    // lookup the reference document for more
    gme->setRangeAudioMode(0);
    // hear maximum of 10 person's voice
    gme->setMaxHearAudioCount(10);
    // set the hear range to 20, 
    // lookup the reference document for more
    gme->updateAudioRecvRange(100);

    // NOTICE: user ID should not be zero
    unsigned int uid = atoll(argv[3]);

    // join in the RTC channel for video and audio real time comunication
    // the token was generated by the APP ID, APP certificate, channel name and user ID
    // lookup the reference document for more
    rtcEngine->joinChannel(argv[1], argv[2], "", uid);
    // enter the room of GME, for range audio and 3D audio feature
    // the token, room name and user ID are the same as the ones for RTC engine
    gme->enterRoom(argv[1], argv[2], uid);

    // these varaibles bellow are examples
    // they may change every frame in your game
    // pos is the position vector
    // f is the forward vector of model in the world coordinate system
    // r is the right vector of model in the world coordinate system
    // u is the up vector of model in the world coordinate system
    int pos[3] = { 0, 0, 0 };
    float f[3] = { 0, 1, 0 };
    float r[3] = { 1, 0, 0 };
    float u[3] = { 0, 0, 1 };
    int loop = 3600;
    while (!bStop && loop > 0) {
        // update self position and orientation every frame in your game
        gme->updateSelfPosition(pos, f, r, u);
        // update interval,
        // as in the case of a people walking 1 meter per second
        // there is no need for updating position frequantly.
        // but NOTICE that the interval of updating position 
        // must not be greater than 2 seconds, otherwise the 
        // SDK may lost sync with server
        Sleep(1000);
        loop--;
    }
    // exit room and release resouces after game
    // NOTICE the sequence of exiting room
    // exitRoom and release of GME must be called 
    // before the release of RTC engine
    gme->exitRoom();
    gme->release();
    rtcEngine->release();

    // these code bellow is testing for reinilializing when starting a new game
    rtcEngine = createAgoraRtcEngine();
    rtcEngine->initialize(rtcCtx);
    GmeEvtHdl hdl1(gme);
    ctx.eventHandler = &hdl1;
    gme->initialize(rtcEngine, ctx);
    gme->release();
    rtcEngine->release();

    return 0;
}