/*
    Copyright 2018 Marco Martin <mart@kde.org>
    Copyright 2016 Aditya Mehra <aix.m@outlook.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.9
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.5 as Kirigami

Item {
    id: root
    width: Kirigami.Units.gridUnit * 5
    height: width

    state: "idle"
    states: [
        State {
            name: "idle"
            PropertyChanges {
                target: innerCircle
                rotation: 360
                graphicsColor: Kirigami.Theme.highlightedTextColor
            }
            PropertyChanges {
                target: root
                opacity: 0
            }
        },
        State {
            name: "waiting"
            PropertyChanges {
                target: innerCircle
                rotation: 0
                graphicsColor: Kirigami.Theme.highlightedTextColor
            }
            PropertyChanges {
                target: root
                opacity: 1
            }
        },
        State {
            name: "ok"
            PropertyChanges {
                target: innerCircle
                explicit: true
                rotation: -90
                graphicsColor: Kirigami.Theme.positiveTextColor
            }
        },
        State {
            name: "error"
            PropertyChanges {
                target: innerCircle
                explicit: true
                rotation: +90
                graphicsColor: Kirigami.Theme.negativeTextColor
            }
        }
    ]

    onStateChanged: outerCircleRotation.running = true;

MouseArea {
    anchors.fill:parent
    onClicked: {
        if (root.state == "waiting")
            root.state = "ok";
        else if (root.state == "ok")
            root.state = "error";
        else
            root.state = "waiting";
    }
}


    Rectangle {
        id: background
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        color: Kirigami.Theme.highlightColor
        radius: height
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
        }
    }
    Behavior on opacity {
        OpacityAnimator {
            duration: innerCircle.animationLength
            easing.type: Easing.InOutCubic
        }
    }

    Rectangle {
        id: innerCircleGraphics
        anchors {
            fill: outerCircle
            margins: Kirigami.Units.smallSpacing * 4
        }
        visible: false

        color: innerCircle.graphicsColor
        radius: width
    }
    Item {
        id: innerCircleMask
        visible: false
        anchors.fill: innerCircleGraphics

        Rectangle {
            anchors {
                left: parent.left
                right: parent.horizontalCenter
                top: parent.top
                bottom: parent.bottom
            }
            color: "white"
        }
    }
    OpacityMask {
        id: innerCircle
        property color graphicsColor
        property int animationLength: 1000
        Behavior on graphicsColor {
            ColorAnimation {
                duration: innerCircle.animationLength
                easing.type: Easing.InOutCubic
            }
        }
        anchors.fill: innerCircleGraphics
        source: innerCircleGraphics
        maskSource: innerCircleMask
        Behavior on rotation {
            RotationAnimator {
                direction: RotationAnimator.Counterclockwise
                duration: innerCircle.animationLength
                easing.type: Easing.InOutCubic
            }
        }
    }

    Item {
        id: outerCircle

        anchors {
            fill: parent
            margins: Kirigami.Units.largeSpacing
        }

        // the little dot
        Rectangle {
            width: Kirigami.Units.smallSpacing * 2
            height: width
            radius: width
            color: innerCircle.graphicsColor
            anchors.horizontalCenter : parent.horizontalCenter
        }
        //the circle
        Rectangle {
            anchors {
                fill: parent
                margins: Kirigami.Units.smallSpacing * 3
            }
            radius: width
            color: "transparent"
            border.width: Kirigami.Units.devicePixelRatio * 2
            border.color: innerCircle.graphicsColor
        }
        RotationAnimator {
            id: outerCircleRotation
            target: outerCircle
            from: 0
            to: 360
            alwaysRunToEnd: true
            direction: RotationAnimator.Clockwise
            duration: innerCircle.animationLength
            easing.type: Easing.InOutCubic
        }
    }
    Timer {
        id: fadeTimer
        interval: 3000
        running: root.state == "ok" || root.state == "error"
        repeat: false
        onTriggered: root.state = "idle"
    }
}
