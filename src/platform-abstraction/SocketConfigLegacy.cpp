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


#include "SocketConfigLegacy.h"
#include <QJsonDocument>
#include <QNetworkInterface>

SocketConfiguratorLegacy::SocketConfiguratorLegacy( QObject *parent) : ISocketConfigurator(parent)
{

}

void SocketConfiguratorLegacy::start(QString ssid, QString pass, QString server, QString ip, bool testConfiguration)
{
    if(_socket)
    {
        _socket->disconnect();
        _socket->deleteLater();
    }

    _targetWifiPass = pass;
    _targetServer = server;
    _targetWifiSsid = ssid;
    _deviceID = "";
    _deviceIP = "";

    qDebug()<<"START "<<ssid<<"  "<<pass;
    _status = SOCKET_CONNECTING;
    Q_EMIT statusChanged();
    QTcpSocket* socket = new QTcpSocket(this);
    connect(socket, &QTcpSocket::readyRead, this, &SocketConfiguratorLegacy::newMessage);
    connect(socket, &QTcpSocket::stateChanged, this, &SocketConfiguratorLegacy::socketStateChanged);
    connect(socket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(socketErrorSlot(QAbstractSocket::SocketError)));
    socket->connectToHost(ip, 80);
}

QString SocketConfiguratorLegacy::shortID() const
{
    return _deviceID;
}

bool SocketConfiguratorLegacy::sendConfig(QTcpSocket* socket)
{
    QVariantMap pl;
    pl["ssid"] = _targetWifiSsid;
    pl["pass"] = _targetWifiPass;
    pl["server"] = _targetServer;

    QVariantMap msg;
    msg["pl"] = pl;
    msg["cmd"] = "setconfig";
    return socket->write(QJsonDocument::fromVariant(msg).toJson()) >= 0;
}

void SocketConfiguratorLegacy::processMessage(QTcpSocket* socket, QVariantMap msg)
{
    QString command = msg["cmd"].toString();
    QVariantMap payload = msg["pl"].toMap();

    if(command == "welcome")
    {
        _deviceID = msg["sid"].toString();
        _uuid = msg["uuid"].toString();
        qDebug()<<"UUID"<<_uuid;
        Q_EMIT uuidChanged();
        Q_EMIT shortIDChanged();
        if(sendConfig(socket))
        {
            _status = SOCKET_DATA_SENT;
            Q_EMIT dataSent();
        }
        else
        {
            _status =  SOCKET_DATA_SEND_FAILED;
            Q_EMIT dataSendFaied();
        }
        Q_EMIT statusChanged();
    }

    if(command == "setconfig")
    {

        int status = msg["status"].toInt();

        if(status == 1)
        {
            _status = SOCKET_DEVICE_RECEIVED_DATA;
            Q_EMIT dataConfirmed();
            Q_EMIT statusChanged();
            return;
        }
        else if (status == 0)
        {
            _status = SOCKET_DEVICE_WIFI_TEST_SUCCEEDED;
            Q_EMIT wifiTestSucceeded();
            _deviceIP = payload["ip"].toString();
            Q_EMIT deviceIPChanged();
        }
        else if (status < 0)
        {
            _status = SOCKET_DEVICE_WIFI_TEST_FAILED;
            Q_EMIT wifiTestFailed();
        }

        Q_EMIT statusChanged();

        QVariantMap msg;
        msg["cmd"] = "finish";
        socket->write(QJsonDocument::fromVariant(msg).toJson());
        socket->waitForBytesWritten(5000);
        socket->close();
    }
}

QString SocketConfiguratorLegacy::uuid() const
{
    return _uuid;
}

void SocketConfiguratorLegacy::disconnect()
{
    if(_socket)
        _socket->disconnect();
}



QString SocketConfiguratorLegacy::deviceIP() const
{
    return _deviceIP;
}

int SocketConfiguratorLegacy::status() const
{
    return _status;
}

void SocketConfiguratorLegacy::newMessage()
{
    QTcpSocket* socket = qobject_cast<QTcpSocket*>(sender());
    if(!socket)
        return;

    QString string = socket->readAll();
    string = string.replace("'","\"");
    QStringList tokens = string.split("\r\n");

    for(QString token : tokens)
    {
        QVariantMap msg = QJsonDocument::fromJson(token.toLatin1()).toVariant().toMap();
        processMessage(socket, msg);
        qDebug()<< token;
    }

}

void SocketConfiguratorLegacy::socketStateChanged(QAbstractSocket::SocketState socketState)
{
    QTcpSocket* socket = qobject_cast<QTcpSocket*>(sender());
    if(!socket)
        return;

    switch(socketState)
    {
        case QAbstractSocket::ConnectedState:
        {
            _status = SOCKET_CONNECTED_TO_DEVICE;
            Q_EMIT statusChanged();
            Q_EMIT connectedToDevice();
            qDebug()<<"Connected.";
            QVariantMap hiMsg;
            hiMsg["cmd"] = "hi";
            socket->write(QJsonDocument::fromVariant(hiMsg).toJson());
            break;
        }
        case QAbstractSocket::UnconnectedState:
        {
            qDebug()<<"Disconnected.";
            socket->deleteLater();
            Q_EMIT finished();
            _status = SOCKET_IDLE;
            Q_EMIT statusChanged();
            break;
        }

        default: qDebug()<<socketState;
    }
}

void SocketConfiguratorLegacy::socketErrorSlot(QAbstractSocket::SocketError err)
{
    Q_UNUSED(err)
    QTcpSocket* socket = qobject_cast<QTcpSocket*>(sender());
    if(!socket)
        return;

    qDebug()<<socket->errorString();
    Q_EMIT socketError();
}
