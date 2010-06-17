use strict;
use warnings;

package Template::Object;

use Carp ();
use File::Spec ();

use base qw/Class::Data::Accessor/;
use overload '""' => \&as_string;

__PACKAGE__->mk_classaccessor(root => File::Spec->curdir);
__PACKAGE__->mk_classaccessor('template');

our $VERSION = 0.01;

sub new {
    my $class = shift;
    my $self = bless {}, ref $class || $class;
    return $self->init(@_);
}

sub init {
    my $self = shift;

    # Hello, Jerry? Homer Simpson. Remember last month when I paid back
    # that loan? Well now I need YOU to do a favor for ME.
    my $args = exists $_[0] ? exists $_[1] ? {@_} : {%{$_[0]}} : {};
    while (my ($method => $method_args) = each %$args) {
	$self->$method($method_args);
    }
    
    return $self;
}

sub file {
    my ($self, $file) = @_;

    open my $fh, '<', File::Spec->catfile($self->root, $file)
        or Carp::croak("$file: $!");
    $self->template(do { local $/; <$fh> });
    close $fh;

    return $self;
}

sub vars {
    my $self = shift;
    
    if (ref $_[0] ne 'HASH') {
	my $attrs = @_ > 2 && @_ % 2 ? pop : {};
	return $self->vars({@_}, $attrs);
    }
    
    my ($vars, $attrs) = @_;
    $attrs ||= {};

    while (my ($varname, $value) = each %$vars) {
        if (!$self->{vars}{$varname} || !$attrs->{append}) {
            $self->{vars}{$varname} = [];
        }
        push @{$self->{vars}{$varname}}, ref $value eq 'ARRAY' ? @$value : $value
            if $value;
    }

    # Return self for chaining.  Very useful for initializing newly created blocks!
    return $self;
}

sub extract_block {
    my $self = shift;
    my $attrs = ref $_[-1] eq 'HASH' ? pop : {};
    my ($name) = @_;

    if (!exists $self->{blocks}{$name}) {
	return unless (my $t = $self->template) =~
            s/
		<!-- \s+ BEGIN \s+ \Q$name\E \s+ --> [ \t]* \n?
		(.*?)
		<!-- \s+ END \s+ \Q$name\E \s+ --> [ \t]* \n?
	    /{{$name}}/sx;
	
	$self->template($t);
	$self->{blocks}{$name} = $1;
    }
    
    return if !defined wantarray; # void context

    my $class = $attrs->{class} || __PACKAGE__;
    return $class->new(template => $self->{blocks}{$name}, vars => {});
}

sub as_string {
    my $self = shift;

    $self->preprocess if $self->can('preprocess');

    # Right now this just blanks out any unknown {{vars}}.  Might be
    # neat to support a 'strict' mode that requires all vars to have
    # substitutions or else raises an error.

    my $ret = $self->template;
    $ret =~ s/\{ ([^{}]*) \{ ([^{}]*) \} ([^{}]*) \}/
	$self->{vars}{$2}
	    ? join '', map { $1 . $_ . $3 } @{$self->{vars}{$2}}
	    : ''
    /egsx;

    return $ret;
}

1;

=head1 NAME

Template::Object - lightweight object-oriented template engine

=head1 SYNOPSIS

=head2 example.tpl

    <h1>{{title}}</h1> 
    <!-- BEGIN list --> 
    <ul> 
    <!-- BEGIN item --> 
        <li>{{name}} are {{attr}}</li> 
    <!-- END item --> 
    </ul> 
    <!-- END list --> 
    <!-- BEGIN empty --> 
    <p>The list is empty.</p> 
    <!-- END empty -->

=head2 example.pl

    use Template::Object;

    my @colors = (
        { name => 'apples', attr => 'red' },
        { name => 'bananas', attr => 'yellow' },
        { name => 'people', attr => 'blue' },
    );

    Template::Object->root('templates');

    my $t = Template::Object->new(file => 'example.tpl');
    $t->vars(title => 'Colors');

    # TMTOWTDI!
    # my $t = Template::Object->new(file => 'example.tpl')->vars(title => 'Colors');
    # my $t = Template::Object->new(file => 'example.tpl')->vars(title => [ 'Colors' ]);
    # my $t = Template::Object->new(file => 'example.tpl')->vars({ title => 'Colors' });
    # my $t = Template::Object->new(file => 'example.tpl')->vars({ title => [ 'Colors' ] });
    # my $t = Template::Object->new(file => 'example.tpl', vars => { title => 'Colors' });
    # my $t = Template::Object->new(file => 'example.tpl', vars => { title => [ 'Colors' ] });
    # my $t = Template::Object->new({ file => 'example.tpl', vars => { title => [ 'Colors' ] } });

    if (@colors) {
        my ($list) = map { $t->extract_block($_) } qw/list empty/;
        foreach (@colors) {
            my $item = $list->extract_block('item');
            
            # TMTOWTDI!
            #my $item = $list->extract_block('item', { class => 'Template::Object' });
            
            $item->vars($_); # TMTOWTDI! ...
            $list->vars(item => $item, { append => 1 });
            
            # TMTOTDI!
            # $list->vars({ item => $item }, { append => 1 });
            # $list->vars({ item => [ $item ] }, { append => 1 });
        }
        $t->vars(list => $list);
    }
    else {
        my ($empty) = map { $t->extract_block($_) } qw/empty list/;
        $t->vars(empty => $empty);
    }

    print $t;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2010 by Ivan Fomichev

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
