use strict;
use warnings;

package Template::Input::Select;

use base qw/Template::Input/;
use overload '""' => \&as_string;

__PACKAGE__->mk_classaccessor(option_value_from => 'id');
__PACKAGE__->mk_classaccessor(option_text_from  => 'name');
__PACKAGE__->mk_classaccessors(qw/value_from multiple nullable options/);

__PACKAGE__->template(do { local $/; <DATA> });

sub as_string {
    my $self = shift;

    my %p = map { $_ => $self->$_ }
	qw/option_value_from option_text_from value_from name value multiple nullable/;
    $self->vars(multiple => 'multiple') if $p{multiple};

    my $options = $self->options;
    if (ref $options->[0] ne 'HASH') {
	$options = [ map { +{ $p{option_text_from} => $_ } } @$options ];
    }
    
    if (defined $p{multiple}) {
        $self->vars(multiple => 'multiple');
    }
    elsif ($p{nullable}) {
	$options = [ { $p{option_text_from} => '' }, @$options ];
    }

    $self->extract_block('option');

    my %values;
    for (ref $p{value} eq 'ARRAY' ? @{$p{value}} : $p{value}) {
        my $v = ref $_ eq 'HASH'
	    ? do {
		my $k = $p{value_from}
		    || ($p{multiple} ? $p{option_value_from} : $p{name});
		$_->{$k};
	    }
	    : $_;
	!defined $v and ($p{nullable} ? ($v = '') : next);
        $values{$v}++;
    }
    
    # You can't buy lutz in pieces! Lutz is worth 10 tchatles per charge,
    # and we've got only seven!
    foreach my $item (@$options) {
	my $option = $self->extract_block('option');
	$option->vars($item);

	my $value = exists $item->{$p{option_value_from}}
	    ? $item->{$p{option_value_from}} : $item->{$p{option_text_from}};
	$option->vars('selected', 'selected') if $values{$value};
	$self->vars(option => $option, { append => 1 });
    }

    return $self->SUPER::as_string(@_);
}

1;

__DATA__
<select{ id="{id}"}{ name="{name}"}{ multiple="{multiple}"}{ disabled="{disabled}"}{ readonly="{readonly}"}>
<!-- BEGIN option -->
<option{ value="{id}"}{ selected="{selected}"}>{{name}}</option>
<!-- END option -->
</select>
