
package org.twolog.android.provisioning;

import android.Manifest;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.ScanResult;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.net.NetworkInfo;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.location.LocationManagerCompat;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import android.content.Context;

import android.net.wifi.WifiManager;
import android.net.wifi.WifiConfiguration;
import java.util.List;
import android.content.pm.PackageManager;
import android.net.ConnectivityManager;
import android.provider.Settings;

import android.net.NetworkRequest;
import android.net.ConnectivityManager.NetworkCallback;
import android.net.NetworkCapabilities;
import android.net.Network;

public class WifiChanger extends org.qtproject.qt5.android.bindings.QtActivity
{
    private static native void wifiSsidChanged(String ssid);
    private static native void wifiConnected(boolean success);
    private static native void wifiScanResults(String[] jstringArr);

    private static final String TAG = WifiChanger.class.getSimpleName();
    private static final int REQUEST_PERMISSION = 0x01;

    private static WifiChanger m_instance;
    private boolean mReceiverRegistered = false;

    private String m_bssid;
    private String m_ssid;
    private static String m_targetSsid;

    public static void register()
    {
        m_instance.init();
    }

    public static boolean startWifiScan()
    {
       WifiManager wifiManager = (WifiManager)m_instance.getSystemService(Context.WIFI_SERVICE);
        return wifiManager.startScan();
    }

    private void init()
    {
        Log.d(TAG, "init");
        if (isSDKAtLeastP()) {
            if (checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
            != PackageManager.PERMISSION_GRANTED)
            {
                Log.d(TAG,"Request permission");
                String[] permissions = {Manifest.permission.ACCESS_FINE_LOCATION};
                requestPermissions(permissions, REQUEST_PERMISSION);
            }
            else
            {
                Log.d(TAG,"Permission Granted..");
                registerBroadcastReceiver();
            }

        }
        else
        {
            Log.d(TAG,"SDK Checkk false..");
            registerBroadcastReceiver();
        }

        ConnectivityManager connection_manager =
        (ConnectivityManager) m_instance.getApplication().getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkRequest.Builder request = new NetworkRequest.Builder();

    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
            String[] permissions, int[] grantResults) {
        switch (requestCode)
        {
            case REQUEST_PERMISSION: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    registerBroadcastReceiver();

                }
                else
                {
                        // permission denied, boo! Disable the
                        // functionality that depends on this permission.
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request.
        }
    }


    private BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action == null) {
                return;
            }

            WifiManager wifiManager = (WifiManager) context.getApplicationContext()
                    .getSystemService(WIFI_SERVICE);
            assert wifiManager != null;

            switch (action) {
                case WifiManager.SCAN_RESULTS_AVAILABLE_ACTION:
                        boolean success = intent.getBooleanExtra(wifiManager.EXTRA_RESULTS_UPDATED, false);
                        if(success)
                            scanSuccess(wifiManager.getScanResults());
                        else
                            Log.d(TAG, "scan failed");
                        break;                 
                case WifiManager.NETWORK_STATE_CHANGED_ACTION:
                case LocationManager.PROVIDERS_CHANGED_ACTION:
                        NetworkInfo info = intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
                        Log.d(TAG, "info.getDetailedState: " + info.getDetailedState().toString());
                        onWifiChanged(wifiManager.getConnectionInfo());
                        break;
            }
        }
    };

//  TODO
//    private void checkLocation() {
//        boolean enable;
//        LocationManager locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
//        enable = locationManager != null && LocationManagerCompat.isLocationEnabled(locationManager);
//        if (!enable) {
//            mMessageTV.setText(R.string.location_disable_message);
//        }
//    }


    private void onWifiChanged(WifiInfo info) {
        boolean disconnected = info == null
                || info.getNetworkId() == -1
                || "<unknown ssid>".equals(info.getSSID());
        if (disconnected) {
            wifiConnected(false);
            wifiSsidChanged("");

            if (isSDKAtLeastP()) {
               // checkLocation();
            }

        } else {
            String ssid = info.getSSID();
            if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
                ssid = ssid.substring(1, ssid.length() - 1);
            }

            Log.d(TAG, "SSID:"+ssid);
            wifiSsidChanged(ssid);
            m_ssid = ssid;


            String bssid = info.getBSSID();
            m_bssid = bssid;

            if(info.getIpAddress() != 0)
            {
                wifiConnected(true);
            }
        }
    }

    private boolean isSDKAtLeastP() {
        return Build.VERSION.SDK_INT >= 26;
    }

    public WifiChanger()
    {
        m_instance = this;
    }

    private void scanSuccess(List<ScanResult> results)
    {
        List<String> resultMsgList = new ArrayList<>(results.size());
        for (ScanResult result : results)
        {
            resultMsgList.add(result.SSID);
        }

        String[] strArr = new String[resultMsgList.size()];
        resultMsgList.toArray(strArr);
        wifiScanResults(strArr);
    }


    private void registerBroadcastReceiver()
    {
        IntentFilter filter = new IntentFilter(WifiManager.NETWORK_STATE_CHANGED_ACTION);
        filter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION);

        if (isSDKAtLeastP()) {
            filter.addAction(LocationManager.PROVIDERS_CHANGED_ACTION);
        }
        registerReceiver(mReceiver, filter);
        mReceiverRegistered = true;
        startWifiScan();
    }

    public static void switchWifi(String networkSSID, String networkPass)
    {
        Log.d(TAG, networkSSID);
        m_targetSsid = networkSSID;
        WifiConfiguration conf = new WifiConfiguration();
        conf.SSID = "\"" + networkSSID + "\"";   // Please note the quotes. String should contain ssid in quotes

        if(!networkPass.equals(""))
            conf.preSharedKey = "\""+ networkPass +"\"";
        else
            conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);

        WifiManager wifiManager = (WifiManager)m_instance.getSystemService(Context.WIFI_SERVICE);
        wifiManager.addNetwork(conf);

        List<WifiConfiguration> list = wifiManager.getConfiguredNetworks();

        int networkID = 0;
        for( WifiConfiguration i : list ) {
            if(i.SSID != null && i.SSID.equals("\"" + networkSSID + "\"")) {
                Log.d(TAG, "Connect to network");
                wifiManager.disconnect();
                wifiManager.enableNetwork(i.networkId, true);
                networkID = i.networkId;
                wifiManager.reconnect();
            }
         }
     }

    static boolean removeNetwork(String networkSSID)
    {
        WifiManager wifiManager = (WifiManager)m_instance.getSystemService(Context.WIFI_SERVICE);
        // remove existing configurations
        List<WifiConfiguration> list1 = wifiManager.getConfiguredNetworks();
        boolean success = false;
        for( WifiConfiguration i : list1 )
        {
            if(i.SSID != null && i.SSID.equals("\"" + networkSSID + "\""))
            {
                 Log.d(TAG, "Remove WiFi configuration");
                 wifiManager.removeNetwork(i.networkId);
                 success = true;
            }
        }

        return success;
    }
}



















