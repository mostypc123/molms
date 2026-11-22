module pages.welcome;

import vibe.vibe;
import database;
import utils;

const string page = import("welcome.html");

void addWelcomePage(URLRouter router, Database db) {
  router.get("/welcome", (req, res) @trusted {
    res.writeHtmlBody(html(page));
  });

  router.post("/welcome/send", (req, res) @trusted {
    string user = req.session.get!string("user");

    if (req.form["bio"] != "") {
      db.setProfileField(user, "bio", req.form["bio"]);
    }

    if (req.form["url"] != "") {
      db.setProfileField(user, "url", req.form["url"]);
    }

    res.redirect("/home");
  });
}
