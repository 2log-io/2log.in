import QtQuick 2.14
import CloudAccess 1.0
import UIControls 1.0
ListView
{

    id: docroot
    property string selectedProduct
    signal productClicked(string productID, string productName)
    signal productDeleted(int index)
    signal priceChanged(int index, int price)
    signal categoryChanged(int index, string category)
    signal flatrateCategoryChanged(int index, string category)
    signal accountingCodeChanged(int index, string accountingCode)

    property var categories
    property var flatrateCategories
    property var accountingCodes

    maximumFlickVelocity: 800
    showScrollableIndication: true
    cacheBuffer: 2000
    keyNavigationEnabled: false
    delegate:

    ProductTableDelegate
    {
        price: model.price
        name: model.name
        categories: docroot.categories
        flatrateCategories: docroot.flatrateCategories
        category: model.category
        flatrateCategory: model.flatrateCategory
        //onClicked: {docroot.selectedProduct = uuid; docroot.productClicked(uuid, name+" "+surname)}
        onDeleteItem: docroot.productDeleted(idx)
        onPriceEdited:
        { docroot.priceChanged(idx, price);}
        accountingCodes: docroot.accountingCodes
        onCategoryEdited: docroot.categoryChanged(idx, category)
        onFlatrateCategoryEdited: docroot.flatrateCategoryChanged(idx, category)
        onAccountingCodeEdited: docroot.accountingCodeChanged(idx, category)
        accountingCode: model.accountingCode
    }
    onSelectedProductChanged: console.log(selectedProduct )
}
