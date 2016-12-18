#!/usr/bin/perl -w

use strict;
use warnings;
use 5.10.0;
use HBase::JSONRest;
use CGI qw/:standard/;

my $locationName = param('locationName');
my $timeRange = param('timeRange');

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

# If timeRange is All the time
sub all_time {

    $locationName = $_[0];

    my $guiData = '';

    # Batch layer
    my $records_batch = $hbase->get({
        table => 'xinran_uber_2015_plot_batch',
        where => {
            key_begins_with => $locationName
        },
    });
    foreach (@$records_batch) {
        $guiData .= cellValue($_, 'uber2015:guiData') . '|';
    }

    # Speed layer
    my $records_speed = $hbase->get({
        table => 'xinran_uber_2015_plot_speed',
        where => {
            key_equals => $locationName
        },
    });
    my $row = @$records_speed[0];
    $guiData .= '|||' . cellValue($row, 'uber2015:guiData');

    # Act as AJAX server
    print header(-type => 'text/plain', -charset => 'UTF-8');

    print $locationName;
    print '|';
    print 'All the time';
    print '|';
    print $guiData;
}

# If timeRange is a single month
sub single_month {

    $locationName = $_[0];
    $timeRange = $_[1];

    # Batch layer only
    my $key = $locationName . '+' . $timeRange;

    my $records_batch = $hbase->get({
        table => 'xinran_uber_2015_plot_batch',
        where => {
            key_equals => $key
        },
    });

    my $row = @$records_batch[0];

    # Act as AJAX server
    print header(-type => 'text/plain', -charset => 'UTF-8');

    print $locationName;
    print '|';
    print $timeRange;
    print '|';
    print cellValue($row, 'uber2015:guiData');
}

# Determine if timeRange is All the time or a single month
if ($timeRange eq '-1') {
    all_time($locationName);
} else {
    single_month($locationName, $timeRange);
}


