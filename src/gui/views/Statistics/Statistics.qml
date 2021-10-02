import QtQuick 2.5
import UIControls 1.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import CloudAccess 1.0
import AppComponents 1.0
import "../Overview"

ScrollViewBase
{
    id: docroot

    viewID: "statistics"
    headline: qsTr("Statistik")


    Column
    {
        width: parent.width
        spacing: docroot.spacing

        UserStatisticContainer
        {

            id: userContainer
            model: revenueContainer.statisticModel
        }

        RevenueStatisticContainer
        {
            id: revenueContainer
        }

        OverviewContainer
        {

        }

    }
}
