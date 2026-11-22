module pages.courses;

import std.typecons : Nullable;
import std.string : replace;
import std.conv : to;
import md_to_html;
import vibe.vibe;
import database;
import std.json;
import utils;

void addCourseHandling(URLRouter router, Database db) {
  router.post("/courses/upload", (req, res) @trusted {
    try {
      if (!req.session) {
        res.statusCode = 401;
        res.writeHtmlBody("Not logged in");
        return;
      }

      auto file = "file" in req.files;

      if (file is null) {
        res.redirect("/home");
        return;
      }

      string content = readFileUTF8(file.tempPath);

      auto json = parseJSON(content);
      int price = json["price"].get!int;
      auto type = json["type"].get!string;
      auto title = json["title"].get!string;
      auto subtitle = json["subtitle"].get!string;

      string courseContent;
      foreach (mem; json["content"].array) {
        courseContent ~= mem.get!string ~ "\n";
      }
      courseContent = markdownToHtml(courseContent);

      db.addCourse(req.sessionUser(), title, subtitle, courseContent, type, Nullable!int(price));
      res.redirect("/home");
    } catch (Exception e) {
      res.handleError("course upload", e);
    }
  });

  router.get("/courses/:id", (req, res) @trusted {
    try {
      auto id = to!ulong(req.params.get("id", ""));

      auto courseNullable = db.getCourseById(id);
      if (courseNullable.isNull) {
        res.statusCode = 404;
        res.writeHtmlBody(html("Course not found"));
        return;
      }

      auto course = courseNullable.get();

      if (!course.price.isNull || course.price.get > 0) {
        res.writeHtmlBody(html("This course is paid - " ~ to!string(course.price) ~ " euros. (todo: implement payment)"));
      }

      const string page = import("course.template.html");
      res.writeHtmlBody(html(
        page
          .replace("<?data>course</?data>", course.title.htmlEscape())
          .replace("<?data>subtitle</?data>",
            course.subtitle.length ? "<h3 style='margin:0px'>" ~ course.subtitle.htmlEscape() ~ "</h3>" : "")
          .replace("<?data>id</?data>", to!string(id))
          .replace("<?data>author</?data>", course.username.htmlEscape())
          .replace("<?data>content</?data>", course.content)
      ));

    } catch (Exception e) {
      res.handleError("course view", e);
    }
  });

  router.get("/courses", (req, res) @trusted {
    try {
      string page = "<h1>Courses list</h1><hr>";
      foreach (course; db.listCourses()) {
        page ~=
          ((course.price.isNull || course.price == 0) ?
          "<code style='color:green'>FREE</code>" : "<code style='color:red'>PAID</code>") ~
          " | <a href='/courses/" ~ to!string(course.id) ~ "'>" ~ course.title ~ "</a><br>";
      }
      res.writeHtmlBody(html(page));
    } catch (Exception e) {
      res.handleError("courses view", e);
    }
  });
}
