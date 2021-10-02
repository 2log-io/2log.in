#ifndef LOGOVERVIEWMODEL_H
#define LOGOVERVIEWMODEL_H

#include <QObject>
#include "../quickhub-qmlclientmodule/src/Models/SynchronizedListLogic.h"
#include "../quickhub-qmlclientmodule/src/Models/ServiceModel.h"
#include <QQmlParserStatus>
#include <QDateTime>

class LogOverviewModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_INTERFACES(QQmlParserStatus)
    Q_OBJECT
    Q_PROPERTY(QString resourceID MEMBER _resourceID WRITE setResourceID NOTIFY resourceIDChanged)
    Q_PROPERTY(int visibleRange MEMBER _visibleRange WRITE setVisibleRange NOTIFY visibleRangeChanged)
    Q_PROPERTY(int bufferInSeconds MEMBER _cacheBuffer WRITE setCacheBuffer NOTIFY cacheBufferChanged)
    Q_PROPERTY(int currentPos MEMBER _currentPos WRITE setCurrentPos NOTIFY currentPosChanged)
    Q_PROPERTY(bool loading READ getLoading NOTIFY loadingChanged)
    Q_PROPERTY(QDateTime to MEMBER _to NOTIFY toChanged)
    Q_PROPERTY(QDateTime from MEMBER _from NOTIFY fromChanged)
    Q_PROPERTY(int count READ getCount NOTIFY countChanged)
    Q_PROPERTY(int logType READ getLogType WRITE setLogType NOTIFY logTypeChanged);

public:
    struct Frame
    {
        Frame(const QVariantList& result, int index)
        {
            _index = index;
            QListIterator<QVariant> it(result);
            while(it.hasNext())
            {
                QVariantMap map = it.next().toMap();
                _logs.insert(map["logID"].toString(), map);
            }
        }

        QStringList                 keys(){return _logs.keys();}
        QList<QVariantMap>          getLogs(){return _logs.values();}
        int                         getIndex(){return _index; }
        QMap<QString, QVariantMap> _logs;

        private:
            int _index = -1;
    };

//Ctor
    explicit LogOverviewModel(QObject *parent = nullptr);
//Dtor
    ~LogOverviewModel();

// QML API
    Q_INVOKABLE void setFrame(QDateTime from, QDateTime to);
                void setResourceID(const QString &resourceID);
                void setVisibleRange(int visibleRange);
                void setCacheBuffer(int bufferInSeconds);
                void setCurrentPos(int pos);
                bool getLoading() const;
                int getCount() const;

// QAbstractListModel
    virtual QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent) const override;

// QQmlParserStatus
    virtual void componentComplete() override;
    virtual void classBegin() override {}

    int getLogType() const;
    void setLogType(int logType);

private:
    void loadFrame(int idx);
    void fetchFrame(int idx);
    void displayFrame(Frame *frame);
    void hideFrame(int idx);
    void insertLog(QVariantMap log);
    void removeLog(QVariantMap log);

    QList<Frame>            _frames;
    ServiceModel*           _service = nullptr;
    SynchronizedListLogic*  _logic = nullptr;
    QSet<QString>           _store;

    mutable QHash<int, QByteArray> _roles;

    int             _currentPos = -1;
    int             _cacheBuffer = 1; //holds buffer to be preload around current window
    int             _visibleRange = 0; // in seconds
    QString         _resourceID;
    QDateTime       _from;
    QDateTime       _to;
    bool            _loading = false;
    int             _logType = 0;

    QMap<QString, QVariantMap> _data;
    QMap<QString, int> _responseIDMap;
    QMap<int, Frame*> _frameMap;

private slots:
    void itemAdded(int index, QVariant data);
    void answerReceived(QVariant data, QString id);

signals:
    void resourceIDChanged();
    void visibleRangeChanged();
    void cacheBufferChanged();
    void currentPosChanged();
    void loadingChanged();
    void toChanged();
    void fromChanged();
    void countChanged();
    void logTypeChanged();
};

#endif // LOGOVERVIEWMODEL_H
