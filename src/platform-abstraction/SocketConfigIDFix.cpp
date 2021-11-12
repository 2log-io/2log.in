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


#include "SocketConfigIDFix.h"
#include <QJsonDocument>
#include <QNetworkInterface>


SocketConfiguratorIDFix::SocketConfiguratorIDFix( QObject *parent) : ISocketConfigurator(parent)
{

}

void SocketConfiguratorIDFix::start(QString ssid, QString pass, QString server, QString deviceHostname, bool testConfiguration)
{
    if(_socket)
    {
        _socket->disconnect();
        _socket->deleteLater();
    }

    _targetWifiPass = pass;
    _targetServer = server;
    _targetWifiSsid = ssid;
    _testWifiConfiguration = testConfiguration;
    _deviceID = "";
    _deviceIP = "";

    qDebug()<<"START "<<ssid<<"  "<<pass;
    _status = SOCKET_CONNECTING;
    Q_EMIT statusChanged();
    QSslSocket* socket = new QSslSocket(this);

    QList<QSslCertificate> caChain = QSslCertificate::fromPath("://Assets/2log-device.local.crt");

    //qDebug() << "FOO caChain size: " << caChain.size();

    // _sslConfiguration.setCaCertificates(caChain);
    // _sslConfiguration.setPeerVerifyMode(QSslSocket::VerifyPeer);
    _sslConfiguration.setPeerVerifyMode(QSslSocket::VerifyNone);
    socket->setSslConfiguration( _sslConfiguration );

    connect(socket, &QSslSocket::readyRead, this, &SocketConfiguratorIDFix::newMessage);
    connect(socket, &QSslSocket::stateChanged, this, &SocketConfiguratorIDFix::socketStateChanged);
    connect(socket, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(socketErrorSlot(QAbstractSocket::SocketError)));
    socket->connectToHostEncrypted(deviceHostname, 8443);
}

QString SocketConfiguratorIDFix::shortID() const
{
    return _deviceID;
}

bool SocketConfiguratorIDFix::sendConfig(QSslSocket *socket)
{
    QVariantMap extconfig;

        extconfig["server"]     = _targetServer;
        extconfig["testconfig"] = _testWifiConfiguration;

    QVariantMap msg;

        msg["cmd"]          = "setconfig";
        msg["ssid"]         = _targetWifiSsid;
        msg["pass"]         = _targetWifiPass;
        msg["extconfig"]    = extconfig;


    return socket->write(QJsonDocument::fromVariant(msg).toJson()) >= 0;
}

void SocketConfiguratorIDFix::processMessage(QSslSocket *socket, QVariantMap msg)
{
    QString command = msg["cmd"].toString();

    if(command == "welcome")
    {
        QVariantMap deviceInfo = msg["device"].toMap();

        _deviceID = deviceInfo["sid"].toString();
        _uuid = deviceInfo["uuid"].toString();
        qDebug()<<"UUID "<<_uuid;
        qDebug()<<"sid "<<_deviceID;
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
            _deviceIP = msg["ip"].toString();
            qDebug() << "IP: " << _deviceIP;
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
        socket->disconnectFromHost();
    }
}

QString SocketConfiguratorIDFix::uuid() const
{
    return _uuid;
}

void SocketConfiguratorIDFix::disconnect()
{
    if(_socket)
        _socket->disconnectFromHost();
}



QString SocketConfiguratorIDFix::deviceIP() const
{
    return _deviceIP;
}

int SocketConfiguratorIDFix::status() const
{
    return _status;
}

void SocketConfiguratorIDFix::newMessage()
{
    QSslSocket* socket = qobject_cast<QSslSocket*>(sender());
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

void SocketConfiguratorIDFix::socketStateChanged(QAbstractSocket::SocketState socketState)
{
    QSslSocket* socket = qobject_cast<QSslSocket*>(sender());
    if(!socket)
        return;

    switch(socketState)
    {
        case QAbstractSocket::ConnectedState:
        {
            _status = SOCKET_CONNECTED_TO_DEVICE;
            Q_EMIT statusChanged();
            Q_EMIT connectedToDevice();
            qDebug()<<"Connected!!;D.";
            QVariantMap hiMsg;
            hiMsg["cmd"] = "hi";
            qDebug() << "wrote  "<<socket->write(QJsonDocument::fromVariant(hiMsg).toJson())<<" bytes.";
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

void SocketConfiguratorIDFix::socketErrorSlot(QAbstractSocket::SocketError err)
{
    Q_UNUSED(err)
    QSslSocket* socket = qobject_cast<QSslSocket*>(sender());
    if(!socket)
        return;

    qDebug()<<socket->errorString();
    Q_EMIT socketError();
}
