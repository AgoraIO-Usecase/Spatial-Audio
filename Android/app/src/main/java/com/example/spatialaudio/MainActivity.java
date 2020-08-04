package com.example.spatialaudio;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import io.agora.rtc.Constants;
import io.agora.rtc.GMEngineConfig;
import io.agora.rtc.IGMEngineEventHandler;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.IGameMediaEngine;

import static java.lang.Thread.sleep;

public class MainActivity extends AppCompatActivity {

    private final static Logger log = LoggerFactory.getLogger(MainActivity.class);

    private static final int JOIN_CHANNEL_BUTTON_STATE_NOT_JOINED = 0;
    private static final int JOIN_CHANNEL_BUTTON_STATE_JOINED = 1;

    private String mAppId = "01234567890123456789012345678901";
    private String mToken = "";
    private String mChannel = "pubgTest";
    private int mUid = 567;
    private int mTeamID = 123;
    private int mHearRange = 100;

    private int mJoinChannelBtnState = JOIN_CHANNEL_BUTTON_STATE_NOT_JOINED;
    private RtcEngine mRtcEngine;
    private IGameMediaEngine mGmEngine;
    private GMEngineConfig mGmConfig;

    private AgGMEngineTest mGmEngineTest = null;
    final IGMEngineEventHandler mGmeEventHandler = new IGMEngineEventHandler() {
        @Override
        public void onRequestToken() {
            log.info("IGMEngineEventHandler: onRequestToken");
        }
        @Override
        public void onEnterRoomSuccess() {
            log.info("IGMEngineEventHandler: onEnterRoomSuccess");
        }
        public void onEnterRoomFail() {
            log.info("IGMEngineEventHandler: onEnterRoomFail");
        }
        @Override
        public void onConnectionStateChange(int state, int reason) {
            log.info("IGMEngineEventHandler: onConnectionStateChange, state: "+state+", reason: "+reason+"\n");
        }
        @Override
        public void onLostSync(long lostSyncTimeMs) {
            log.info("IGMEngineEventHandler: onLostSync, lostSyncTime: "+lostSyncTimeMs);
        }
        @Override
        public void onGetSync(long lostSyncTimeMs) {
            log.info("IGMEngineEventHandler: onGetSync, lostSyncTime: "+lostSyncTimeMs);
        }
        @Override
        public void onTeamMatesChange(int[] uids) {
            log.info("IGMEngineEventHandler: onTeamMatesChange, uids: "+uids.length);
        }
    };

    final IRtcEngineEventHandler mRtcEventHandler = new IRtcEngineEventHandler() {
        @Override
        public void onJoinChannelSuccess(String s, int i, int i1) {
            log.info("IRtcEngineEventHandler: onJoinChannelSuccess");
        }
        @Override
        public void onConnectionStateChanged(int state, int reason) {
            log.info("IRtcEngineEventHandler: onConnectionStateChanged, state: %d, reason: %d", state, reason);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        try {
            mRtcEngine = RtcEngine.create(getApplicationContext(), mAppId, mRtcEventHandler);
            mRtcEngine.setLogFilter(Constants.LOG_FILTER_INFO);
        } catch (Exception e) {
            log.error(Log.getStackTraceString(e));
            throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
        }

        mRtcEngine.disableVideo();
        mRtcEngine.enableAudio();
        mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_GAME);

        final Button joinChannelBtn = findViewById(R.id.joinChannelBtn);
        joinChannelBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switch (mJoinChannelBtnState) {
                    case JOIN_CHANNEL_BUTTON_STATE_NOT_JOINED:
                        mRtcEngine.joinChannel(mToken, mChannel, "", mUid);
                        startGMEngineTest(mChannel, mUid);
                        mJoinChannelBtnState = JOIN_CHANNEL_BUTTON_STATE_JOINED;
                        joinChannelBtn.setText(R.string.leaveChannelBtnTxt);
                        break;
                    case JOIN_CHANNEL_BUTTON_STATE_JOINED:
                        new Thread(new Runnable() {
                            @Override
                            public void run() {
                                stopGMEngineTest();
                                while(!mGmEngineTest.isStopped()) {
                                    try {
                                        sleep(10);
                                    } catch (InterruptedException e) {
                                        // e.printStackTrace();
                                    }
                                }
                                mRtcEngine.leaveChannel();
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        mJoinChannelBtnState = JOIN_CHANNEL_BUTTON_STATE_NOT_JOINED;
                                        joinChannelBtn.setText(R.string.joinChannelBtnTxt);
                                    }
                                });
                            }
                        }).start();
                        break;
                    default:
                        break;
                }
            }
        });

        /*FloatingActionButton fab = findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
            }
        });*/
    }

    interface IGmTestCase {
        void test(AgGMEngineTest gme);
    }

    class GmTestCase1 implements IGmTestCase {
        public void test(AgGMEngineTest gme) {
            gme.testCase1();
        }
    }
    class GmTestCase2 implements IGmTestCase {
        public void test(AgGMEngineTest gme) {
            gme.testCase2();
        }
    }
    class GmTestCase3 implements IGmTestCase {
        public void test(AgGMEngineTest gme) {
            gme.testCase3();
        }
    }
    public class AgGMEngineTest extends Thread {
        public int mTestCase;

        private String mChannel;
        private int mUid;
        private boolean mRunning;
        private boolean mStopped;
        private IGmTestCase[] mTests;

        public AgGMEngineTest(String channel, int uid) {
            mChannel = channel;
            mUid = uid;
            mTests = new IGmTestCase[]{
                new GmTestCase1(),
                new GmTestCase2(),
                new GmTestCase3()
            };
        }

        public void stopGMEngineTest() {
            mRunning = false;
        }

        public boolean isStopped() {return mStopped;}

        @Override
        public void run() {
            mStopped = false;
            mRunning = true;

            mGmEngine = IGameMediaEngine.create();
            mGmConfig = new GMEngineConfig();
            mGmConfig.mAppId = mAppId;
            mGmConfig.mEventHandler = mGmeEventHandler;
            mGmEngine.initialize(mRtcEngine, mGmConfig);

            mGmEngine.setRangeAudioTeamID(mTeamID);
            mGmEngine.enableSpatializer(true, true);
            mGmEngine.setRangeAudioMode(0);
            mGmEngine.setMaxHearAudioCount(10);
            mGmEngine.updateAudioRecvRange(mHearRange);

            mGmEngine.enterRoom(mToken, mChannel, mUid);

            mTests[mTestCase].test(this);

            mGmEngine.exitRoom();
            mGmEngine.release();

            mStopped = true;
        }

        void testCase1() {
            int speed = 1;
            int[] pos = {20, 0, 0};
            float[] f = {0, 1, 0};
            float[] r = {1, 0, 0};
            float[] u = {0, 0, 1};
            while (mRunning) {
                mGmEngine.updateSelfPosition(pos, f, r, u);
                pos[0] += speed;
                if (pos[0] >= 20) {
                    speed = -1;
                }
                if (pos[0] <= -20) {
                    speed = 1;
                }
                try {
                    sleep(1000);
                } catch (InterruptedException e) {
                    // e.printStackTrace();
                }
            }
        }
        void testCase2() {
            double radio = 0.1;
            double curRadio = 0;
            int[] pos = {10, 0, 0};
            float[] f = {0, 1, 0};
            float[] r = {1, 0, 0};
            float[] u = {0, 0, 1};
            while (mRunning) {
                mGmEngine.updateSelfPosition(pos, f, r, u);
                curRadio += radio;
                pos[0] = (int)(Math.cos(curRadio) * 10);
                pos[1] = (int)(Math.sin(curRadio) * 10);
                try {
                    sleep(1000);
                } catch (InterruptedException e) {
                    // e.printStackTrace();
                }
            }
        }
        void testCase3() {
            int[] pos = {0, 0, 0};
            float[] f = {0, 1, 0};
            float[] r = {1, 0, 0};
            float[] u = {0, 0, 1};
            while (mRunning) {
                mGmEngine.updateSelfPosition(pos, f, r, u);
                try {
                    sleep(1000);
                } catch (InterruptedException e) {
                    // e.printStackTrace();
                }
            }
        }
    }

    public void startGMEngineTest(String channel, int uid) {
        mGmEngineTest = new AgGMEngineTest(channel, uid);
        mGmEngineTest.mTestCase = 1;
        mGmEngineTest.start();
    }

    public void stopGMEngineTest() {
        mGmEngineTest.stopGMEngineTest();
    }

}