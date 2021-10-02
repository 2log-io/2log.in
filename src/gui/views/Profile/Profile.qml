import QtQuick 2.5
import QtQuick.Controls 2.5
import UIControls 1.0
import QtQuick.Layouts 1.3
import AppComponents 1.0
import CloudAccess 1.0


ScrollViewBase
{
    id: docroot
    viewID: "profile"
    headline: qsTr("Mein Profil")

    Column
    {
        spacing: docroot.spacing
        width: parent.width
        ResetPasswordContainer
        {
            id: container
            onPasswordChanged:
            {
                console.log(code)
                if(success)
                {
                    feedbackOKDialog.open()
                }
                else
                {
                    feedbackErrorDialog.open()
                }
            }
        }

       LanguageContainer
       {
            width: parent.width/2
       }
    }


   Item
   {
        InfoDialog
        {
            id: feedbackOKDialog
            icon: Icons.warning2
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.highlightBlue
            text: qsTr("Passwort erfolgreich geändert!")
            StandardButton
            {
               text:"OK"
               onClicked: feedbackOKDialog.close()
            }
        }

        InfoDialog
        {
            id: feedbackErrorDialog
            icon: Icons.warning2
            anchors.centerIn: Overlay.overlay
            iconColor: Colors.warnRed
            text: qsTr("Falsches Passwort. Versuche es einfach noch einmal.")
            StandardButton
            {
               text:"OK"
               onClicked: feedbackErrorDialog.close()
            }
        }
    }

}
