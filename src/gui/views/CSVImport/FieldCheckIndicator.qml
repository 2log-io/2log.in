import QtQuick 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3

Item
{
    id: docroot

    property int index: reader.cardIndex
    property string label:  "Karten ID"
    property bool mandatory: false
    property bool optional: false
    property bool overwritten: false
    onOverwrittenChanged: console.log(overwritten+" OVER")
    property alias buttonRect: buttonBackground
    property bool checked: false
    signal clicked()

    width: layout.width
    height: 40


    function blink()
    {
        errorAnimation.start()
    }



    SequentialAnimation
    {
        id: errorAnimation
        NumberAnimation {target: buttonBackground; property:"opacity"; from: 1; to: 0; duration: 150}
        NumberAnimation {target: buttonBackground; property:"opacity"; from: 0; to: 1; duration: 150}
        NumberAnimation {target: buttonBackground; property:"opacity"; from: 1; to: 0; duration: 150}
        NumberAnimation {target: buttonBackground; property:"opacity"; from: 0; to: 1; duration: 150}
        NumberAnimation {target: buttonBackground; property:"opacity"; from: 1; to: 0; duration: 150}
        NumberAnimation {target: buttonBackground; property:"opacity"; from: 0; to: 1; duration: 150}
    }



    Rectangle
    {
        id: buttonBackground
        visible: false
        width: layout.width +18
        height: layout.height +8
        anchors.centerIn: layout
        color: Colors.brighterDarkBlue_controls
        radius: 2
    }

    Row
    {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        TextLabel
        {
            text: docroot.label
            anchors.verticalCenter: parent.verticalCenter
        }

        Icon
        {
            id: icon
            iconSize: 10
            iconColor:  Colors.highlightBlue
            icon:  Icons.check
            anchors.verticalCenter: parent.verticalCenter
            opacity: buttonBackground.opacity
        }
        onStateChanged: console.log(state)

        states:
        [
            State
            {
                name:"pressed"
                when: mouse.pressed && mouse.enabled
                PropertyChanges
                {
                    target: buttonBackground
                    color:  Colors.darkBlue
                }
                PropertyChanges
                {
                    target: layout
                    opacity: 1
                }
            },
            State
            {
                name:"hover"
                when: (mouse.containsMouse  && mouse.enabled) && !docroot.mandatory
                PropertyChanges
                {
                    target: layout
                    opacity: 1
                }

                PropertyChanges
                {
                    target: buttonBackground
                    visible: true
                }
            },
            State
            {
                name:"clickable"
                when:  mouse.enabled && docroot.state == "incomplete"
                PropertyChanges
                {
                    target: layout
                    opacity: .7
                }
            }
//            ,
//            State
//            {
//                name:"checked"
//                when:  docroot.checked
//                PropertyChanges
//                {
//                    target: layout
//                    opacity: 1
//                }

//                PropertyChanges
//                {
//                    target: buttonBackground
//                    visible: true
//                }
//            }
        ]

        transitions:
        [
            Transition
            {
                from: "pressed"
                to:"hover"

                NumberAnimation
                {
                    property: "opacity"
                }

                ColorAnimation {
                    target: buttonBackground
                    duration: 200
                }
            },

            Transition
            {
                from: "hover"
                to:"clickable"

                NumberAnimation
                {
                    property: "opacity"
                }

                ColorAnimation
                {
                    target: buttonBackground
                    duration: 200
                }
            }
        ]

    }

    MouseArea
    {
        id: mouse
        hoverEnabled: true
        anchors.fill: parent
        enabled: true
        onClicked: docroot.clicked()
    }

    onStateChanged: console.log(state)
    states:
    [
        State
        {
            name:"error"
            when: docroot.index < 0 && docroot.mandatory && !docroot.overwritten

            PropertyChanges
            {
                target: icon
                iconColor: Colors.warnRed
                icon: Icons.forbidden
            }

            PropertyChanges
            {
                target: mouse
                enabled: true
            }

//            PropertyChanges
//            {
//                target: buttonBackground
//                visible: true
//            }
        },

        State
        {
            name: "incomplete"
            when: docroot.index < 0 && !docroot.mandatory && !docroot.overwritten  && !docroot.optional
            PropertyChanges
            {
                target: icon
                icon: Icons.warning
                iconColor: Colors.warnYellow
            }

            PropertyChanges
            {
                target: mouse
                enabled: true
            }
            PropertyChanges
            {
                target: buttonBackground
                visible: true
            }
        },
        State
        {
            name: "optional"
            when: docroot.index < 0 && !docroot.mandatory && !docroot.overwritten && docroot.optional
            PropertyChanges
            {
                target: icon
                icon: Icons.question
                iconColor: Colors.white
            }

            PropertyChanges
            {
                target: mouse
                enabled: true
            }
            PropertyChanges
            {
                target: buttonBackground
                visible: true
            }
        }

    ]
}