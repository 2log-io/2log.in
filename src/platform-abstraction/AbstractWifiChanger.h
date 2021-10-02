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


#ifndef IWIFICHANGER_H
#define IWIFICHANGER_H

#include <QObject>

class AbstractWifiChanger : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString currentSSID READ currentSSID  NOTIFY currentSSIDChanged)
    Q_PROPERTY(QStringList scanResults READ scanResults  NOTIFY scanResultsChanged)
    Q_PROPERTY(QStringList foundDots READ foundDots  NOTIFY scanResultsChanged)
    Q_PROPERTY(QStringList foundSwitches READ foundSwitches  NOTIFY scanResultsChanged)
    Q_PROPERTY(bool wifiConnected READ wifiConnected NOTIFY wifiConnectedChanged)

public:
    explicit AbstractWifiChanger(QObject* parent) : QObject(parent){};
    virtual ~AbstractWifiChanger(){};
    
    QString currentSSID() const;
    QStringList scanResults() const;
    QStringList foundDots() const;
    QStringList foundSwitches() const ;
    bool wifiConnected() const;

    Q_INVOKABLE virtual int requestPermissions(){return 0;};
    Q_INVOKABLE virtual bool startScan() {return false;};
    Q_INVOKABLE virtual bool switchWifi(QString ssid, QString pass = "")
    {
        Q_UNUSED (ssid)
        Q_UNUSED (pass)
        return false;
    };

    Q_INVOKABLE virtual bool removeWifi(QString ssid)
    {
        Q_UNUSED (ssid)
        return false;
    };

protected:
    void setCurrentSSID(const QString &currentSSID);
    void setScanResults(const QStringList &scanResults);
    void setWifiConnected(bool wifiConnected);

private:
    QStringList _scanResults;
    QString     _currentSsid;
    bool        _connected;

signals:
    void currentSSIDChanged();
    void scanResultsChanged();
    void wifiConnectedChanged();

};


#endif // IWIFICHANGER_H
