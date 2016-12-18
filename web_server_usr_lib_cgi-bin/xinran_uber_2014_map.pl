#!/usr/bin/perl -w

use strict;
use warnings;
use 5.10.0;
use HBase::JSONRest;
use CGI qw/:standard/;

my $daySince20140401 = param('daySince20140401');

my $hbase = HBase::JSONRest->new(host => 'localhost:8080');

sub cellValue {
    my $row = $_[0];
    my $field_name = $_[1];
    my $row_cells = ${$row}{'columns'};
    foreach my $cell (@$row_cells) {
        if ($$cell{'name'} eq $field_name) {
            return $$cell{'value'};
        }
    }
    return 'missing';
}

my $records = $hbase->get({
    table => 'xinran_uber_2014_map_batch',
    where => {
        key_equals => $daySince20140401
    },
});

my $row = @$records[0];

# Act as AJAX server
print header(-type => 'text/plain', -charset => 'UTF-8');

print $daySince20140401;
print ',';
print cellValue($row, 'uber2014:dateDisplay');
print ',';
print cellValue($row, 'uber2014:dayOfWeek');
print ',';
print cellValue($row, 'uber2014:guiData');


