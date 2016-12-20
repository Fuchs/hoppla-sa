/*
    Copyright 2016-2017 Christian Loosli <develop@fuchsnet.ch>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the original Author.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0


Item {
    ColumnLayout {
        Layout.fillWidth: true

        GroupBox {
            Layout.fillWidth: true
            flat: true
            title: i18n("Bridge")

            GridLayout {
                columns: 2
                Layout.fillWidth: true

                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Bridge URL:")
                }

                TextField {
                    id: baseURL
                }

                Label {
                    Layout.alignment: Qt.AlignRight
                    text: i18n("Authentication Token:")
                }

                TextEdit {
                    id: authToken
                }
            }
        }
    }
}
