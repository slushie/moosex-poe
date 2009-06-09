package MooseX::POE::Meta::Trait::Class;

use Moose::Role;

with qw(MooseX::POE::Meta::Trait);

around 'default_events' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $event_map = $self->$orig(@_);
    for my $method (reverse $self->get_all_methods) {
        my $name = $method->name;
        $name =~ s/^on_// or next;
        $event_map->{$name} = $method->name;
    }

    return $event_map;
};

around 'add_role' => sub {
    my ( $next, $self, $role ) = @_;
    $next->( $self, $role );
    if (   $role->meta->can('does_role')
        && $role->meta->does_role("MooseX::POE::Meta::Trait") ) {
        $self->set_state_method_name( $role->get_event_map );
    }
};

sub get_all_events { 
    my ($self) = @_;
    
    my %events;
    for my $class (map { $_->meta } reverse $self->linearized_isa) {
        next unless $class->meta->can('does_role')
                    && $class->meta->does_role( 'MooseX::POE::Meta::Trait' );
        %events = ( %events, $class->get_event_map );
    }

    return ( %events, $self->get_event_map );
}

no Moose::Role;
1;
__END__

=head1 NAME

MooseX::POE::Meta::Trait::Class

=head1 SYNOPSIS

    use MooseX::POE::Meta::Trait::Constructor;

=head1 DESCRIPTION

The MooseX::POE::Meta::Trait::Constructor class implements ...

=head1 METHODS

=over 

=item get_all_events

=back 

=head1 DEPENDENCIES

Moose::Role

=head1 AUTHOR

Chris Prather (chris@prather.org)

=head1 LICENCE

Copyright 2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
