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


#ifndef PROVISIONINGMANAGER_H
#define PROVISIONINGMANAGER_H

#include <QObject>
#include <QStateMachine>
#include <QTimer>
#include <QSignalTransition>

#include "AbstractWifiChanger.h"
#include "ISocketConfig.h"

#ifndef Q_OS_WASM
#include "SocketConfigIDFix.h"
//#include "SocketConfigLegacy.h"
#endif

class QQmlEngine;
class QJSEngine;

#if defined(Q_OS_ANDROID)
    #include "android/src/WifiChanger.h"
#elif defined(Q_OS_IOS)
    #include "ios/src/WifiChanger.h"
#endif

class ProvisioningManager : public QStateMachine
{
    Q_OBJECT
    Q_PROPERTY(ProvisioningState state READ state NOTIFY stateChanged);
    Q_PROPERTY(QString deviceSSID READ deviceSSID WRITE setDeviceSSID NOTIFY deviceSSIDChanged);
    Q_PROPERTY(QString shortID READ getShortID  NOTIFY shortIDChanged);
    Q_PROPERTY(QString uuid READ getUuid  NOTIFY uuidChanged);
    Q_PROPERTY(QString deviceIP READ getDeviceIP  NOTIFY deviceIPChanged);
    Q_PROPERTY(QString currentSSID READ ssid  NOTIFY ssidChanged);
    Q_PROPERTY(ProvisioningError errorCode READ getErrorCode NOTIFY failed)

public:
    static QObject* instanceAsQObject(QQmlEngine *engine, QJSEngine *scriptEngine);
    ProvisioningManager(QObject *parent);

    enum ProvisioningError
    {
        ERR_PROVISIONING_NO_ERROR = -1,
        ERR_PROVISIONING_DEVICE_NOT_FOUND,
        ERR_PROVISIONING_SOCKET_ERROR,
        ERR_PROVISIONING_SOCKET_TIMEOUT,
        ERR_PROVISIONING_WIFI_TEST_FAILED,
        ERR_PROVISIONING_TIMEOUT,
        ERR_PROVISIONING_UNKNOWN_ERROR,
        ERR_PROVISIONING_ABORTED
    };
    Q_ENUM (ProvisioningError)


    enum ProvisioningState
    {
        PROVISIONING_IDLE = 0,
        PROVISIONING_CONNECTING_WIFI,
        PROVISIONING_CONNECTED_WIFI,
        PROVISIONING_CONNECTING_SOCKET,
        PROVISIONING_TRANSFERING,
        PROVISIONING_TRANSFERING_SUCCEEDED,
        PROVISIONING_ERROR,
        PROVISIONING_SUCCESS,
        PROVISIONING_CONNECTING_TO_HOME_WIFI,
        PROVISIONING_CONNECTED_TO_HOME_WIFI,
        PROVISIONING_ABORTING,
    };
    Q_ENUM (ProvisioningState)


    Q_INVOKABLE void startProvisioning(QString wifiPass, QString server, QString targetSSID = "");
    Q_INVOKABLE bool cancel();

    void setDeviceWifi(QString ssid, QString pass = "");

    ProvisioningState state() const;

    QString deviceSSID() const;
    void setDeviceSSID(const QString &deviceSSID);

    QString getShortID();

    QString getDeviceIP();

    QString ssid();

    ProvisioningError getErrorCode() const;

    QString getUuid() const;

    void init();

private:
    void setupStates();
    AbstractWifiChanger* _changer;
    ISocketConfigurator* _socketConfigurator;
    QString _deviceSSID;
    QString _devicePass;
    bool _initialized = false;
    QString _targetSsid;
    QString _targetPass;
    QString _targetServer;
    QString _uuid;

    QTimer* _timoutTimer;
    QState* _errorState;
    bool    _testWifi;

    ProvisioningState _state = PROVISIONING_IDLE;
    ProvisioningError _errorCode = ERR_PROVISIONING_NO_ERROR;

    void addTimerTransition(QState *from, QAbstractState *to, int interval, ProvisioningError errorCode = ERR_PROVISIONING_NO_ERROR);
    void addErrorTransition(QState *from, QAbstractState *to, QObject* sender, const char *signal,  ProvisioningError errorCode);
    static ProvisioningManager* _instance;

private slots:
    void wifiConnectedStateChanged();

signals:
    void timeoutError();
    void connectedToTargetWifi();
    void stateChanged();
    void deviceSSIDChanged();
    void deviceIPChanged();
    void shortIDChanged();
    void succeeded();
    void failed();
    void ssidChanged();
    void connectedToHomeWifi();
    void uuidChanged();
    void cancelProvisioning();
};

#endif // PROVISIONINGMANAGER_H
