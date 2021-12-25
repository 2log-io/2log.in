#ifndef MANUALWIFICHANGER_H
#define MANUALWIFICHANGER_H

#include "AbstractWifiChanger.h"
#include <QObject>

class ManualWifiChanger : public AbstractWifiChanger
{
    Q_OBJECT
    Q_PROPERTY(QString nextRequestedWifi READ nextRequestedWifi NOTIFY nextRequestedWifiChanged)
    Q_PROPERTY(QString appropriatePassword READ appropriatePassword NOTIFY nextRequestedWifiChanged)

public:
    Q_INVOKABLE void confirmWifiChanged();

    bool switchWifi(QString ssid, QString pass = "") override;
    bool removeWifi(QString ssid) override;

    explicit ManualWifiChanger(QObject *parent = nullptr);

    const QString &nextRequestedWifi() const;
    const QString &appropriatePassword() const;

signals:
    void nextRequestedWifiChanged();
    void setupRemoteDeviceFinished();

private:
    QString _nextRequestedWifi;
    QString _appropriatePassword;

};

#endif // MANUALWIFICHANGER_H
