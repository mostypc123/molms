module pages.profiles;

import std.typecons : Nullable;
import std.string : replace;
import vibe.vibe;
import database;
import utils;

const string page = import("profiles.template.html");

void addProfilesPage(URLRouter router, Database db) {
  router.get("/profiles/:user", (req, res) @trusted {
    try {
      auto user = req.params.get("user", "");
      auto site = db.getProfileField(user, "website");

      if (site.isNull) {
        res.writeHtmlBody(html("No such user."), 404);
        return;
      }

      auto bioField = db.getProfileField(user, "bio");
      string bio = bioField.isNull ? "" : htmlEscape(bioField.get);
      bio = bio.length ? bio : "<i>No bio</i>";

      string website = htmlEscape(site.get);
      website = site.get.length ? "<a href=\"" ~ website ~ "\">" ~ website ~ "</a>" : "<i>Not set by the user</i>";

      res.writeHtmlBody(html(
        page
          .replace("<?data>user</?data>", htmlEscape(user))
          .replace("<?data>website</?data>", website)
          .replace("<?data>bio</?data>", bio)
      ));
    } catch (Exception e) {
      res.handleError("profile", e);
    }
  });

  router.get("/profiles", (req, res) @trusted {
    try {
      auto users = db.listUsers();
      string page = "<h1>Users</h1><hr>";

      foreach (user; users) {
        page ~= "<a href=\"/profiles/" ~ htmlEscape(user) ~ "\">" ~ htmlEscape(user) ~ "</a><br>";
      }

      res.writeHtmlBody(html(page));
    } catch (Exception e) {
      res.handleError("profile", e);
    }
  });
}
