#include "LanguageSwitcher.h"
#include <QCoreApplication>
#include <QLocale>
#include <QDir>
#include <QDebug>
#include <QProcess>

void LanguageSwitcher::retranslate()
{
    _engine->retranslate();
}

LanguageSwitcher::LanguageSwitcher(QQmlEngine* engine, QObject *parent) : QObject(parent),
    _engine(engine)
{
    tr("Deutsch", "Translate to language name");
    _qmFiles.insert("Deutsch", "");
    const QStringList qmFiles = findQmFiles();
    for (int i = 0; i < qmFiles.size(); ++i)
    {
        const QString &qmlFile = qmFiles.at(i);
        QString name = languageName(qmlFile);
        _qmFiles.insert(name, qmlFile);
    }
}

QString LanguageSwitcher::language() const
{
    return _language;
}

void LanguageSwitcher::setLanguage(const QString &language)
{

    qDebug()<<language;
    if(_language == language)
        return;

    QTranslator* oldTranslator = _translators.value(_language, nullptr);
    if(oldTranslator)
    {
        _translators.remove(_language);
        QCoreApplication::removeTranslator(oldTranslator);
        delete oldTranslator;
        oldTranslator = nullptr;
        qDebug()<<"remove";
    }

    QString qmFile = _qmFiles.value(language);
    if(!qmFile.isEmpty())
    {
        QTranslator* translator = new QTranslator();
        if(translator->load(qmFile))
        {
            QCoreApplication::installTranslator(translator);
            _translators.insert(language, translator);
            Q_EMIT languagesChanged();
            Q_EMIT dummyChanged();
            qDebug()<<"install";
        }
        else
        {
            qDebug()<<"delete";
            delete translator;
            translator = nullptr;
        }
    }

    _language = language;
   // _engine->retranslate();
}

QString LanguageSwitcher::dummy() const
{
    return "";
}

QStringList LanguageSwitcher::languages() const
{
    return _qmFiles.keys();
}

QString LanguageSwitcher::languageName(const QString &qmFile)
{
    QTranslator translator;
    translator.load(qmFile);

    return translator.translate("LanguageSwitcher", "Deutsch");
}

QStringList LanguageSwitcher::findQmFiles()
{
    QDir dir(":/translations");
    QStringList fileNames = dir.entryList(QStringList("*.qm"), QDir::Files,
                                          QDir::Name);
    for (QString &fileName : fileNames)
        fileName = dir.filePath(fileName);
    return fileNames;
}
