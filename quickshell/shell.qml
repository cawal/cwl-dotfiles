// Barra lateral de teste — Quickshell + Qtile (X11)
// Lê o group atual via EWMH (_NET_CURRENT_DESKTOP com xprop) e troca de
// group chamando o proprio qtile. Groups fixos batendo com o config.py.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    PanelWindow {
        id: bar

        // Grude na esquerda ocupando a altura toda.
        anchors {
            top: true
            bottom: true
            left: true
        }

        implicitWidth: 56
        // Reserva o espaco na tela (janelas tiled nao ficam por baixo).
        // Troque para 0 se quiser testar como overlay flutuante.
        exclusiveZone: 56

        color: "#1e1e2e"

        // Groups do seu config.py, na mesma ordem (indice = _NET_CURRENT_DESKTOP).
        property var groups: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        property int current: -1

        // --- Polling do group atual via EWMH ---
        Process {
            id: currentProc
            command: ["xprop", "-root", "_NET_CURRENT_DESKTOP"]
            stdout: StdioCollector {
                onStreamFinished: {
                    // Ex: "_NET_CURRENT_DESKTOP(CARDINAL) = 2"
                    var m = text.match(/= *(\d+)/)
                    if (m) bar.current = parseInt(m[1])
                }
            }
        }

        Timer {
            interval: 200
            running: true
            repeat: true
            onTriggered: currentProc.running = true
        }

        // Troca de group chamando o qtile.
        Process { id: switchProc }
        function goToGroup(name) {
            switchProc.command = ["qtile", "cmd-obj", "-o", "group", name, "-f", "toscreen"]
            switchProc.running = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            spacing: 6

            // Logo / cabecalho
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "λ"
                color: "#cba6f7"
                font.pixelSize: 20
                font.bold: true
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 32; height: 1
                color: "#585b70"
            }

            // Botoes de group (workspaces reais)
            Repeater {
                model: bar.groups
                Rectangle {
                    required property int index
                    required property string modelData

                    Layout.alignment: Qt.AlignHCenter
                    width: 40; height: 40
                    radius: 8

                    property bool active: bar.current === index

                    color: active ? "#cba6f7"
                         : gMouse.containsMouse ? "#45475a"
                         : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: parent.active ? "#1e1e2e" : "#cdd6f4"
                        font.pixelSize: 16
                        font.bold: parent.active
                    }

                    MouseArea {
                        id: gMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bar.goToGroup(modelData)
                    }
                }
            }

            // Empurra o relogio pro rodape.
            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 32; height: 1
                color: "#585b70"
            }

            // Relogio
            Text {
                id: clock
                Layout.alignment: Qt.AlignHCenter
                color: "#cdd6f4"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDateTime(new Date(), "hh\nmm")

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh\nmm")
                }
            }
        }
    }
}
