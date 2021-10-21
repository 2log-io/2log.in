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


#ifndef SOCKETCONFIGURATORIDFIX_H
#define SOCKETCONFIGURATORIDFIX_H

#include <QObject>
#include <QSslSocket>
#include <QSslConfiguration>
#include "ISocketConfig.h"

class SocketConfiguratorIDFix : public ISocketConfigurator
{
    Q_OBJECT

public:
    explicit SocketConfiguratorIDFix( QObject *parent = nullptr);

    QString shortID() const override;
    int status() const override;
    QString deviceIP() const override;
    QString uuid() const override;

private:
	bool sendConfig(QSslSocket *socket);
	void processMessage(QSslSocket* socket, QVariantMap msg);

	QString _targetWifiSsid;
	QString _targetWifiPass;
	QString _targetServer;
	bool	_testWifiConfiguration;

	QString				_deviceIP;
	QString				_deviceID;
	QString				_uuid;
	QSslSocket*			_socket = nullptr;
	QSslConfiguration	_sslConfiguration = { QSslConfiguration::defaultConfiguration() };

	SocketConfigurationState _status;


private slots:
	void newMessage();
	void socketStateChanged(QAbstractSocket::SocketState socketState);
	void socketErrorSlot(QAbstractSocket::SocketError err);

public slots:
    Q_INVOKABLE virtual void disconnect() override;
    Q_INVOKABLE virtual void start(QString ssid, QString pass, QString server, QString deviceHostname = "device.local.2log.io", bool testConfiguration = true) override;



};

#endif // SOCKETCONFIGURATOR_H
