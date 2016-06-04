#!/usr/bin/env perl
##############################################################################
# Create/update the bookmarks of a PDF file based on a spreadsheet file
#
# Usage: apply-bookmarks <pdf file>.pdf <bookmarks file>
# Output: <pdf file>.bookmarked.pdf
#
# Bookmarks file:
#   For reasons of personal preference, I decided to use LibreOffice Calc to
#   record the bookmarks of my 300-page scanned PDF file. Don't ask why; I
#   just like spreadsheets sometimes.
#
#   Mine looks like this:
#      | A  | B   | C    |
#   ---+----+-----+------+--
#    1 |  1 | Front Cover|
#   ---+----+-----+------+--
#    2 |  2 | Introduction
#   ---+----+-----+------+--
#    3 |  3 | Chapter One|
#   ---+----+-----+------+--
#    4 |  3 |     | Section One
#   ---+----+-----+------+--
#    5 |  4 |     |      |
#   ---+----+-----+------+--
#    6 |  5 |     | Section Two
#   ---+----+-----+------+
#
#   Down the left side, I've apply the formula A{n}=A{n-1}+1 to create a list
#   of page numbers. For each bookmark that I want to create, I go to the row
#   for the page, tab over as many indentation levels as appropriate, and
#   type in the name of the bookmark. To make it easier to read, I make the
#   columns narrower than the bookmark text.
#
#   Not every page has a bookmark, so this script ignores rows wihout a
#   bookmark name.
#
#   Some pages have multiple bookmarks. When that happens, I put the duplicate
#   bookmark on the next line down and manually type in the page number. Since
#   the page numbers are a formula by default, the page numbers following
#   automatically re-flow.
#
#   As long as I only add duplicate bookmarks before pages I've already
#   labeled, it's fine.
#
# Requirements:
#   pdftk >= v1.45 (2012-12-06) - for working with PDF files
#   libreoffice/openoffice - for importing the spreadsheet
#
# Example on writing the PDF metadata:
#   http://unix.stackexchange.com/questions/17065/add-and-edit-bookmarks-to-pdf

use strict;
use warnings;

# Parse arguments
my ($input_pdf, $bookmark_spreadsheet) = @ARGV;

#my $DRY_RUN = 1;
my $DRY_RUN = 0;
my $logging = 1;

# Output and intermediate filenames
my $bookmark_csv = $bookmark_spreadsheet;
$bookmark_csv =~ s/\.[^\.]+$/.csv/;

my $output_pdf = $input_pdf;
$output_pdf =~ s/(\.[^\.]+$)/.bookmarked$1/;

# Export the bookmark file into something Perl can parse easily
my $output = `soffice --convert-to csv '$bookmark_spreadsheet' --headless`;
if ($? != 0) {
    die "Libreoffice command failed:\n$output\n";
}
elsif (not -f $bookmark_csv) {
    die "Libreoffice didn't created expected file at $bookmark_csv. (Is it still running?)\nOutput:\n$output\n";
}

# Load the existing metadata, stripping existing bookmarks
my @pdf_metadata = grep {!/^Bookmark/} `pdftk "$input_pdf" dump_data`;
if ($? != 0) {
    die "pdftk command failed";
}

# Patch the info file
print "Output file will be $output_pdf\n";
my $pdftk_fh;
if (not $DRY_RUN) {
    open($pdftk_fh, "| pdftk '$input_pdf' update_info - output '$output_pdf'")
        or die("Failed to start pdftk: $!");
}

# Re-insert existing metadata lines
foreach my $line (@pdf_metadata) {
    if ($DRY_RUN) {
        print $line;
    } else {
        if ($logging) { print $pdftk_fh $line; }
    }
}

# Insert bookmark data
open(my $bookmark_fh, "<$bookmark_csv") or die $!;
foreach my $line (<$bookmark_fh>) {
    if ($line =~ /(\d+)(,+)([^,]+).+/) {
        my $page_number = $1;
        my $indentation = length($2);
        my $title = $3;
        if ($DRY_RUN) {
            print "BookmarkBegin\n";
            print "BookmarkTitle: $title\n";
            print "BookmarkLevel: $indentation\n";
            print "BookmarkPageNumber: $page_number\n";
        } else {
            if ($logging) { print "BookmarkBegin"; }
            if ($logging) { print "BookmarkTitle: $title\n"; }
            if ($logging) { print "BookmarkLevel: $indentation\n"; }
            if ($logging) { print "BookmarkPageNumber: $page_number\n"; }
            print $pdftk_fh "BookmarkBegin\n";
            print $pdftk_fh "BookmarkTitle: $title\n";
            print $pdftk_fh "BookmarkLevel: $indentation\n";
            print $pdftk_fh "BookmarkPageNumber: $page_number\n";
        }
    }
}
close $bookmark_fh;

if (not $DRY_RUN) {
    close $pdftk_fh;
}


