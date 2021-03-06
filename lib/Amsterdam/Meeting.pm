package Amsterdam::Meeting;
use 5.01000;
use warnings;
use strict;

=head1 NAME

Amsterdam::Meeting - Bereken de datum van de volgende Amsterdam.pm meeting

=head1 SYNOPSIS

    use Amsterdam::Meeting ':all';
    printf "Volgende meeting in Amsterdam: %s\n", next_amsterdam_meeting();

=head1 DESCRIPTION

Meetings worden gehouden op de eerste dinsdag van de maand, met uitzondering
van:

=over

=item B<1 januari> wordt 8 januari

=item B<5 mei> wordt 12 mei

=item B<5 december> wordt 12 december

=back

Daarnaast zullen er jaarlijks uitzonderingen zijn:

=over

=item 1 mei 2012 => 8 mei 2012

=back

=cut

use Exporter 'import';
our @EXPORT_OK = qw/next_amsterdam_meeting amsterdam_meeting_time/;
our %EXPORT_TAGS = (all => [@EXPORT_OK]);

use Time::Local;

=head2 my $datum = next_amsterdam_meeting()

=head3 Argumenten

Geen.

=head3 Retour

Een datumstring met de maand in het Nederlands (strftime "%e %B %Y").

=cut

sub next_amsterdam_meeting {
    my $now = time();
    my @now = localtime($now);

    my $month = $now[4]; # 0..11
    my $year  = $now[5] + 1900;

    my $meeting = amsterdam_meeting_time($month, $year);
    if ($meeting < $now) {
        $month++;
        if ($month > 11) {
            $month = 0;
            $year++;
        }
        $meeting = amsterdam_meeting_time($month, $year);
    }

    return date_nl($meeting);
}

=head2 my $stamp = amsterdam_meeting_time(@argumenten)

=head3 Argumenten

Positioneel.

=over

=item $maand <0..11>

=item $jaar

=back

=head3 Retour

Een timestamp.

=cut

sub amsterdam_meeting_time {
    my ($month, $year) = @_;

    $month //= (localtime time())[4];
    $year  //= (localtime time())[5] + 1900;

    # get the weekday of the first of the month
    my $wday = (localtime timelocal 0, 0, 0, 1, $month, $year)[6];
    my $mday = ( (9 - $wday) % 7 ) + 1;

    # not on 1 jan, 1 or 5 may, 5 dec;
    if (   ($month == 0 && $mday == 1)
        or ($month == 4 && $mday == 1 && $year == 2012)
        or ($month == 4 && $mday == 5)
        or ($month == 11 && $mday == 5))
    {
        $mday += 7;
    }

    return timelocal(0, 0, 20, $mday, $month, $year);
}

=head2 my $datum = date_nl($stamp)

=head3 Argumenten

Positioneel.

=over

=item $timestamp

=back

=head3 Retour

Een datumstring met de maand in het Nederlands.

=cut

sub date_nl {
    my ($stamp) = @_;

    my ($mday, $month, $year) = (localtime($stamp))[3, 4, 5];

    my $month_name = [
        qw/
            januari februari maart april mei juni juli
            augustus september oktober november december
        /
    ]->[$month];

    return sprintf("%d %s %d", $mday, $month_name, $year + 1900);
}

1;

=head1 STUFF

(c) MMIX - MMXII Abe Timmerman <abeltje@cpan.org>

=cut
