module database;

import std.typecons : Nullable;
import sql = d2sqlite3;
import arsd.argon2;

const string init = import("init.sql");

struct Course {
  long id;
  string username;
  string title;
  string subtitle;
  string content;
  string type;
  Nullable!int price = Nullable!int.init;
}

class Database {
  public {
    this(string file) {
      db = sql.Database(file);

      db.run(init);
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

      try {
        return verify(stored, pwd);
      } catch (Exception e) {
        return false;
      }
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

    string[] listUsers() {
      string[] users;

      foreach (row; db.execute("SELECT username FROM users ORDER BY username")) {
        users ~= row["username"].as!string;
      }

      return users;
    }

    bool addCourse(
      string username,
      string title,
      string subtitle,
      string content,
      string type,
      Nullable!int price = Nullable!int.init
    ) {
      if (!userExists(username)) return false;

      db.execute(
        "INSERT INTO courses (by_user, price, title, subtitle, content, type) VALUES (?, ?, ?, ?, ?, ?)",
        username, price, title, subtitle, content, type
      );

      return db.changes > 0;
    }

    Nullable!Course getCourseById(long id) {
      auto rows = db.execute(
        "SELECT id, by_user, title, subtitle, content, type, price FROM courses WHERE id = ?",
        id
      );

      if (rows.empty) return Nullable!Course.init;

      return Nullable!Course(rowToCourse(rows.front));
    }

    Course[] listCourses() {
      Course[] courses;

      foreach (row; db.execute(
        "SELECT id, by_user, title, subtitle, content, type, price FROM courses ORDER BY id"
      )) {
        courses ~= rowToCourse(row);
      }

      return courses;
    }
  }

  private {
    sql.Database db;

    Course rowToCourse(sql.Row row) {
      Course course;
      course.id = row.peek!long(0);
      course.username = row.peek!string(1);
      course.title = row.peek!string(2);
      course.subtitle = row.peek!string(3);
      course.content = row.peek!string(4);
      course.type = row.peek!string(5);

      if (row.columnType(6) != sql.SqliteType.NULL) {
        course.price = Nullable!int(row.peek!int(6));
      }

      return course;
    }
  }
}
