/*   2log.io
 *   Copyright (C) 2021 - 2log.io | mail@2log.io,  mail@friedemann-metzger.de
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


#include "WifiChanger.h"
#include <QDebug>
#include <QAndroidJniEnvironment>
#include <QtAndroidExtras/QAndroidJniObject>
#include "jni.h"

using namespace  Android;
WifiChanger* WifiChanger::_this  = nullptr;

// step 2
// create a vector with all our JNINativeMethod(s)
static JNINativeMethod methods[] =
{
    {"wifiSsidChanged", "(Ljava/lang/String;)V", reinterpret_cast<void *>(WifiChanger::wifiSsidChanged)},
    {"wifiConnected", "(Z)V", reinterpret_cast<void *>(WifiChanger::wifiConnected)},
    {"wifiScanResults", "([Ljava/lang/String;)V", reinterpret_cast<void *>(WifiChanger::wifiScanResults)},
};

JNIEXPORT jint JNI_OnLoad(JavaVM* vm, void* /*reserved*/)
{
    JNIEnv* env;

   //  get the JNIEnv pointer.
    if (vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6)
           != JNI_OK) {
        return JNI_ERR;
    }

    // step 3
    // search for Java class which declares the native methods
    jclass javaClass = env->FindClass("org/twolog/android/provisioning/WifiChanger");
    if (!javaClass)
        return JNI_ERR;

    // step 4
    // register our native methods
    if (env->RegisterNatives(javaClass, methods,
                            sizeof(methods) / sizeof(methods[0])) < 0) {
        return JNI_ERR;
    }
    return JNI_VERSION_1_6;
}


bool WifiChanger::startScan()
{
    qDebug()<<Q_FUNC_INFO;
    return QAndroidJniObject::callStaticMethod<jboolean>("org.twolog.android.provisioning.WifiChanger",
                                                         "startWifiScan");

}

bool WifiChanger::switchWifi(QString ssid, QString pass)
{
    qDebug()<<Q_FUNC_INFO;
    QAndroidJniObject javaPass= QAndroidJniObject::fromString(pass);
    QAndroidJniObject javaSsid = QAndroidJniObject::fromString(ssid);
    QAndroidJniObject::callStaticMethod<void>("org.twolog.android.provisioning.WifiChanger",
                                       "switchWifi",
                                       "(Ljava/lang/String;Ljava/lang/String;)V",
                                       javaSsid.object<jstring>(),
                                       javaPass.object<jstring>());
    return true;

}

bool WifiChanger::removeWifi(QString ssid)
{
    QAndroidJniObject javaSsid = QAndroidJniObject::fromString(ssid);
    return QAndroidJniObject::callStaticMethod<jboolean>("org.twolog.android.provisioning.WifiChanger",
                                       "removeNetwork",
                                       "(Ljava/lang/String;)Z",
                                       javaSsid.object<jstring>());
}

WifiChanger::WifiChanger(QObject *parent) : AbstractWifiChanger(parent)
{
    _this = this;
    QAndroidJniObject::callStaticMethod<void>("org.twolog.android.provisioning.WifiChanger",
                                       "register");
}


void WifiChanger::wifiScanResults(JNIEnv *env, jobject thiz, jobjectArray stringArrays)
{
    Q_UNUSED(thiz)

    QStringList stringlist;
    int len = env->GetArrayLength(stringArrays);

    for (int i=0; i<len; i++) {
        // Cast array element to string
        jstring jstr = (jstring) (env->GetObjectArrayElement(stringArrays, i));

        // Convert Java string to std::string
        const char *charBuffer = env->GetStringUTFChars(jstr, (jboolean *) 0);
        QString str = QString(charBuffer);

        // Push back string to vector
        stringlist << str;

        // Release memory
        env->ReleaseStringUTFChars(jstr, charBuffer);
        env->DeleteLocalRef(jstr);
    }

    _this->setScanResults(stringlist);
}

void WifiChanger::wifiConnected(JNIEnv *env, jobject thiz, jboolean success)
{
    qDebug()<<Q_FUNC_INFO;
    _this->setWifiConnected(success);
}

void WifiChanger::wifiSsidChanged(JNIEnv *env, jobject thiz, jstring x)
{
    Q_UNUSED(env)
    Q_UNUSED(thiz)
    _this->setCurrentSSID(QAndroidJniObject(x).toString());
}


