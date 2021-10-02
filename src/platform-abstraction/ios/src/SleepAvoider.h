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


#ifndef SLEEPAVOIDER_H
#define SLEEPAVOIDER_H

#include <QObject>
#include "../../ISleepAvoider.h"


class SleepAvoider : public ISleepAvoider
{
    Q_OBJECT

public:
    SleepAvoider(QObject* parent = nullptr):ISleepAvoider(parent){};
    Q_INVOKABLE void dolock() override;
    Q_INVOKABLE void unlock() override;


};

#endif // SLEEPAVOIDER_H
