import QtQuick 2.5
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.12
import UIControls 1.0
import CloudAccess 1.0
import AppComponents 1.0


ViewBase
{
    id: docroot

    viewID: "payment_sales"
    headline: qsTr("Sales")

   PaymentSalesStatistics
   {
        anchors.fill: parent
   }

}
