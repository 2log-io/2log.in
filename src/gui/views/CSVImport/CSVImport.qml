import QtQuick 2.5
import QtQuick.Controls 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0

ViewBase
{
    id: docroot
    viewID: "csvimport"
    headline: qsTr("CSV Import")
    property CSVReader reader: csvReader

    Item
    {
        id: logic
        property bool working: false
        property int success
        property int updated
        property int fails
        property int total: success+fails
        property int currentIndex: 0
        signal callComplete()
        signal finished()
        onFinished: finishedDialig.open()

        ServiceModel
        {
            id: labService
            service: "lab"
        }

        function startImport()
        {
            if(working)
                return;

            logic.success = 0
            logic.fails  = 0
            logic.updated  = 0
            logic.working = true
            labService.call("addOrUpdateUser", csvReader.getIndex(logic.currentIndex), logic.addUserCb)
        }

        function addUserCb(data)
        {
            if(data.errorCode >= 0)
            {
                logic.success++

                if(data.errorCode === 1)
                    logic.updated++
            }
            else
            {
                console.log("import failed: "+logic.currentIndex+" "+csvReader.getIndex(logic.currentIndex)["user"]["name"]+" "+csvReader.getIndex(logic.currentIndex)["user"]["surname"]);
                logic.fails++
            }

            if(currentIndex < csvReader.count-1)
            {
                labService.call("addOrUpdateUser", csvReader.getIndex(++logic.currentIndex), addUserCb)
            }
            else
            {
                logic.finished()
                logic.currentIndex = 0;
                logic.working = false
                return
            }

            logic.callComplete()
        }
    }

    Item
    {

        Binding
        {
            target: reader
            property: "overwriteRole"
            value: p.role >= 0 ? TypeDef.roles[p.role].code : undefined
            when: !logic.working
        }

        Binding
        {
            target: reader
            property: "overwriteCourse"
            value: p.role >= 0 ? TypeDef.courses[p.course].code : undefined
            when: !logic.working
        }

        Binding
        {
            target: reader
            property: "overwriteGroup"
            value:  p.groupObject !== undefined ?  p.groupObject.uuid : undefined
            when: !logic.working
        }

        Binding
        {
            target: reader
            property: "overwriteBalance"
            value: p.balance
            when: !logic.working
        }

        Connections
        {
            target: reader
            onCountChanged:
            {
                list.model = 0; list.model = reader.count; if(reader.count > 0 && docroot.hasErrors()) errorDialog.open()
            }
            onFileLoaded:
            {
                p.course = -1
                p.role = -1
                p.group = -1

            }
        }

        Binding
        {
            target: reader
            property: "overwriteDate"
            when: !logic.working
            value:datePicker.selectedDate
        }

        QtObject
        {
            id: p
            property alias role: roleFlyout.selectedIndex
            property alias course: courseFlyout.selectedIndex
            property alias group: groupDropDown.selectedIndex
            property var groupObject
            property int balance

            onGroupChanged:
            {
                groupObject = groupModel.get(group)
            }
        }


        InfoDialog
        {
            id: errorDialog
            icon: Icons.warning
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.warnRed
            text: qsTr("Die Tabelle ist unvollständig. Es fehlen folgende Spalten:") +"\n" +
                  reader.nameIndex < 0 ? "\n• "+ qsTr("Vorname") : ""+
                  reader.surnameIndex < 0 ? "\n• "+ qsTr("Nachname") : ""+
                  reader.mailIndex < 0 ? "\n• "+ qsTr("eMail") : ""

            StandardButton
            {
                text:qsTr("OK")
                onClicked: errorDialog.close()
            }
        }


        InfoDialog
        {
            id: finishedDialig
            Item
            {
                states:
                [
                    State
                    {
                        name:"error"
                        when: logic.fails === logic.total

                        PropertyChanges
                        {
                            target: finishedDialig
                            iconColor: Colors.warnRed
                            icon: Icons.warning2
                        }
                    } ,
                    State
                    {
                        name:"warning"
                        when: logic.fails > 0

                        PropertyChanges
                        {
                            target: finishedDialig
                            iconColor: Colors.warnYellow
                            icon: Icons.warning
                        }
                    }
                ]
            }
            anchors.centerIn: Overlay.overlay
            icon: Icons.check
            iconColor: Colors.highlightBlue
            headline:qsTr("Import abgeschlossen")
            text:
            {   
                var description = "\n"+qsTr("Von %1 Datensätzen wurden %2 geupdatet und %3 neu angelegt. %4 Datensätze waren fehlerhaft.").arg(logic.total).arg(logic.updated).arg(logic.success - logic.updated).arg(logic.fails)

                var reasons =
                       "\n\n"+qsTr("Mögliche Gründe:")
                      + "\n• "+qsTr("Keine oder ungültige eMail Adresse")
                      + "\n• "+qsTr("Nutzer bereits im System registriert")
                      + "\n• "+qsTr("Karten ID bereits vergeben")

                if(logic.fails > 0)
                    description = description + reasons

               return description

            }

            StandardButton
            {
                text:qsTr("OK")
                onClicked: finishedDialig.close()
            }
        }
    }


    function  hasErrors()
    {
        var name = reader.nameIndex >= 0
        if(!name)
            nameCheck.blink()

        var surname  = reader.surnameIndex >= 0
        if(!surname)
            surnameCheck.blink()

        var email = reader.mailIndex >= 0
        if(!email)
            emailCheck.blink()

        return !(name && surname && email)
    }

    function checkValidity()
    {
        var course = reader.courseIndex >= 0 || p.course >= 0
        if(!course)
            courseCheck.blink()
        var role = reader.roleIndex >= 0 || p.role >= 0
        if(!role)
            roleCheck.blink()

        return !hasErrors() && role && course
    }



    ColumnLayout
    {
        id: columnLayout
        anchors.fill: parent
        spacing: 20

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Container
            {
                id: importContainer
                anchors.fill: parent
                contentHeight: parent.height - 40 - margins
                headline: qsTr("Import")

                header:
                    Row{
                    anchors.right: parent.right
                    height: parent.height
                    anchors.verticalCenter:parent.verticalCenter
                    spacing: 20


                    ContainerButton
                    {
                        id: setupbtn2
                        anchors.verticalCenter:parent.verticalCenter
                        icon: Icons.downloadFile
                        enabled: !logic.working
                        //enabled: stack.currentItem.stackID === "info" && deviceModel.available
                        text:qsTr("Formatvorlage")
                        onClicked: reader.downloadSampleCSV()
                    }

                    ContainerButton
                    {
                        id: setupbtn
                        anchors.verticalCenter:parent.verticalCenter
                        icon: Icons.uploadFile
                        enabled: !logic.working
                        //enabled: stack.currentItem.stackID === "info" && deviceModel.available
                        text:qsTr("CSV hochladen")
                        onClicked: reader.readFromDialog()
                    }

                    Row
                    {
                        spacing: 5
                        height: parent.height
                        anchors.verticalCenter:parent.verticalCenter

                        CounterBubble
                        {
                            id: bubble
                            visible: reader.count !== 0
                            text: !logic.working ? reader.count : logic.total +"/"+ reader.count
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ContainerButton
                        {
                            id: importbtn
                            visible: reader.count !== 0
                            anchors.verticalCenter:parent.verticalCenter
                            enabled: !logic.working
                            text:qsTr("Import starten")
                            onClicked:
                            {
                                console.log("CLICK")
                                if(docroot.checkValidity())
                                {
                                    console.log("OK")
                                    logic.startImport()
                                }
                            }
                        }
                    }
                }

                ColumnLayout
                {
                    id: layout
                    width: parent.width
                    height: parent.height

                    //  height: importContainer.height -40

                    Row
                    {
                        Layout.fillWidth:true
                        height: 40
                        spacing: 5

                        opacity: reader.count != 0 ? 1 : 0

                        FieldCheckIndicator
                        {
                            id: surnameCheck
                            index: reader.surnameIndex
                            width: (120 / 720) * (layout.width-220)
                            label: qsTr("Nachname")
                            mandatory: true
                        }


                        FieldCheckIndicator
                        {
                            id: nameCheck
                            width: (120 / 720) * (layout.width-220)
                            index: reader.nameIndex
                            label: qsTr("Vorname")
                            mandatory: true
                        }


                        FieldCheckIndicator
                        {
                            id: emailCheck
                            width: (200 / 720) * (layout.width-220)
                            index: reader.mailIndex
                            label: qsTr("eMail")
                            mandatory: true
                        }

                        FieldCheckIndicator
                        {
                            id: courseCheck
                            width: (80 / 720) * (layout.width-220)

                            index: reader.courseIndex
                            label: qsTr("Studg.")
                            onClicked: courseFlyout.open()
                            overwritten: p.course >= 0
                            checked: courseFlyout.opened

                            OptionChooser
                            {

                                id: courseFlyout
                                label: qsTr("Studiengang wählen")
                                parent: courseCheck.buttonRect
                                options: TypeDef.getLongStrings(TypeDef.courses)// ["Student","Angestellter","Extern"]
                                onSelectedIndexChanged: courseFlyout.close()
                            }
                        }


                        FieldCheckIndicator
                        {
                            id: roleCheck
                            width: (100 / 720) * (layout.width-220)
                            index: reader.roleIndex
                            label: qsTr("Rolle")
                            onClicked: roleFlyout.open()
                            overwritten: p.role >= 0
                            checked: roleFlyout.opened


                            OptionChooser
                            {
                                id: roleFlyout
                                parent: roleCheck.buttonRect
                                options: TypeDef.getLongStrings(TypeDef.roles)// ["Student","Angestellter","Extern"]
                                label: qsTr("Rolle wählen")
                                onSelectedIndexChanged: roleFlyout.close()
                            }
                        }

                        FieldCheckIndicator
                        {
                            id: groupCheck
                            width: (100 / 720) * (layout.width-220)
                            index: reader.groupIndex
                            label: qsTr("Gruppe")
                            checked: groupFlyout.opened
                            onClicked: groupFlyout.open()
                            optional: true
                            overwritten: p.group >= 0

                            FlyoutBox
                            {
                                id: groupFlyout
                                parent: groupCheck.buttonRect
                                width: column.width+4
                                fillColor: Colors.greyBlue
                                height: column.height+10

                                Rectangle
                                {
                                    width: groupFlyout.width-4
                                    height: column.height
                                    color: Qt.darker(Colors.darkBlue, 1.2)


                                    Column
                                    {
                                        id: column
                                        spacing: 10
                                        y: -8

                                        Rectangle
                                        {
                                            width: parent.width
                                            height: 26
                                            color: Colors.greyBlue

                                            TextLabel
                                            {

                                                anchors.verticalCenter: parent.verticalCenter
                                                x: 10
                                                text: qsTr("Gruppe")
                                            }
                                        }

                                        DropDown
                                        {
                                            id: groupDropDown
                                            width: parent.width -18
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            placeholderText: qsTr("Gruppe wählen")
                                            options:
                                            {
                                                var options = []
                                                for(var i = 0; i < groupModel.count; i++)
                                                {
                                                    var description = groupModel.get(i).name
                                                    options.push(description)
                                                }
                                                return options;
                                            }

                                            SynchronizedListModel
                                            {
                                                id: groupModel
                                                resource:"labcontrol/groups"
                                            }
                                        }


                                        Rectangle
                                        {
                                            width: parent.width
                                            height: 26
                                            color: Colors.greyBlue

                                            TextLabel
                                            {
                                                anchors.verticalCenter: parent.verticalCenter
                                                x: 10
                                                text: qsTr("Ablaufdatum")
                                            }
                                        }

                                        CalendarWidget
                                        {
                                            id: datePicker
                                            enabled: groupDropDown.selectedIndex >= 0
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Item
                                        {
                                            width: parent.width
                                            height: 40

                                            StandardButton
                                            {
                                                anchors.verticalCenter: parent.verticalCenter
                                                height: 25
                                                anchors.right: parent.right
                                                anchors.rightMargin: 10
                                                text: qsTr("Fertig")
                                                onClicked:groupFlyout.close()
                                                transparent:true
                                            }
                                        }
                                    }
                                }
                            }
                        }


                        FieldCheckIndicator
                        {
                            index: reader.cardIndex
                            label: qsTr("Karten ID")
                            width:100
                            mandatory: true
                        }

                        Item
                        {
                            width:10
                            height:1
                        }

                        FieldCheckIndicator
                        {
                            id: balanceCheck
                            width: 100
                            index: reader.balanceIndex
                            label: qsTr("Guth.")
                            optional: true
                            onClicked: balanceFlyout.open()

                            FlyoutBox
                            {
                                id: balanceFlyout
                                parent: balanceCheck.buttonRect
                                onOpenedChanged: if(opened) balanceField.forceActiveFocus()
                                Row
                                {
                                    spacing: 10
                                    TextField
                                    {
                                        id: balanceField
                                        width: 65
                                        placeholderText:qsTr("Guthaben")
                                        anchors.verticalCenter: parent.verticalCenter
                                        field.validator: RegExpValidator { regExp:/^[-]?\d+([\.,]\d{2})?$/}
                                        field.horizontalAlignment:  Text.AlignRight
                                        onAccepted:
                                        {
                                            p.balance =  parseInt(balanceField.text.replace(",",".") * 100)
                                            balanceFlyout.close()
                                        }
                                    }
                                    TextLabel
                                    {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: "EUR"
                                        fontSize: Fonts.verySmallControlFontSize
                                        color: Colors.lightGrey
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    StandardButton
                                    {
                                        icon: Icons.check
                                        anchors.verticalCenter: parent.verticalCenter
                                        id: button
                                        onClicked:
                                        {
                                            p.balance =  parseInt(balanceField.text.replace(",",".") * 100)
                                            balanceFlyout.close()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle
                    {
                        Layout.fillWidth:true
                        height: 1
                        opacity: reader.count != 0 ? .2 : 0
                    }

                    ListView
                    {
                        id: list
                        clip:true
                        Layout.fillWidth:true
                        Layout.fillHeight:true
                        showScrollableIndication: true
                        width: parent.width



                        Column
                        {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -40
                            visible: reader.count == 0
                            spacing: 10

                            TextLabel
                            {
                                id: emptyHintLabel
                                text: qsTr("Klicke auf \"CSV öffnen\" um eine CSV Datei zu laden")
                                wrapMode: Text.Wrap
                                fontSize: Fonts.headerFontSze
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                opacity: .2

                            }

                            StandardButton
                            {
                                anchors.horizontalCenter: emptyHintLabel.horizontalCenter
                                text:qsTr("CSV öffnen")
                                onClicked: reader.readFromDialog()
                            }
                        }


                        delegate:
                            Item
                        {
                            height: 40
                            width: parent.width
                            Row
                            {
                                width: parent.width
                                spacing: 5
                                anchors.verticalCenter: parent.verticalCenter
                                property var delegateData: reader.getIndex(index)

                                TextLabel
                                {
                                    width: (120 / 720) * (layout.width-220)
                                    Layout.fillHeight: true
                                    text: parent.delegateData["user"]["surname"]
                                }
                                TextLabel
                                {
                                    Layout.fillHeight: true
                                    width: (120 / 720) * (layout.width-220)
                                    text: parent.delegateData["user"]["name"]
                                }
                                TextLabel
                                {
                                    Layout.fillHeight: true
                                    width:  (200 / 720) * (layout.width-220)
                                    opacity: .6
                                    text: parent.delegateData["user"]["mail"]
                                }
                                TextLabel
                                {
                                    Layout.fillHeight: true
                                    width:  (80 / 720) * (layout.width-220)
                                    text:
                                    {

                                        if(reader.courseIndex >= 0)
                                            return parent.delegateData["user"]["course"]

                                        if(p.course >= 0)
                                            return TypeDef.courses[p.course].name

                                        return ""
                                    }

                                }



                                TextLabel
                                {
                                    Layout.fillHeight: true
                                    width:  (100 / 720) * (layout.width-220)
                                    text:
                                    {
                                        if(reader.roleIndex >= 0)
                                            return parent.delegateData["user"]["role"]
                                        if(p.role >= 0)
                                            return TypeDef.roles[p.role].name
                                        return ""
                                    }
                                }

                                TextLabel
                                {
                                    Layout.fillHeight: true
                                    width:  (100 / 720) * (layout.width-220)
                                    text:
                                    {

                                        if(reader.groupIndex >= 0)
                                            return JSON.stringify(parent.delegateData["groups"])

                                        if(p.group >= 0)
                                            return p.groupObject.name
                                        return ""
                                    }
                                }

                                TextLabel
                                {
                                    Layout.fillHeight: true
                                    width:  100
                                    text: parent.delegateData["card"]["cardID"]
                                    font.family: Fonts.simplonMono
                                }

                                TextLabel
                                {
                                    Layout.fillHeight: true
                                    width: 50
                                    horizontalAlignment: Text.AlignRight
                                    text:
                                    {
                                        if(reader.balanceIndex >= 0)
                                            return (parent.delegateData["user"]["balance"]/ 100).toLocaleString(Qt.locale("de_DE"))

                                        if(p.balance >= 0)
                                            return (p.balance / 100).toLocaleString(Qt.locale("de_DE"))

                                        return ""
                                    }
                                }
                                TextLabel
                                {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "EUR"
                                    fontSize: Fonts.verySmallControlFontSize
                                    color: Colors.lightGrey
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
