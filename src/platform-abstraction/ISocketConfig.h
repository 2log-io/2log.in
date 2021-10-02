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


#ifndef ISOCKETCONFIG_H
#define ISOCKETCONFIG_H

#include <QObject>

class ISocketConfigurator : public QObject
{

    Q_OBJECT

    Q_PROPERTY(QString shortID READ shortID NOTIFY shortIDChanged)
    Q_PROPERTY(QString deviceIP READ deviceIP NOTIFY deviceIPChanged)
    Q_PROPERTY(int status READ status NOTIFY statusChanged)


public:
    ISocketConfigurator(QObject* parent) :QObject(parent){};
    virtual ~ISocketConfigurator(){};

    virtual QString shortID() const = 0;
    virtual int status() const = 0;
    virtual QString deviceIP() const = 0;
    virtual QString uuid() const = 0;

    enum SocketConfigurationState
    {
        SOCKET_IDLE = 0,

        SOCKET_CONNECTING = 1,
        SOCKET_CONNECTED_TO_DEVICE = 2,

        SOCKET_DATA_SENT = 3,
        SOCKET_DATA_SEND_FAILED = -3,

        SOCKET_DEVICE_RECEIVED_DATA = 4,

        SOCKET_DEVICE_WIFI_TEST_SUCCEEDED = 5,
        SOCKET_DEVICE_WIFI_TEST_FAILED = -5,

        SOCKET_SEND_RESTART_DEVICE = 6,

        SOCKET_NETWORK_ERROR = -10
    };

    Q_ENUM (SocketConfigurationState)

public slots:
    Q_INVOKABLE virtual void disconnect() = 0;
    Q_INVOKABLE virtual void start(QString ssid, QString pass, QString server, QString deviceHostname = "device.local.2log.io", bool testConfiguration = true) = 0;


signals:
    void shortIDChanged();
    void deviceIPChanged();
    void uuidChanged();
    void statusChanged();

    void connectedToDevice();
    void wifiTestFailed();
    void wifiTestSucceeded();
    void dataConfirmed();
    void finished();
    void dataSent();
    void dataSendFaied();
    void socketError();

};


#endif // ISOCKETCONFIG_H
