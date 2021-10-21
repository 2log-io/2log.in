import QtQuick 2.5
import CloudAccess 1.0
import UIControls 1.0
ListView
{

    id: docroot
    property string selectedUser
    signal userClicked(string userID, string userName)
    property bool showImages: true
    property bool showBalance: true
    showScrollableIndication: true
    cacheBuffer: 2000
    delegate:
    UserTableDelegate
    {
        _balance: balance
        _name: name
        _email: mail
        showBalance: docroot.showBalance
        showGravatarImage: docroot.showImages
        _surname: surname
        onClicked: {docroot.selectedUser = uuid; docroot.userClicked(uuid, name+" "+surname)}
    }

    maximumFlickVelocity: 1000
    boundsBehavior: Flickable.DragOverBounds
}
