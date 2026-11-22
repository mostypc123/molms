import std.string : toStringz;
import std.conv : to;
import core.stdc.stdlib : free;

extern(C) char* cmark_markdown_to_html(const char *text, size_t len, int options);

string markdownToHtml(string markdown) {
  auto html = cmark_markdown_to_html(markdown.toStringz(), markdown.length, 0);
  scope(exit) free(html);

  return to!string(html);
}

unittest {
  import std.string : strip;
  assert(markdownToHtml("# Hello").strip() == "<h1>Hello</h1>", "markdownToHtml turns markdown into html");
}
