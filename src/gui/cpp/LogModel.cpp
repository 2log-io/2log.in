#include "LogModel.h"
#include <QAbstractListModel>
#include <QJsonDocument>

LogOverviewModel::LogOverviewModel(QObject *parent) : QAbstractListModel(parent),
    _service(new ServiceModel(this)),
    _logic(new SynchronizedListLogic(this))
{ 
    _service->setService("lab");
    connect(_logic, &SynchronizedListLogic::itemAdded, this, &LogOverviewModel::itemAdded);
    connect(_service, &ServiceModel::answerReceived, this, &LogOverviewModel::answerReceived);
    _to = QDateTime::currentDateTime();
}

LogOverviewModel::~LogOverviewModel()
{
    qDeleteAll(_frameMap.begin(), _frameMap.end());
}


void LogOverviewModel::setResourceID(const QString &resourceID)
{
    _resourceID = resourceID;
}

QVariant LogOverviewModel::data(const QModelIndex &index, int role) const
{
    if(index.row() < _data.size())
    {
        QVariantMap map = _data.values().at(index.row());
        return map[roleNames().value(role)];
    }

    return QVariant();
}

QHash<int, QByteArray> LogOverviewModel::roleNames() const
{
    if(_data.count() > 0)
    {
        QVariantMap map = _data.first();
        if(_roles.count() == map.count())
        {
            return _roles;
        }

        for(int i = 0; i < map.keys().size(); i++)
        {
            QByteArray key =  map.keys().at(i).toLatin1();

            if(!_roles.values().contains(key))
                _roles.insert(_roles.count(), key);
        }
    }

    return _roles;
}

int LogOverviewModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return _data.count();
}

void LogOverviewModel::itemAdded(int index, QVariant data)
{
    Q_UNUSED(index);
    insertLog(data.toMap());
}

void LogOverviewModel::answerReceived(QVariant data, QString id)
{
    if(!_responseIDMap.contains(id))
        return;

    int idx = _responseIDMap.value(id);
    QVariantList list = data.toList();
    if(_frameMap.contains(idx))
        return;

    Frame* bunch = new Frame(list, idx);
    _frameMap.insert(idx, bunch);
    if(qAbs(_currentPos - idx) <= 1)
    {
        displayFrame(bunch);
    }
}


void LogOverviewModel::setFrame(QDateTime from, QDateTime to)
{



}
void LogOverviewModel::componentComplete()
{
    QVariantMap match;
    match["resourceID"] = _resourceID;
    match["logType"] = _logType;
    QVariantMap filterObj;
    filterObj["match"] = match;
    filterObj["limit"] = 1;
    QString filter = QJsonDocument::fromVariant(filterObj).toJson();
    _logic->setResource( "labcontrol/logs:" + filter);
    loadFrame(0);
    loadFrame(1);
}

void LogOverviewModel::loadFrame(int idx)
{
    if(_frameMap.contains(idx))
        displayFrame(_frameMap.value(idx));
    else
        fetchFrame(idx);
}

void LogOverviewModel::fetchFrame(int idx)
{
    if(_frameMap.contains(idx))
        return;

    QDateTime to = _to.addMSecs(-1 * idx * _visibleRange);
    QDateTime from = _to.addMSecs(-1 * (idx +1) * _visibleRange);
    QVariantMap filter;
    QVariantMap match;
    match["resourceID"] = _resourceID;
    match["logType"] = _logType;
    filter["match"] = match;
    filter["from"] = from;
    filter["to"] = to;
    QVariantMap data;
    data["filter"] = filter;

    _responseIDMap.insert(_service->call("getLogs", data), idx);
    _loading = true;
    Q_EMIT loadingChanged();
}

void LogOverviewModel::displayFrame(LogOverviewModel::Frame* frame)
{
    QMapIterator<QString, QVariantMap> it(frame->_logs);
    while(it.hasNext())
    {
        insertLog(it.next().value());
    }
}

void LogOverviewModel::hideFrame(int idx)
{
    Frame* frame = _frameMap.value(idx, nullptr);
    if(frame)
    {
        QMapIterator<QString, QVariantMap> it(frame->_logs);
        while(it.hasNext())
        {
            removeLog(it.next().value());
        }
    }
}

void LogOverviewModel::insertLog(QVariantMap log)
{
    QString logID = log["logID"].toString();
    int pos = std::distance(_data.begin(), _data.lowerBound(logID));
    beginInsertRows(QModelIndex(), pos, pos);
    _data.insert(logID, log);
    endInsertRows();
    Q_EMIT countChanged();
}

void LogOverviewModel::removeLog(QVariantMap log)
{
    QString logID = log["logID"].toString();
    if(!_data.contains(logID))
        return;

    int pos = std::distance(_data.begin(), _data.find(logID));
    beginRemoveRows(QModelIndex(), pos, pos);
    _data.remove(logID);
    endRemoveRows();
    Q_EMIT countChanged();
}

int LogOverviewModel::getLogType() const
{
    return _logType;
}

void LogOverviewModel::setLogType(int logType)
{
    _logType = logType;
    Q_EMIT logTypeChanged();
}

bool LogOverviewModel::getLoading() const
{
    return _loading;
}

int LogOverviewModel::getCount() const
{
    return _data.count();
}

void LogOverviewModel::setCacheBuffer(int bufferInSeconds)
{
    _cacheBuffer = bufferInSeconds;
    Q_EMIT cacheBufferChanged();
}

void LogOverviewModel::setCurrentPos(int pos)
{
    if(_currentPos == pos)
        return;

    if(pos - _currentPos == 1)
    {
        hideFrame(pos - 2);
        loadFrame(pos+1);
    }

    if(pos - _currentPos == -1)
    {
        hideFrame(pos+ 2);
        loadFrame(pos - 1);
    }

     _currentPos = pos;
    Q_EMIT currentPosChanged();
}


void LogOverviewModel::setVisibleRange(int visibleRange)
{
    _visibleRange = visibleRange;
    Q_EMIT cacheBufferChanged();
}
