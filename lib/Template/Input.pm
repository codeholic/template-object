use strict;
use warnings;

package Template::Input;

use base 'Template::Object';
use overload '""' => \&as_string;

__PACKAGE__->mk_classaccessors(qw/id name value disabled readonly/);

sub as_string {
    my $self = shift;
    $self->vars(map { $_ => $self->$_ } qw/id name value/);
    $self->vars(map { $self->$_ ? ($_ => $_) : () } qw/disabled readonly/);
    return $self->SUPER::as_string(@_);
}

1;
