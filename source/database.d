import std.typecons : Nullable;
import sql = d2sqlite3;
import arsd.argon2;

class Database {
  public {
    this(string file) {
      db = sql.Database(file);

      db.run(
        `CREATE TABLE IF NOT EXISTS users (
          username TEXT NOT NULL UNIQUE,
          pwd_hash TEXT NOT NULL,
          bio TEXT,
          website TEXT
        )`
      );

      db.run("PRAGMA foreign_keys = ON;");
    }

    bool userExists(string username) {
      return db.execute(
        "SELECT EXISTS(SELECT 1 FROM users WHERE username = ?)",
        username
      ).oneValue!bool;
    }

    bool checkLogin(string username, string pwd) {
      auto rows = db.execute("SELECT pwd_hash FROM users WHERE username = ?", username);
      if (rows.empty) return false;

      string stored = rows.front["pwd_hash"].as!string;
      return verify(stored, pwd);
    }

    bool addUser(string username, string unhashed_pwd) {
      if (userExists(username)) {
        return checkLogin(username, unhashed_pwd);
      }

      string hash = encode(unhashed_pwd);

      db.execute(
        "INSERT INTO users (username, pwd_hash) VALUES (?, ?)",
        username, hash
      );

      return true;
    }

    bool setProfileField(string username, string field, string value) {
      if (field != "bio" && field != "website") return false;

      db.execute(
        "UPDATE users SET " ~ field ~ " = NULLIF(?, '') WHERE username = ?",
        value, username
      );

      return db.changes > 0;
    }

    Nullable!string getProfileField(string username, string field) {
      if (field != "bio" && field != "website") return Nullable!string.init;

      auto rows = db.execute(
        "SELECT COALESCE(" ~ field ~ ", '') FROM users WHERE username = ?",
        username
      );

      if (rows.empty) return Nullable!string.init;

      return Nullable!string(rows.front.peek!string(0));
    }
  }

  private {
    sql.Database db;
  }
}
