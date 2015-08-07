.pragma library
.import QtQuick.LocalStorage 2.0 as Sql

function getSettings(key, defaultValue) {
    var db = Sql.LocalStorage.openDatabaseSync(
                "com.ubuntu.calendar", "1.0", "Calendar offline storage", 50);

    db.transaction (function (tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS settings (key TEXT UNIQUE, value BLOB)");
        var rs = tx.executeSql("SELECT * FROM settings");

        var item = {};
        for (var i = 0; i < rs.rows.length; i++) {
            if (key === rs.rows.item(i).key) {
                defaultValue = rs.rows.item(i).value;
                return;
            }
        }
    })

    return defaultValue;
}

function updateSettings(key, value) {
    var db = Sql.LocalStorage.openDatabaseSync(
                "com.ubuntu.calendar", "1.0", "Calendar offline storage", 50);

    db.transaction (function (tx){
        tx.executeSql("INSERT OR REPLACE INTO settings VALUES(?, ?)",
                      [key, value]);
    })
}

