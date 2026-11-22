module pages.home;

import vibe.vibe;
import database;
import utils;

const string page = import("home.template.html");

void addHomePage(URLRouter router, Database db) {
  import std.string : replace;

  router.get("/home", (req, res) @trusted {
    res.writeHtmlBody(html(
      page.replace("<?data>user</?data>", req.session.get!string("user"))
    ));
  });
}
