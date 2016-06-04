# PDF Bookmark Applicator

When you have to work with a several-hundred-page PDF file, it's nice to have
an index to jump around. Not every PDF has one, however. This script uses a
couple of utilities to help you add an index to your own PDF files.

Usage: `apply-bookmarks.pl ${PDF_FILE}.pdf ${BOOKMARKS_FILE}`

Output: `${PDF_FILE}.bookmarked.pdf`

## Requirements:

* perl
* pdftk >= v1.45 (2012-12-06) - for working with PDF files
* libreoffice/openoffice - for importing the spreadsheet

## Bookmarks file:
For reasons of personal preference, I decided to use LibreOffice Calc to
record the bookmarks of my 300-page scanned PDF file. Don't ask why; I
just like spreadsheets sometimes.

If you want to use a text file instead of a spreadsheet, this script can
be modified for that. Just get rid of the Libreoffice conversion and
replace the CSV parsing regex.

My bookmarks spreadsheet looks like this:

```
     | A  | B   | C    |
  ---+----+-----+------+--
   1 |  1 | Front Cover|
  ---+----+-----+------+--
   2 |  2 | Introduction
  ---+----+-----+------+--
   3 |  3 | Chapter One|
  ---+----+-----+------+--
   4 |  3 |     | Section One
  ---+----+-----+------+--
   5 |  4 |     |      |
  ---+----+-----+------+--
   6 |  5 |     | Section Two
  ---+----+-----+------+
```

Down the left side, I've applied the formula A{n}=A{n-1}+1 to create a list
of page numbers. For each bookmark that I want to create, I go to the row
for the page, tab over as many indentation levels as appropriate, and
type in the name of the bookmark. To make it easier to read, I make the
columns narrower than the bookmark text.

Not every page has a bookmark, so this script ignores rows wihout a
bookmark name.

Some pages have multiple bookmarks. When that happens, I put the duplicate
bookmark on the next line down and manually type in the page number. Since
the page numbers are a formula by default, the page numbers following
automatically re-flow.

As long as I only add duplicate bookmarks before pages I've already
labeled, it's fine.

## References:

Example on writing the PDF metadata:
http://unix.stackexchange.com/questions/17065/add-and-edit-bookmarks-to-pdf


