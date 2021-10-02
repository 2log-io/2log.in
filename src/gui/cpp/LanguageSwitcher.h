#ifndef LANGUAGESWITCHER_H
#define LANGUAGESWITCHER_H

#include <QObject>
#include <QTranslator>
#include <QQmlEngine>
#include <QMap>
#include <QTranslator>

class LanguageSwitcher : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString currentLanguage READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString dummy READ dummy NOTIFY dummyChanged)
    Q_PROPERTY(QStringList supportedLanguages READ languages NOTIFY languagesChanged)


public:
    Q_INVOKABLE void retranslate();
    explicit LanguageSwitcher(QQmlEngine* engine, QObject *parent = nullptr);

    QString language() const;
    void setLanguage(const QString &language);

    QString dummy() const;
    QStringList languages() const;

private:
    QString _language;
    QTranslator _translator;
    QStringList findQmFiles();
    QString languageName(const QString &qmFile);
    QMap<QString, QString> _qmFiles;
    QMap<QString, QTranslator*> _translators;
    QQmlEngine* _engine = nullptr;


signals:
    void languageChanged();
    void dummyChanged();
    void languagesChanged();
};

#endif // LANGUAGESWITCHER_H
