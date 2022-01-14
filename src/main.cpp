#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtDebug>
#include <QQmlContext>
#include <QProcessEnvironment>
#include <QTranslator>

#include "InitQuickHub.h"
#include "LineChart.h"
#include "DottedLine.h"
#include "Init2logQMLComponents.h"
#include "Init2logQMLControls.h"
#include "InitPlatformAbstraction.h"
#include "CppHelper.h"
#include "LanguageSwitcher.h"
#include "ISleepAvoider.h"
#include "LogModel.h"

#if defined(Q_OS_ANDROID)
    #include "NFCReader.h"
    #include "android/src/SleepAvoider.h"
    #include <QtAndroid>
#elif defined(Q_OS_IOS)
    #include "NFCReader.h"
    #include "ios/src/Notch.h"
    #include "ios/src/PermissionRequester.h"
    #include "ios/src/SleepAvoider.h"
    #include "ios/src/QtAppDelegate-C-Interface.h"
#endif

#if defined(Q_OS_HTML5) or defined(Q_OS_WASM) or defined(__EMSCRIPTEN__)
    #define PLATFORM_WASM
#endif


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setOrganizationName("2log");
    QCoreApplication::setOrganizationDomain("2log.io");
    QCoreApplication::setApplicationName("2log Control");
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    LanguageSwitcher* switcher = new LanguageSwitcher(&engine);
    InitQuickHub::registerTypes("CloudAccess");
    Init2logQMLComponents::registerTypes("AppComponents", &engine);
    Init2logQMLControls::registerTypes("UIControls", &engine);
    ProvisioningModule::registerTypes("DeviceProvisioning");
    qmlRegisterType<LogOverviewModel>("AppComponents", 1, 0, "LogModel");

    engine.addImportPath(":/");

    qDebug() << QProcessEnvironment::systemEnvironment().toStringList();
    QString url = QProcessEnvironment::systemEnvironment().value("SERVER_URL","");

    CppHelper* keyHandler = new CppHelper(qApp);
    qApp->installEventFilter(keyHandler);
    engine.rootContext()->setContextProperty("cppHelper",keyHandler);

    #if defined(Q_OS_ANDROID)
        NFCReader* reader =  new NFCReader();
        engine.rootContext()->setContextProperty("nfcReader",reader);
        engine.rootContext()->setContextProperty("isMobile",true);
        engine.rootContext()->setContextProperty("sleepAvoider",new SleepAvoider(qApp));

        QtAndroid::runOnAndroidThread([=]()
        {
            QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
            window.callMethod<void>("addFlags", "(I)V", 0x80000000);
            window.callMethod<void>("clearFlags", "(I)V", 0x04000000);
            window.callMethod<void>("setStatusBarColor", "(I)V", 0xff202428); // Desired statusbar color
            window.callMethod<void>("setNavigationBarColor", "(I)V", 0xff202428); // Desired statusbar color
        });
    #elif defined(Q_OS_IOS)
        NFCReader* reader =  new NFCReader();
        engine.rootContext()->setContextProperty("nfcReader",reader);
        engine.rootContext()->setContextProperty("isMobile",true);
        Notch();
        PermissionRequester requester;
        requester.requestPermissions();
        engine.rootContext()->setContextProperty("sleepAvoider",new SleepAvoider(qApp));
    #else
        engine.rootContext()->setContextProperty("isMobile",false);
        engine.rootContext()->setContextProperty("sleepAvoider",new ISleepAvoider(qApp));
    #endif

    #ifndef WEB_ASSEMBLY
        engine.rootContext()->setContextProperty("webAssembly",false);
    #else
        engine.rootContext()->setContextProperty("webAssembly",true);
    #endif

    engine.rootContext()->setContextProperty("csvReader", new CSVReader(&engine));

     engine.rootContext()->setContextProperty("languageSwitcher", switcher);
    engine.rootContext()->setContextProperty("serverURL",url);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
