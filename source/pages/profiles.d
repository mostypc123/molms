module pages.profiles;

import std.typecons : Nullable;
import std.string : replace;
import vibe.vibe;
import database;
import utils;

const string page = import("profiles.template.html");

void addProfilesPage(URLRouter router, Database db) {
  router.get("/profiles/:user", (req, res) @trusted {
    auto user = req.params["user"];
    auto site = db.getProfileField(user, "website");

    if (site.isNull) {
      res.statusCode = 404;
      res.writeHtmlBody(html("No such user."));
      return;
    }

    auto bio = db.getProfileField(user, "bio").get().htmlEscape();
    bio = bio.length ? bio : "<i>No bio</i>";

    string website = htmlEscape(site.get);
    website = site.get.length ? "<a href=\"" ~ website ~ "\">" ~ website ~ "</a>" : "<i>Not set by the user</a>";

    res.writeHtmlBody(html(
      page
        .replace("<?data>user</?data>", htmlEscape(user))
        .replace("<?data>website</?data>", website)
        .replace("<?data>bio<?/data>", bio)
    ));
  });
}
