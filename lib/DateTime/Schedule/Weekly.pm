package DateTime::Schedule::Weekly;
use v5.26;

use Object::Pad;

class DateTime::Schedule::Weekly {
  inherit DateTime::Schedule;

  use Readonly;
  Readonly::Array my @DAY_NUMS => (undef, qw(monday tuesday wednesday thursday friday saturday sunday));

  use constant true => !!1;
  use constant false => !true;

  field $sunday    :param :reader = true;
  field $monday    :param :reader = true;
  field $tuesday   :param :reader = true;
  field $wednesday :param :reader = true;
  field $thursday  :param :reader = true;
  field $friday    :param :reader = true;
  field $saturday  :param :reader = true;

  ADJUST {
    die("At least one day must be scheduled") unless(
      $self->sunday    || 
      $self->monday    || 
      $self->tuesday   || 
      $self->wednesday || 
      $self->thursday  || 
      $self->friday    || 
      $self->saturday
    );
  }

  sub weekdays($class, @params) {
    __PACKAGE__->new(sunday => false, saturday => false, @params)
  }

  sub weekends($class, @params) {
    __PACKAGE__->new(monday => false, tuesday => false, wednesday => false, thursday => false, friday => false, @params)
  }

  method calc_recurrence :override () {
    return sub ($prev) {
      return $prev if ($prev->is_infinite);
      my $next = $prev;
      while(1) {
        $next = $next->add(days => 1);
        my $day_name = $DAY_NUMS[$next->day_of_week];
        next if($self->exclude->contains($next));
        return $next if($self->include->contains($next) || $self->$day_name);
      };
    }
  }
}
