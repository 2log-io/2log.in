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


#ifndef ISLEEPAVOIDER_H
#define ISLEEPAVOIDER_H

#include <QObject>

class ISleepAvoider : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool lock READ isLocked WRITE setLock NOTIFY lockedChanged)

public:
    ISleepAvoider(QObject* parent = nullptr) :  QObject(parent){};
    Q_INVOKABLE virtual void dolock() {};
    Q_INVOKABLE virtual void unlock(){};
    Q_INVOKABLE void setLock(bool lock)
    {
        if(_locked == lock)
            return;

        if(lock)
            dolock();
        else
            unlock();

        _locked = lock;
        Q_EMIT lockedChanged();
    };
    bool isLocked(){return _locked;};

signals:
    void lockedChanged();

protected:
    bool _locked = false;
};

#endif // ISLEEPAVOIDER_H


