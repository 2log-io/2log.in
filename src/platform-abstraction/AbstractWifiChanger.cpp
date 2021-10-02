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


#include "AbstractWifiChanger.h"
#include <QDebug>

void AbstractWifiChanger::setCurrentSSID(const QString &currentSSID)
{
    if(_currentSsid == currentSSID)
        return;

    _currentSsid = currentSSID;
    Q_EMIT currentSSIDChanged();
}


void AbstractWifiChanger::setScanResults(const QStringList &scanResults)
{
    _scanResults = scanResults;
    Q_EMIT scanResultsChanged();
}

void AbstractWifiChanger::setWifiConnected(bool connected)
{
    _connected = connected;
    Q_EMIT wifiConnectedChanged();
}

QStringList AbstractWifiChanger::scanResults() const
{
    return _scanResults;
}

QStringList AbstractWifiChanger::foundDots() const
{
    QStringList list;
    for(QString string : _scanResults)
    {
       if(string.startsWith("I'm a Dot"))
       {
            list << string;
       }
    }
    return list;
}

QStringList AbstractWifiChanger::foundSwitches() const
{
    return QStringList();
}

bool AbstractWifiChanger::wifiConnected() const
{
    return _connected;
}


QString AbstractWifiChanger::currentSSID() const
{
    return _currentSsid;
}
