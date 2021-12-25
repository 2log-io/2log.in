#include "ManualWifiChanger.h"

ManualWifiChanger::ManualWifiChanger(QObject *parent)
    : AbstractWifiChanger{parent}
{

}

void ManualWifiChanger::confirmWifiChanged()
{

    this->setCurrentSSID(_nextRequestedWifi);
    this->setWifiConnected(true);
}

bool ManualWifiChanger::switchWifi(QString ssid, QString pass)
{
    _nextRequestedWifi = ssid;
    _appropriatePassword = pass;
    Q_EMIT nextRequestedWifiChanged();
    this->setWifiConnected(false);
    return true;
}

bool ManualWifiChanger::removeWifi(QString ssid)
{
    Q_UNUSED(ssid)
    _nextRequestedWifi = "";
    _appropriatePassword = "";
    Q_EMIT nextRequestedWifiChanged();
    this->setWifiConnected(false);
    Q_EMIT setupRemoteDeviceFinished();
    return true;
}

const QString &ManualWifiChanger::nextRequestedWifi() const
{
    return _nextRequestedWifi;
}



const QString &ManualWifiChanger::appropriatePassword() const
{
    return _appropriatePassword;
}

