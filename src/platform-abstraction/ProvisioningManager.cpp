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


#include "ProvisioningManager.h"
#include <QFinalState>
#include <QCoreApplication>
#include <QDebug>

ProvisioningManager* ProvisioningManager::_instance = nullptr;

QObject *ProvisioningManager::instanceAsQObject(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    if(!_instance)
        _instance = new ProvisioningManager(qApp);

    return _instance;
}

ProvisioningManager::ProvisioningManager(QObject* parent) : QStateMachine(parent),
    _timoutTimer(new QTimer(this))
{
    // changed meaning of _testWifi:
    // _testWifi true: if device cannot connect to configured wifi on first startup after provisioning - reset config and restart to config mode again
    // _testWifi false: device will not start to config mode automatically if configured wifi is not found - useful to pre-provision a device
    _testWifi = true;
    #ifndef Q_OS_WASM
   // _socketConfigurator = new SocketConfiguratorIDFix(this);
    _socketConfigurator = new SocketConfiguratorLegacy(this);
    init();
    #endif
}


void ProvisioningManager::startProvisioning(QString wifiPass, QString server, QString targetSSID)
{
    _errorCode = ERR_PROVISIONING_NO_ERROR;
    if(isRunning())
        return;

    this->start();
    _targetPass = wifiPass;
    if(targetSSID.isEmpty())
        _targetSsid = _changer->currentSSID();
    else
        _targetSsid = targetSSID;
    _targetServer = server;
    _changer->switchWifi(_deviceSSID, _devicePass);
}

bool ProvisioningManager::cancel()
{
    Q_EMIT cancelProvisioning();
    return true;
}

void ProvisioningManager::setDeviceWifi(QString ssid, QString pass)
{
    _devicePass = pass;
    _deviceSSID = ssid;
}

void ProvisioningManager::setupStates()
{
    QState* errorState = new QState(this);
    connect(errorState, &QAbstractState::entered,[=]()
    {
        _state = PROVISIONING_ERROR;
        qDebug()<<_state;
        qDebug()<<_errorCode;
        Q_EMIT failed();
        Q_EMIT stateChanged();
    });

    QState* successState = new QState(this);
    connect(successState, &QAbstractState::entered,[=]()
    {
        _state = PROVISIONING_SUCCESS;
        qDebug()<<_state;
        _socketConfigurator->disconnect();
        Q_EMIT stateChanged();
        Q_EMIT succeeded();
    });

    QState* connectingWifiState = new QState(this);
    connect(connectingWifiState, &QAbstractState::entered,[=]()
    {
        _state = PROVISIONING_CONNECTING_WIFI;
        Q_EMIT stateChanged();
        qDebug()<<_state;
        if(_changer->currentSSID() == _deviceSSID)
            Q_EMIT connectedToTargetWifi();
    });

    QState* connectedWifiState = new QState(this);
    connect(connectedWifiState, &QAbstractState::entered,[=]()
    {
        _state = PROVISIONING_CONNECTED_WIFI;
        Q_EMIT stateChanged();
        qDebug()<<_state;
    });


    QState* connectToSocketState = new QState(this);
    connect(connectToSocketState, &QAbstractState::entered,[=]()
    {
        _state = PROVISIONING_CONNECTING_SOCKET;
        Q_EMIT stateChanged();
        qDebug()<<_state;
        _socketConfigurator->start(_targetSsid, _targetPass, _targetServer, "device.local.2log.io", _testWifi);
    //     _socketConfigurator->start(_targetSsid, _targetPass, _targetServer, "192.168.4.1", _testWifi);
    });

    QState* transferDataState = new QState(this);
    connect(transferDataState, &QAbstractState::entered,[=]()
    {
        _state = PROVISIONING_TRANSFERING;
        qDebug()<<_state;
        Q_EMIT stateChanged();
    });

    QState* deviceHasConfigReceived = new QState(this);
    connect(deviceHasConfigReceived, &QAbstractState::entered,[=]()
    {
        _state = PROVISIONING_TRANSFERING_SUCCEEDED;
        qDebug()<<_state;
        Q_EMIT stateChanged();

        _socketConfigurator->disconnect();
    });

    QState* connectingToHomeWifi = new QState(this);
    connect(connectingToHomeWifi, &QAbstractState::entered,[=]()
    {
        _changer->removeWifi(_deviceSSID);
        _state = PROVISIONING_CONNECTING_TO_HOME_WIFI;
        qDebug()<<_state;
        Q_EMIT stateChanged();
    });


    QFinalState* connectedHomeState = new QFinalState(this);
    connect(connectedHomeState, &QAbstractState::entered,[=]()
    {
        _state = PROVISIONING_CONNECTED_TO_HOME_WIFI;
        qDebug()<<_state;
        Q_EMIT stateChanged();
    });

    QState* abortingState = new QState(this);
    connect(abortingState, &QAbstractState::entered,[=]()
    {
        _socketConfigurator->disconnect();
        _changer->removeWifi(_deviceSSID);
        _errorCode = ERR_PROVISIONING_ABORTED;
        _state = PROVISIONING_ABORTING;
        qDebug()<<_state;
        Q_EMIT stateChanged();
        if(_changer->currentSSID() == _targetSsid)
        {
            Q_EMIT connectedToHomeWifi();
        }
    });

    // connectingWifiState --connected--> connectedWifiState
    connectingWifiState->addTransition(this, &ProvisioningManager::connectedToTargetWifi, connectedWifiState);

    // connectingWifiState --timeout--> no device found
    addTimerTransition(connectingWifiState, errorState, 15000, ERR_PROVISIONING_DEVICE_NOT_FOUND);

    // connectingWifiState --cancel--> cancel provisioning
    connectingWifiState->addTransition(this, &ProvisioningManager::cancelProvisioning, abortingState);


    // when wifi connected: wait 3s to proceed // maybe device has no IP settings yet
    addTimerTransition(connectedWifiState, connectToSocketState, 3000);

    // cancel pressed when in waiting state
    connectedWifiState->addTransition(this, &ProvisioningManager::cancelProvisioning, abortingState);

    // connectedWifiState --cancel--> cancel provisioning
    connectedWifiState->addTransition(this, &ProvisioningManager::cancelProvisioning, abortingState);

    // connectToSocketState --timeout--> errorState
    addTimerTransition(connectToSocketState, errorState, 10000, ERR_PROVISIONING_SOCKET_TIMEOUT);


    // connectToSocketState --cancel--> cancel provisioning
    connectToSocketState->addTransition(this, &ProvisioningManager::cancelProvisioning, abortingState);

    // connectToSocketState --socket has disconnected--> errorState
    addErrorTransition(connectToSocketState, errorState, _socketConfigurator, SIGNAL(finished()), ERR_PROVISIONING_SOCKET_ERROR);

    // connectToSocketState --socket was able to connect--> transferDataState
    connectToSocketState->addTransition(_socketConfigurator, &ISocketConfigurator::connectedToDevice, transferDataState);

    // transferDataState --timout--> errorState
    addTimerTransition(transferDataState, errorState, 30000, ERR_PROVISIONING_TIMEOUT);

    // transferDataState --cancel--> cancel provisioning
    transferDataState->addTransition(this, &ProvisioningManager::cancelProvisioning, abortingState);

    // transferDataState --disconnect--> errorState
    addErrorTransition(transferDataState, errorState, _socketConfigurator, SIGNAL(finished()), ERR_PROVISIONING_SOCKET_ERROR);

    // transferDataState --dataSendFailed--> errorState
    addErrorTransition(transferDataState, errorState, _socketConfigurator, SIGNAL(dataSendFaied()), ERR_PROVISIONING_SOCKET_ERROR);

    // transferDataState --dataConfirmed--> deviceHasConfigReceived
    transferDataState->addTransition(_socketConfigurator, &ISocketConfigurator::dataConfirmed, deviceHasConfigReceived);


    // deviceHasConfigReceived --disconnect--> successState
    // This is okay. Some phones lose wifi connection while ESP is testing the WiFi credentials.
    deviceHasConfigReceived->addTransition(_socketConfigurator, &ISocketConfigurator::finished, successState);

    // IP check succeeded
    deviceHasConfigReceived->addTransition(_socketConfigurator, &ISocketConfigurator::wifiTestSucceeded, successState);

    addErrorTransition(deviceHasConfigReceived, errorState, _socketConfigurator, SIGNAL(wifiTestFailed()), ERR_PROVISIONING_WIFI_TEST_FAILED);

    errorState->addTransition(this, &ProvisioningManager::connectedToHomeWifi, connectedHomeState);
    successState->addTransition(this, &ProvisioningManager::connectedToHomeWifi, connectedHomeState);
    abortingState->addTransition(this, &ProvisioningManager::connectedToHomeWifi, connectedHomeState);
    connectingToHomeWifi->addTransition(this, &ProvisioningManager::connectedToHomeWifi, connectedHomeState);

    addTimerTransition(errorState, connectingToHomeWifi, 5000);
    addTimerTransition(successState, connectingToHomeWifi, 10000);


    addTimerTransition(abortingState, connectingToHomeWifi, 5000);

    this->setInitialState(connectingWifiState);
}

QString ProvisioningManager::getUuid() const
{
    return _socketConfigurator->uuid();
}

void ProvisioningManager::init()
{
    if(_initialized)
        return;

    #if defined(Q_OS_ANDROID)
        _changer = new Android::WifiChanger(qApp);
    #elif defined(Q_OS_IOS)
        _changer = new iOS::WifiChanger(qApp);
    #else
        _changer = new AbstractWifiChanger(qApp);
    #endif

    _timoutTimer->setSingleShot(true);
    connect(_socketConfigurator, &ISocketConfigurator::finished,[=]()
    {
        qDebug()<<"Remove Wifi...";
        _changer->removeWifi(_deviceSSID);
    });

    connect(_changer, &AbstractWifiChanger::wifiConnectedChanged, this, &ProvisioningManager::wifiConnectedStateChanged);
    connect(_changer, &AbstractWifiChanger::currentSSIDChanged, this, &ProvisioningManager::ssidChanged);
    connect(_socketConfigurator, &ISocketConfigurator::deviceIPChanged, this, &ProvisioningManager::deviceIPChanged);
    connect(_socketConfigurator, &ISocketConfigurator::shortIDChanged, this, &ProvisioningManager::shortIDChanged);
    connect(_socketConfigurator, &ISocketConfigurator::uuidChanged, this, &ProvisioningManager::uuidChanged);
    setupStates();
    _initialized = true;
}

ProvisioningManager::ProvisioningError ProvisioningManager::getErrorCode() const
{
    return _errorCode;
}

QString ProvisioningManager::deviceSSID() const
{
    return _deviceSSID;
}

void ProvisioningManager::setDeviceSSID(const QString &deviceSSID)
{
    if(_deviceSSID == deviceSSID)
        return;

    _deviceSSID = deviceSSID;
    Q_EMIT deviceSSIDChanged();
}

QString ProvisioningManager::getShortID()
{
    return _socketConfigurator->shortID();
}

QString ProvisioningManager::getDeviceIP()
{
    return _socketConfigurator->deviceIP();
}

QString ProvisioningManager::ssid()
{
    return _changer->currentSSID();
}

ProvisioningManager::ProvisioningState ProvisioningManager::state() const
{
    return _state;
}

void ProvisioningManager::addTimerTransition(QState* from, QAbstractState* to, int interval, ProvisioningError errorCode)
{
    QSignalTransition* timoutTranstion = new QSignalTransition(_timoutTimer, &QTimer::timeout);
    if(errorCode != ERR_PROVISIONING_NO_ERROR)
        connect(timoutTranstion, &QSignalTransition::triggered, [=](){_errorCode = errorCode;});
    timoutTranstion->setTargetState(to);
    connect(from, &QAbstractState::entered,[=](){_timoutTimer->setInterval(interval); _timoutTimer->start();});
    from->addTransition(timoutTranstion);
}

void ProvisioningManager::addErrorTransition(QState *from, QAbstractState *to, QObject *sender, const char *signal, ProvisioningManager::ProvisioningError errorCode)
{
    QSignalTransition* errorTransition = new QSignalTransition(sender, signal);
    connect(errorTransition, &QSignalTransition::triggered, [=](){_errorCode = errorCode;});
    errorTransition->setTargetState(to);
    from->addTransition(errorTransition);
}

void ProvisioningManager::wifiConnectedStateChanged()
{
    if(_changer->wifiConnected() && _changer->currentSSID() == _deviceSSID)
    {
        qDebug()<<"State: CONNECTED";
        Q_EMIT connectedToTargetWifi();
    }

    if(_changer->wifiConnected() && _changer->currentSSID() == _targetSsid)
    {
        qDebug()<<"State: CONNECTED TO HOMEWIFI";
        Q_EMIT connectedToHomeWifi();
    }
}


