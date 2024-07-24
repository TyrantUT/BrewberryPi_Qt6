/**
  ******************************************************************************
  * File Name          : radialbar.cpp
  * Description        : Radial Bar widget class
  ******************************************************************************
  * @attention
**/
#include "radialbar.h"

RadialBar::RadialBar(QQuickItem *parent)
    : QQuickPaintedItem(parent),
    m_Size(200),
    m_StartAngle(40),
    m_SpanAngle(280),
    m_MinValue(0),
    m_MaxValue(100),
    m_Value(50),
    m_PointValue(0),
    m_DialWidth(15),
    m_BackgroundColor(Qt::transparent),
    m_DialColor(QColor(80,80,80)),
    m_ProgressColor(QColor(135,26,5)),
    m_SetPointTextColor(QColor(255,255,255)),
    m_SetPointBarColor(QColor(255, 255, 255)),
    m_TextColor(QColor(0, 0, 0)),
    m_SuffixText(""),
    m_ShowText(true),
    m_ShowPointText(true),
    m_PenStyle(Qt::FlatCap),
    m_DialType(DialType::MinToMax)
{
    setWidth(200);
    setHeight(200);
    setSmooth(true);
    setAntialiasing(true);
}

void RadialBar::paint(QPainter *painter) {
    double startAngle;
    double spanAngle;
    qreal size = qMin(this->width(), this->height());
    setWidth(size);
    setHeight(size);
    QRectF rect = this->boundingRect();

    // Adjust boundingRect for additional line width on the progress bar
    rect.adjust(0 + (m_DialWidth + 2),
                0 + (m_DialWidth + 2),
                -(m_DialWidth - 2),
                -(m_DialWidth - 2));

    painter->setRenderHint(QPainter::Antialiasing);
    QPen pen = painter->pen();
    pen.setCapStyle(m_PenStyle);
    startAngle = -90 - m_StartAngle;

    if (FullDial != m_DialType) {
        spanAngle = 0 - m_SpanAngle;
    }
    else {
        spanAngle = -360;
    }

    //Draw outer dial
    painter->save();
    pen.setWidth(m_DialWidth);
    pen.setColor(m_DialColor);
    painter->setPen(pen);
    qreal offset = m_DialWidth / 2;

    if (m_DialType == MinToMax) {
        painter->drawArc(rect.adjusted(offset, offset, -offset, -offset), startAngle * 16, spanAngle * 16);
    }
    else if(m_DialType == FullDial) {
        painter->drawArc(rect.adjusted(offset, offset, -offset, -offset), -90 * 16, -360 * 16);
    }
    else {
        //do not draw dial
    }

    painter->restore();

    //Draw background
    painter->save();
    painter->setBrush(m_BackgroundColor);
    painter->setPen(m_BackgroundColor);
    qreal inner = offset * 2;
    painter->drawEllipse(rect.adjusted(inner, inner, -inner, -inner));
    painter->restore();

    //Draw progress text with suffix
    painter->save();
    painter->setFont(m_TextFont);
    pen.setColor(m_TextColor);
    painter->setPen(pen);

    if (m_ShowText) {
        // TODO: Set new font pixel size and color
        painter->drawText(rect.adjusted(offset, offset - 75, -offset, -offset - 75), Qt::AlignCenter, "Current");
        painter->drawText(rect.adjusted(offset, offset - 25, -offset, -offset - 25), Qt::AlignCenter,QString::number(m_Value, 'f', 1) + m_SuffixText);
    }
    else {
        painter->drawText(rect.adjusted(offset, offset, -offset, -offset), Qt::AlignCenter, m_SuffixText);
    }

    painter->restore();

    //Draw Setpoint text
    painter->save();
    painter->setFont(m_TextFont);
    pen.setColor(m_SetPointTextColor);
    painter->setPen(pen);

    if (m_ShowPointText) {
        painter->drawText(rect.adjusted(offset, offset + 25, -offset, -offset + 25), Qt::AlignCenter, QString::number(m_PointValue, 'f', 1) + m_SuffixText);
    }
    else {
        painter->drawText(rect.adjusted(offset, offset + 25, -offset, -offset + 25), Qt::AlignCenter, NULL);
    }

    painter->restore();

    //Draw setpoint bar
    painter->save();
    pen.setWidth(m_DialWidth);
    pen.setColor(m_SetPointBarColor);
    qreal pointValueAngle = ((m_PointValue - m_MinValue)/(m_MaxValue - m_MinValue)) * spanAngle;
    painter->setPen(pen);
    painter->drawArc(rect.adjusted(offset, offset, -offset, -offset), startAngle * 16, pointValueAngle * 16);
    painter->restore();

    //Draw progress bar
    painter->save();
    QConicalGradient gradient;
    gradient.setCenter(rect.center());
    gradient.setAngle(270);
    gradient.setColorAt(0, QColor(255, 0, 0));
    gradient.setColorAt(1, QColor(0, 0, 255));

    QPen progressPen(QBrush(gradient), m_DialWidth);
    progressPen.setCapStyle(m_PenStyle);

    qreal valueAngle = ((m_Value - m_MinValue)/(m_MaxValue - m_MinValue)) * spanAngle;  //Map value to angle range
    painter->setPen(progressPen);
    painter->drawArc(rect.adjusted(offset, offset, -offset, -offset), startAngle * 16, valueAngle * 16);
    painter->restore();

    // Draw Inner Circle
    painter->save();
    qreal inner2 = offset * 16;
    pen.setColor(QColor(0, 0, 255, 127));
    painter->setPen(pen);
    painter->drawArc(rect.adjusted(inner2, inner2, -inner2, -inner2), startAngle * 16, spanAngle * 16);
    painter->restore();
}


void RadialBar::setSize(qreal size) {
    if (m_Size == size)
        return;
    m_Size = size;

    emit sizeChanged();
}

void RadialBar::setStartAngle(qreal angle) {
    if (m_StartAngle == angle)
        return;
    m_StartAngle = angle;

    emit startAngleChanged();
}

void RadialBar::setSpanAngle(qreal angle) {
    if (m_SpanAngle == angle)
        return;
    m_SpanAngle = angle;

    emit spanAngleChanged();
}

void RadialBar::setMinValue(qreal value) {
    if (m_MinValue == value)
        return;
    m_MinValue = value;

    emit minValueChanged();
}

void RadialBar::setMaxValue(qreal value) {
    if (m_MaxValue == value)
        return;
    m_MaxValue = value;

    emit maxValueChanged();
}

void RadialBar::setValue(qreal value) {
    if (m_Value == value)
        return;
    m_Value = value;
    update();   //update the radialbar

    emit valueChanged();
}

void RadialBar::setPointValue(qreal value) {
    if (m_PointValue == value)
        return;
    m_PointValue = value;
    update();

    emit pointValueChanged();
}

void RadialBar::setDialWidth(qreal width) {
    if (m_DialWidth == width)
        return;
    m_DialWidth = width;

    emit dialWidthChanged();
}

void RadialBar::setBackgroundColor(QColor color) {
    if (m_BackgroundColor == color)
        return;
    m_BackgroundColor = color;

    emit backgroundColorChanged();
}

void RadialBar::setForegroundColor(QColor color) {
    if (m_DialColor == color)
        return;
    m_DialColor = color;

    emit foregroundColorChanged();
}

void RadialBar::setProgressColor(QColor color) {
    if (m_ProgressColor == color)
        return;
    m_ProgressColor = color;

    emit progressColorChanged();
}

void RadialBar::setSetPointTextColor(QColor color) {
    if (m_SetPointTextColor == color)
        return;
    m_SetPointTextColor = color;

    emit setPointTextColorChanged();
}

void RadialBar::setSetPointBarColor(QColor color) {
    if (m_SetPointBarColor == color)
        return;
    m_SetPointBarColor = color;

    emit setPointBarColorChanged();
}

void RadialBar::setTextColor(QColor color) {
    if (m_TextColor == color)
        return;
    m_TextColor = color;

    emit textColorChanged();
}

void RadialBar::setSuffixText(QString text) {
    if (m_SuffixText == text)
        return;
    m_SuffixText = text;

    emit suffixTextChanged();
}

void RadialBar::setShowText(bool show) {
    if (m_ShowText == show)
        return;
    m_ShowText = show;
}

void RadialBar::setShowPointText(bool show) {
    if (m_ShowPointText == show)
        return;
    m_ShowPointText = show;

    emit pointTextChanged();
}

void RadialBar::setPenStyle(Qt::PenCapStyle style) {
    if (m_PenStyle == style)
        return;
    m_PenStyle = style;

    emit penStyleChanged();
}

void RadialBar::setDialType(RadialBar::DialType type) {
    if (m_DialType == type)
        return;
    m_DialType = type;

    emit dialTypeChanged();
}

void RadialBar::setTextFont(QFont font) {
    if (m_TextFont == font)
        return;
    m_TextFont = font;

    emit textFontChanged();
}
