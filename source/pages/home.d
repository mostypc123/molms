module pages.home;

import vibe.vibe;
import database;
import utils;

const string page = import("home.template.html");

void addHomePage(URLRouter router, Database db) {
  import std.string : replace;

  router.get("/home", (req, res) @trusted {
    try {
      string user = req.sessionUser();

      if (user.length == 0) {
        res.redirect("/");
        return;
      }

      res.writeHtmlBody(html(
        page.replace("<?data>user</?data>", htmlEscape(user))
      ));
    } catch (Exception e) {
      res.handleError("home", e);
    }
  });
}
