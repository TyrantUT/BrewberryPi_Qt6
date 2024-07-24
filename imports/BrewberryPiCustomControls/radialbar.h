/**
  ******************************************************************************
  * File Name          : radialbar.h
  * Description        : Radial Bar widget
  ******************************************************************************
  * @attention
**/

#ifndef RADIALBAR_H
#define RADIALBAR_H

#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickPaintedItem>
#include <QtGui/QPainter>
#include <QtGui/QPainterPath>


class RadialBar : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(qreal size READ getSize WRITE setSize NOTIFY sizeChanged)
    Q_PROPERTY(qreal startAngle READ getStartAngle WRITE setStartAngle NOTIFY startAngleChanged)
    Q_PROPERTY(qreal spanAngle READ getSpanAngle WRITE setSpanAngle NOTIFY spanAngleChanged)
    Q_PROPERTY(qreal minValue READ getMinValue WRITE setMinValue NOTIFY minValueChanged)
    Q_PROPERTY(qreal maxValue READ getMaxValue WRITE setMaxValue NOTIFY maxValueChanged)
    Q_PROPERTY(qreal value READ getValue WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(qreal pointValue READ getPointValue WRITE setPointValue NOTIFY pointValueChanged)
    Q_PROPERTY(int dialWidth READ getDialWidth WRITE setDialWidth NOTIFY dialWidthChanged)
    Q_PROPERTY(QColor backgroundColor READ getBackgroundColor WRITE setBackgroundColor NOTIFY backgroundColorChanged)
    Q_PROPERTY(QColor foregroundColor READ getForegroundColor WRITE setForegroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(QColor progressColor READ getProgressColor WRITE setProgressColor NOTIFY progressColorChanged)
    Q_PROPERTY(QColor setPointTextColor READ getSetPointTextColor WRITE setSetPointTextColor NOTIFY setPointTextColorChanged)
    Q_PROPERTY(QColor setPointBarColor READ getSetPointBarColor WRITE setSetPointBarColor NOTIFY setPointBarColorChanged)
    Q_PROPERTY(QColor textColor READ getTextColor WRITE setTextColor NOTIFY textColorChanged)
    Q_PROPERTY(QString suffixText READ getSuffixText WRITE setSuffixText NOTIFY suffixTextChanged)
    Q_PROPERTY(bool showText READ isShowText WRITE setShowText NOTIFY showTextChanged)
    Q_PROPERTY(bool showPointText READ isShowPointText WRITE setShowPointText NOTIFY pointTextChanged)
    Q_PROPERTY(Qt::PenCapStyle penStyle READ getPenStyle WRITE setPenStyle NOTIFY penStyleChanged)
    Q_PROPERTY(DialType dialType READ getDialType WRITE setDialType NOTIFY dialTypeChanged)
    Q_PROPERTY(QFont textFont READ getTextFont WRITE setTextFont NOTIFY textFontChanged)

public:
    RadialBar(QQuickItem *parent = 0);
    void paint(QPainter *painter);

    enum DialType {
        FullDial,
        MinToMax,
        NoDial
    };
    Q_ENUM(DialType)

    qreal getSize() {return m_Size;}
    qreal getStartAngle() {return m_StartAngle;}
    qreal getSpanAngle() {return m_SpanAngle;}
    qreal getMinValue() {return m_MinValue;}
    qreal getMaxValue() {return m_MaxValue;}
    qreal getValue() {return m_Value;}
    qreal getPointValue() {return m_PointValue;}
    int getDialWidth() {return m_DialWidth;}
    QColor getBackgroundColor() {return m_BackgroundColor;}
    QColor getForegroundColor() {return m_DialColor;}
    QColor getProgressColor() {return m_ProgressColor;}
    QColor getSetPointTextColor() {return m_SetPointTextColor;}
    QColor getSetPointBarColor() {return m_SetPointBarColor;}
    QColor getTextColor() {return m_TextColor;}
    QString getSuffixText() {return m_SuffixText;}
    bool isShowText() {return m_ShowText;}
    bool isShowPointText() {return m_ShowPointText;}
    Qt::PenCapStyle getPenStyle() {return m_PenStyle;}
    DialType getDialType() {return m_DialType;}
    QFont getTextFont() {return m_TextFont;}

    void setSize(qreal size);
    void setStartAngle(qreal angle);
    void setSpanAngle(qreal angle);
    void setMinValue(qreal value);
    void setMaxValue(qreal value);
    void setValue(qreal value);
    void setPointValue(qreal value);
    void setDialWidth(qreal width);
    void setBackgroundColor(QColor color);
    void setForegroundColor(QColor color);
    void setProgressColor(QColor color);
    void setSetPointTextColor(QColor color);
    void setSetPointBarColor(QColor color);
    void setTextColor(QColor color);
    void setSuffixText(QString text);
    void setShowText(bool show);
    void setShowPointText(bool show);
    void setPenStyle(Qt::PenCapStyle style);
    void setDialType(DialType type);
    void setTextFont(QFont font);

signals:
    void sizeChanged();
    void startAngleChanged();
    void spanAngleChanged();
    void minValueChanged();
    void maxValueChanged();
    void valueChanged();
    void pointValueChanged();
    void dialWidthChanged();
    void backgroundColorChanged();
    void foregroundColorChanged();
    void progressColorChanged();
    void setPointTextColorChanged();
    void setPointBarColorChanged();
    void textColorChanged();
    void suffixTextChanged();
    void showTextChanged();
    void pointTextChanged();
    void penStyleChanged();
    void dialTypeChanged();
    void textFontChanged();

private:
    qreal m_Size;
    qreal m_StartAngle;
    qreal m_SpanAngle;
    qreal m_MinValue;
    qreal m_MaxValue;
    qreal m_Value;
    qreal m_PointValue;
    int m_DialWidth;
    QColor m_BackgroundColor;
    QColor m_DialColor;
    QColor m_ProgressColor;
    QColor m_SetPointTextColor;
    QColor m_SetPointBarColor;
    QColor m_TextColor;
    QString m_SuffixText;
    bool m_ShowText;
    bool m_ShowPointText;
    Qt::PenCapStyle m_PenStyle;
    DialType m_DialType;
    QFont m_TextFont;
};

#endif // RADIALBAR_H
