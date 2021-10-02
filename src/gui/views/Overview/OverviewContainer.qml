import QtQuick 2.0
import AppComponents 1.0
import UIControls 1.0
import "../DeviceDetails"
import QtQuick.Layouts 1.3
import CloudAccess 1.0

Container
{
    id: docroot
    headline:  qsTr("Gesamtverlauf")
    width: parent.width

    property double xOffset: 0

    property int range: 1 * 12 * 60 * 60 * 1000

    property date to:
    {
        var date = new Date()
        return date
    }

    property date from:
    {
         var date = new Date()
         date.setTime(to.getTime() - 2*range )
         return date
    }

    property int fromSec: from.getTime()

    property int toSec: to.getTime()

    property real pxPerSec:indicatorRepeater.count > 0 ? indicatorRepeater.itemAt(0).width / docroot.range : 0

    property bool test

    function timeToPx(time)
    {
        var milis = docroot.range
        var pxPerSec = indicatorRepeater.itemAt(0).width / milis
        return time * pxPerSec
    }

    function timeToX(time)
    {
        var range = docroot.range
        var delta =  to.getTime() - time.getTime()
        var pixRange = indicatorRepeater.itemAt(0).width
        return pixRange - (delta / range * pixRange) //w+ xOffset
    }

    function secToX(time)
    {
        var date = new Date()
        return timeToX(date.setTime(time))
    }

    function pxToTime(px)
    {
        var pxPerMsec =  docroot.range / indicatorRepeater.itemAt(0).width
        return pxPerSec * px
    }


    ColumnLayout
    {
        width: parent.width
        height: layout.height + 40//docroot.height - docroot.margins - 40

        Item
        {
            Layout.fillWidth: true
            Layout.minimumHeight: 20
            Layout.maximumHeight: 20

            GridLabels
            {
                grid: gridLines.lines
                height: 20
                width: gridLines.width
                anchors.right: parent.right
            }
        }


        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true


            Rectangle
            {
                z: 10
                anchors.bottom: flickable.bottom
                height: 20
                width: flickable.width
                opacity: 1
                gradient: Gradient {
                         GradientStop { position: 1.0; color: Colors.darkBlue }
                         GradientStop { position: 0.0; color: "transparent" }
                     }
            }



            Flickable
            {
                id: flickable
                clip: true
                contentWidth: width
                contentHeight: layout.height
                interactive: flickable.height < contentHeight && !dragArea.lock
                anchors.fill: parent

                MouseArea
                {
                    id: dragArea
                    property real start
                    property real start2
                    property bool lock

                    anchors.fill: parent
                    onPressed:
                    {
                        start = mouseX
                        start2 = mouseX
                    }
                    onReleased:  lock = false
                    onMouseXChanged:
                    {
                        if (xOffset + (mouseX -start) < 0)
                            return
                        lock = Math.abs(start2 - mouseX) > 5
                        xOffset += mouseX -start
                        start = mouseX
                    }

                    onWheel:
                    {
                        if (xOffset + wheel.pixelDelta.x < 0)
                            return

                        xOffset += wheel.pixelDelta.x
                        wheel.accepted = false
                    }
                }

                GridLayout
                {
                    id: layout
                    width: parent.width
                    columns: 2
                    rows:  indicatorRepeater.count
                    columnSpacing: 10
                    rowSpacing:0

                    TimeGrid
                    {
                        id: gridLines
                        Layout.rowSpan:indicatorRepeater.count
                        Layout.row: 0
                        Layout.column: 1
                        Layout.fillWidth: true
                        Layout.minimumHeight: indicatorRepeater.count*42
                        count: indicatorRepeater.count
                        clip: true
                        xOffset:  docroot.xOffset
                        range: docroot.range
                        visible: true
                        Column
                        {
                            //spacing: 10
                            anchors.fill: parent
                            Repeater
                            {
                                id: indicatorRepeater
                                model:  deviceModel

                                Item
                                {
                                    visible: true
                                    Layout.column: 1
                                    Layout.row: index
                                    width: parent.width
                                    height: 42
                                    //clip: true


                                    Rectangle
                                    {
                                        height: 1
                                        anchors.bottom: parent.bottom
                                        anchors.right: parent.right
                                        anchors.left: parent.left
                                        opacity: .2
                                    }

                                    Rectangle
                                    {
                                        visible: index == 0
                                        height: 1
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.left: parent.left
                                        opacity: .2
                                    }


                                    Item
                                    {
                                        height: parent.height
                                        width: parent.width
                                        x: docroot.xOffset
                                        Repeater
                                        {
                                            model: logModel

                                            Rectangle
                                            {
                                                property string start: startTime
                                                property string end: endTime
                                                property date startTimeObj: TypeDef.parseISOLocal(start)
                                                property date endTimeObj: TypeDef.parseISOLocal(end)

                                                height: 20
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.verticalCenterOffset: docroot.width < 460 ? 6 : 0

                                                color: Colors.highlightBlue
                                                x: timeToX(startTimeObj)
                                               // visible: x+width > 0 && x < layout.width
                                                width: (timeToX(endTimeObj) - x) < 1 ? 1 : timeToX(endTimeObj) - x
                                            }
                                        }
                                    }
                                    TextLabel
                                    {
                                        anchors.top: parent.top
                                        anchors.topMargin: 2
                                        id: textIn
                                        opacity:.5
                                        text: _displayName
                                        Layout.alignment : Qt.AlignRight
                                        visible:  docroot.width < 460
                                        fontSize: 11
                                    }


                                    LogModel
                                    {
                                        id: logModel
                                        logType: 13
                                        resourceID:_deviceID
                                        visibleRange: docroot.range
                                        currentPos: (xOffset + gridLines.width/2) / gridLines.width
                                        to: docroot.to
                                    }
                                }
                            }
                        }
                    }

                    FilteredDeviceModel
                    {
                        id: deviceModel
                        deviceType:["Controller/*", "Controller"]
                    }

                    Repeater
                    {
                        id: deviceModelRepeater
                        model: deviceModel
                        Item
                        {
                            id: labelWrapper
                            visible: docroot.width > 460
                            width: text.width
                            Layout.minimumHeight: 40
                            Layout.maximumHeight: 40
                            Layout.alignment: Qt.AlignRight
                            Layout.column: 0
                            Layout.row: index

                            TextLabel
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                id: text
                                text: _displayName
                                Layout.alignment : Qt.AlignRight
                            }
                        }
                    }
                }
            }
        }
    }
}
