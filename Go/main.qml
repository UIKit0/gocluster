// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import nobdy 0.1
import QtMobility.location 1.2

Rectangle {
    id: container
    width: 1200
    height: 640
    color: "black"

    property double heading: headingStream.value
    property double rpmValue: rpm.value

    NobdyStream {
        id: rpm
        request: VehicleData.EngineRPM
    }

    NobdyStream {
        id: velocity
        request: VehicleData.Velocity
        sourceFilter: "obd2"
    }

    NobdyStream {
        id: engineCoolant
        request: VehicleData.EngineCoolantTemp
    }

    NobdyStream {
        id: headingStream
        request: VehicleData.Heading
    }

    NobdyStream {
        id: latitudeStream
        request: VehicleData.Latitude
    }

    NobdyStream {
        id: longitudeStream
        request: VehicleData.Longitude
    }

    NobdyStream {
        id: troubleCodeStream
        request: VehicleData.DiagnosticTroubleCodes
    }

    Rectangle {
        id: mapScreen
        width: 1200
        height: 640
        color: "black"

        anchors.right: guageScreen.left

        Map {
            id: map
            plugin: Plugin { name: "nokia" }
            anchors.fill: parent
            size.width: parent.width
            size.height: parent.height
            zoomLevel: 20
            center: Coordinate { latitude: latitudeStream.value; longitude: longitudeStream.value }

            MapCircle {
                     id: myPosition
                     color: "blue"
                     radius: 2
                     center: Coordinate { latitude: latitudeStream.value; longitude: longitudeStream.value }
                 }
        }

        Column {
            width: 70
            spacing: 10
            Button {
                width: 70
                title.text: "+"
                title.font.pixelSize: 40
                onClicked: {
                    map.zoomLevel++;
                }
            }

            Button {
                width: 70
                title.text: "-"
                title.font.pixelSize: 40
                onClicked: {
                    map.zoomLevel--;
                }
            }
        }

        Button {
            id: guageScreenButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 100
            title.text: ">"
            title.font.pixelSize: 40
            onClicked: {
                guageScreen.x = 0
            }
        }

    }

    Rectangle {
        id: guageScreen
        width: 1200
        height: 640
        color: "black"

        Behavior on x {
            NumberAnimation { duration: 500 }
        }

        Image {
            id: mainGaugeBackground
            source: "assets/dial-main-bg.png"

            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit

            Rectangle {
                id: rpmNeedle
                visible: rpm.supported
                width: 15
                height: parent.height / 2 - 10
                radius: 10
                x: parent.width / 2
                y: parent.height / 2
                color: "#E89820"
                transform: Rotation {
                    origin.x: rpmNeedle.width / 2
                    origin.y: 0
                    angle: container.rpmValue > 10000 ? 360:(container.rpmValue / 10000 * 180) + 180

                    Behavior on angle {
                        //NumberAnimation { duration: 500 }
                        SpringAnimation { spring: 2; damping: 0.2 }
                    }
                }

            }

            Rectangle {
                id: coolantNeedle
                width: 7
                visible: engineCoolant.supported
                height: parent.height / 2
                radius: 10
                x: parent.width / 2
                y: parent.height / 2
                color: "white"
                transform: Rotation {
                    origin.x: coolantNeedle.width / 2
                    origin.y: 0
                    angle: engineCoolant.value > 165 ? (165/280 * 70 + 90):(engineCoolant.value / 180 * 70) + 90

                    Behavior on angle {
                        //NumberAnimation { duration: 500 }
                        SpringAnimation { spring: 2; damping: 0.2 }
                    }
                }

            }

            Image {
                id: centerImage
                source: "assets/dial-main-center-bg.png"
                anchors.centerIn: parent

                Text {
                    id: velocityText
                    anchors.centerIn: parent
                    text: Math.floor(velocity.value)
                    height: paintedHeight
                    verticalAlignment: Text.AlignBottom
                    font.pixelSize: 90
                    color: "white"
                }

                Text {
                    id: velocityUnits
                    anchors.left: velocityText.right
                    text: "kph"
                    font.pixelSize: 30
                    color: "white"
                    anchors.verticalCenter: parent.verticalCenter
                    height: velocityText.height
                    verticalAlignment: Text.AlignBottom
                }
            }

        }

        Image {
            id: headingImage
            source: "assets/dial-main-secondary-bg.png"
            anchors.top: parent.verticalCenter
            x: mainGaugeBackground.x - 53

            Text {
                text: {
                    if(container.heading > 315 && (container.heading > 0 && container.heading < 45))
                        return "N";
                    else if(container.heading <= 315 && container.heading > 225)
                        return "W";
                    else if(container.heading < 225 && container.heading > 135)
                        return "S";
                    else if(container.heading >= 45 && container.heading <= 135)
                        return "E";

                    return "?";
                }

                font.pixelSize: 90
                anchors.centerIn: parent
                color: "white"
            }
        }

        Button {
            id: configureButton
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 100
            Column {
                y: parent.height / 5
                spacing: parent.height / 8
                width: parent.width

                Repeater {
                    model: 3

                    Rectangle {
                        width: parent.width - 20
                        height: configureButton.height / 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.75
                        color: "black"
                        radius: 1

                    }
                }
            }
        }

        Button {
            id: mapsButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 100
            title.text: "<"
            title.font.pixelSize: 40

            onClicked: guageScreen.x = guageScreen.width
        }

        Button {
            id: checkEngine
            title.text: "Check engine"
            title.color: "red"
            width: 200
           // visible: troubleCodeStream.value.count
        }
    }

    Loader {
        id: topPageLoader
    }

    Component {
        id: troubleCodesComponent
        Rectangle {
            id: troubleCodes
            width: 1200
            height: 640
            color: "black"

            TroubleCodes {  }

        }
    }
}