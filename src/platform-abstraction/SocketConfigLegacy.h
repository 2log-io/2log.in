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


#ifndef SOCKETCONFIGURATOR_H
#define SOCKETCONFIGURATOR_H

#include <QObject>
#include <QTcpSocket>
#include "ISocketConfig.h"

class SocketConfiguratorLegacy : public ISocketConfigurator
{
    Q_OBJECT
    Q_PROPERTY(QString shortID READ shortID NOTIFY shortIDChanged)
    Q_PROPERTY(QString deviceIP READ deviceIP NOTIFY deviceIPChanged)
    Q_PROPERTY(int status READ status NOTIFY statusChanged)


public:
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

    Q_ENUM (SocketConfigurationState);


    explicit SocketConfiguratorLegacy( QObject *parent = nullptr);

    QString shortID() const;
    int status() const;
    QString deviceIP() const;

    QString uuid() const;

private:
    bool sendConfig(QTcpSocket *socket);
    void processMessage(QTcpSocket* socket, QVariantMap msg);

    QString _targetWifiSsid;
    QString _targetWifiPass;
    QString _targetServer;

    QString     _deviceIP;
    QString     _deviceID;
    QString     _uuid;
    QTcpSocket* _socket = nullptr;

    SocketConfigurationState _status;

public slots:
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void start(QString ssid, QString pass, QString server, QString ip ="192.168.4.1", bool testConfiguration = true);

private slots:
    void newMessage();
    void socketStateChanged(QAbstractSocket::SocketState socketState);
    void socketErrorSlot(QAbstractSocket::SocketError err);

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

#endif // SOCKETCONFIGURATOR_H
