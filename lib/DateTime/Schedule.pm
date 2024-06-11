package DateTime::Schedule;
use v5.26;

use Object::Pad;

class DateTime::Schedule {
  use DateTime::Set;
  
  field $portion :param :reader = 1;

  field $include :param :reader = [];
  field $exclude :param :reader = [];

  ADJUST {
    $portion = 0 if($portion < 0);
    $portion = 1 if($portion > 1);
    $include = DateTime::Set->from_datetimes(dates => [map { $_->clone->truncate(to => 'day') } $include->@*]);
    $exclude = DateTime::Set->from_datetimes(dates => [map { $_->clone->truncate(to => 'day') } $exclude->@*]);
  }

  my sub day_frac($datetime) {
    my $this_day = $datetime->clone->truncate(to => 'day');
    my $next_day = $this_day->clone->add(days => 1);
    my $total = $next_day->epoch - $this_day->epoch; #total number of seconds in "this" day
    my $diff = $datetime->epoch - $this_day->epoch; #number of seconds elapsed since beginning of day
    return $diff/$total;
  }

  method calc_recurrence() {
    return sub ($prev) {
      return $prev if ($prev->is_infinite);
      my $next = $prev;
      while(1) {
        $next = $next->add(days => 1);
        next if($self->exclude->contains($next));
        return $next;
      };
      return $next;
    }
  }

  method days_in_range($start, $end) {
    $start = $start->clone;
    $end = $end->clone;
    $start = $start->subtract(days => 1) if(day_frac($start) < $portion);
    $end = $end->add(days => 1) if(day_frac($end) > $portion);
    $start->truncate(to => 'day');
    $end->truncate(to => 'day');

    DateTime::Set->from_recurrence(
      after  => $start,
      before => $end,
      recurrence => $self->calc_recurrence()
    )
  }

}
