

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
import QtQuick 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3

Item {
    id: docroot

    clip: true

    property int range
    property real xOffset
    property double gridOpacity: .05
    property color gridColor: Colors.white
    property int count
    property alias lines: lineRepeater
    property int gridItemSpan: {
        var h = 60 * 60 * 1000

        var count = docroot.width / 75
        var span = range / count

        var hours = span / h

        if (hours > 24)
            return 24 * h

        if (hours > 12)
            return 12 * h

        if (hours > 6)
            return 6 * h

        if (hours > 4)
            return 4 * h

        if (hours > 3)
            return 4 * h

        if (hours > 2)
            return 2 * h

        if (hours > 1)
            return h

        if (hours > .5)
            return .5 * h

        return span
    }

    function timeToPx(time) {
        var milis = docroot.range
        var pxPerSec = docroot.width / milis
        return time * pxPerSec
    }

    function pxToTime(px) {
        var pxPerMsec = docroot.range / docroot.width
        var pxPerSec = docroot.width / milis
        return pxPerSec * px
    }

    property int offset: {
        var date = to
        date.setHours(0)
        date.setMinutes(0)
        var off = to.getTime() % date.getTime()
        return off % gridItemSpan
    }

    property real pxOffset: timeToPx(gridItemSpan)

    Repeater {
        id: lineRepeater
        model: docroot.range / docroot.gridItemSpan + 2

        Rectangle {
            id: gridLine
            width: 1
            height: parent.height
            opacity: zero ? .8 : docroot.gridOpacity
            color: docroot.gridColor
            x: (docroot.count > 0 ? timeToPx(
                                        -docroot.offset) + index * pxOffset : 0)
               + (docroot.xOffset % pxOffset)

            property bool zero: (date.getHours() == 0)
                                && (date.getMinutes() == 0)
            property date date: {
                var idx = lineRepeater.count - index - 2 + (parseInt(
                                                                docroot.xOffset / pxOffset))
                var time = to.getTime() - idx * gridItemSpan - offset
                var date = new Date()
                date.setTime(time)
                return date
            }
        }
    }
}
