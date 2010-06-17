use strict;
use warnings;

package Template::Input::Text;

use base 'Template::Input';
use overload '""' => \&as_string;

__PACKAGE__->mk_classaccessors(qw/size/);
__PACKAGE__->template(do { local $/; <DATA> });

# You're a grown-up man, Gedevan Alexandrovich. You had studied for a term, and
# then disappeared for years! And now you pop up! With a piece of rock, with
# a shatter of Caucasian pottery and a fishing bell! And you put in a claim...
sub as_string {
    my $self = shift;
    $self->vars(size => $self->size);
    $self->SUPER::as_string(@_);
}

1;

__DATA__
<input{ id="{id}"} type="text"{ name="{name}"}{ value="{value}"}{ size="{size}"}{ disabled="{disabled}"}{ readonly="{readonly}"}/>
