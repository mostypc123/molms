module pages.welcome;

import vibe.vibe;
import database;
import utils;

const string page = import("welcome.html");

void addWelcomePage(URLRouter router, Database db) {
  router.get("/welcome", (req, res) @trusted {
    try {
      if (req.sessionUser().length == 0) {
        res.redirect("/");
        return;
      }

      res.writeHtmlBody(html(page));
    } catch (Exception e) {
      res.handleError("welcome", e);
    }
  });

  router.post("/welcome/send", (req, res) @trusted {
    try {
      string user = req.sessionUser();

      if (user.length == 0) {
        res.redirect("/");
        return;
      }

      string bio = req.form.get("bio", "");
      string url = req.form.get("url", "");

      if (bio != "") {
        db.setProfileField(user, "bio", bio);
      }

      if (url != "") {
        db.setProfileField(user, "website", url);
      }

      res.redirect("/home");
    } catch (Exception e) {
      res.handleError("welcome send", e);
    }
  });
}
